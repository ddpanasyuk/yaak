gdt_load:
	cli
	lgdt [gdt_ptr]
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp 0x08:gdt_reload_segment
gdt_reload_segment:
	ret

idt_load:
	cli
	push ecx
	xor ecx, ecx
	call remap_pic
make_gate_loop:
	cmp ecx, 256 ;done making gates?
	je idt_load_cleanup
	;mov edx, 4
	mov eax, ecx
	;mul edx
	shl eax, 2
	add eax, isr_addr_table ;get offset of interrupt address
	cmp dword [eax], 0 ;make sure the address exists
	je make_gate_blank ;if its blank, make a blank gate
	push word 0x8E00
	push word 0x0008
	push dword [eax]
	push ecx
	call idt_make_gate ;make interrupt gate
	add esp, 12
	inc ecx
	jmp make_gate_loop

make_gate_blank:
	push word 0x0
	push word 0x0
	push dword 0x0
	push ecx
	call idt_make_gate ;make a completely blank gate
	add esp, 12
	inc ecx
	jmp make_gate_loop

idt_load_cleanup:
	pop ecx
	lidt [idt_ptr]
	ret

idt_make_gate: ;makes an interrupt gate with arguments -> number, address, selector, flags
;IDT DESC         OFFSET
;word base_low -> 0
;word selector -> 2
;byte 0        -> 4
;byte flags    -> 5
;word base_high-> 6
	push ebp
	mov ebp, esp
	xor eax, eax
	xor edx, edx
	mov eax, [ebp + 8]; number
	;mov edx, 8
	;mul edx
	shl eax, 3
	add eax, idt_table; get desc offset
	mov edx, [ebp + 12]; address
	mov [eax], dx
	shr edx, 16
	mov [eax + 6], dx
	mov dx, [ebp + 16]; selector
	mov [eax + 2], dx
	mov dx, [ebp + 18]; flags
	mov [eax + 4], dx
	pop ebp
	ret 

remap_pic:
	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x20
	out 0x21, al
	mov al, 0x28
	out 0xA1, al
	mov al, 0x04
	out 0x21, al
	mov al, 0x02
	out 0xA1, al
	mov al, 0x01
	out 0x21, al
	out 0xA1, al
	mov al, 0
	out 0x21, al
	out 0x21, al
	ret

;pushad -> Push EAX, ECX, EDX, EBX, original ESP, EBP, ESI, EDI
;EAX = offset 32
;ECX = offset 28
;EDX = offset 24
;EBX = offset 20
;ESP = offset 16
;EBP = offset 12
;ESI = offset 8
;EDI = offset 4
handle_isr:
	push ebp
	mov ebp, esp
	pushad; push all registers
	mov eax, [ebp + 4];number of interrupt
	;mov edx, 4
	;mul edx
	shl eax, 2
	add eax, interrupt_call_table; get address of handler
	cmp dword [eax], 0
	je handle_isr_end; no function to handle
	mov edx, ebp
	sub edx, 32
	push edx
	call [eax]; argument is edx (address of registers on stack)
	add esp, 4
handle_isr_end:
	popad
	pop ebp
	add esp, 4; get rid of interrupt number
	sti
	iret; enable interrupts and return

add_isr:;adds to isr table -> two arguments, number + address
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]
	;mov edx, 4
	;mul edx
	shl eax, 2
	add eax, interrupt_call_table; get address to write to
	mov edx, [ebp + 12]
	mov [eax], edx; write address of function
	pop ebp
	ret

handle_irq:
	;pushad
	push ebp
	mov ebp, esp
	pushad; push all registers
	mov eax, [ebp + 4]
	cmp eax, 40
	jnge irq_master;if not above 40, master interrupt
	mov al, 0x20
	out 0xA0, al;reset slave
irq_master:
	mov al, 0x20
	out 0x20, al;reset master
	mov eax, [ebp + 4];get number again
	;mov edx, 4
	;mul edx
	shl eax, 2
	add eax, interrupt_call_table
	cmp dword [eax], 0
	je handle_irq_end
	mov edx, ebp
	sub edx, 32
	push edx; get pointer to registers
	call [eax]; call at table
	add esp, 4
handle_irq_end:
	popad
	pop ebp
	add esp, 4; clean up stack + interrupt number
	sti
	iret
%include "gdt_idt_data.asm"