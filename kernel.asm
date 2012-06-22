MULTIBOOT_PAGE_ALIGN        equ 1<<0
MULTIBOOT_MEMORY_INFO       equ 1<<1
MULTIBOOT_AOUT_KLUDGE       equ 1<<16
MULTIBOOT_HEADER_MAGIC      equ 0x1BADB002
MULTIBOOT_HEADER_FLAGS      equ MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO | MULTIBOOT_AOUT_KLUDGE
MULTIBOOT_CHECKSUM  equ -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)
LOAD_ADDRESS equ 0x00100000                    

[BITS 32]
org LOAD_ADDRESS                                 

mboot: ;Multiboot 
dd  MULTIBOOT_HEADER_MAGIC         
dd  MULTIBOOT_HEADER_FLAGS         
dd  MULTIBOOT_CHECKSUM

aout: ;Aout kludge
dd mboot
dd LOAD_ADDRESS
dd 0
dd 0
dd start

start:    	
push ebx  
	cli
	call k_clear
	call gdt_load
	call idt_load
	sti
	call start_syscall
	call start_keyboard
	push boot_message
	call k_putstr
	add esp, 4
	pop ebx
	mov eax, [ebx + 24]
	push dword [eax]
	call file_sys_parse
	add esp, 4
	push test_msg
	call k_open
	add esp, 4
	push eax
	push dword [eax]
	call k_sbrk
	add esp, 4
	pop edx
	push dword [edx]
	push eax
	push edx
	call k_read
	add esp, 4
	pop eax
	add esp, 4
	push eax
	push print_msg
	call k_putstr
	add esp, 4
	call k_putstr
	jmp $ 
		
boot_message: db "YAAK v0.01", 0x0A, 0x0
test_msg: db "string.asm", 0x0
print_msg: db "Printing contents of file compile.sh: ", 0x0A, 0
%include  "print.asm"
%include  "tables.asm"
%include  "sys_call.asm"
%include  "keyboard.asm"
%include  "stream_io.asm"
%include  "load_prog.asm"
%include  "file_sys.asm"
%include  "string.asm"
%include  "sbrk.asm";must always come last