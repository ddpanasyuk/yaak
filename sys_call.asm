start_syscall:;maps system calls to interrupt 48
	mov eax, handle_syscall
	push handle_syscall
	mov eax, 48
	push eax
	call add_isr
	add esp, 8
	ret

	
;EAX = offset 28
;ECX = offset 24
;EDX = offset 20
;EBX = offset 16
;ESP = offset 12
;EBP = offset 8
;ESI = offset 4
;EDI = offset 0	
handle_syscall:;takes pointer to registers on stack
	push ebp
	mov ebp, esp
	mov eax, [ebp + 8]; pointer to stack of registers
	mov edx, [eax + 28]; old eax
	push eax
	mov eax, edx
	;mov edx, 4
	;mul edx
	shl eax, 2
	add eax, syscall_table; eax now holds the address of the system call
	cmp dword [eax], 0
	je handle_syscall_end
	pop edx; edx holds address of registers again
	push dword [edx]     ;edi
	push dword [edx + 4] ;esi
	push dword [edx + 20];edx
	push dword [edx + 24];ecx
	push dword [edx + 16];ebx
	call [eax] ;call the function
	add esp, 20
	mov [edx + 28], eax; return register
	handle_syscall_end:
	pop ebp
	ret
	
syscall_table:
dd k_write
dd k_read
dd test_func; reserved for k_lseek
dd 0; reserved for k_stat
dd 0; reserved for k_open
dd 0; reserved for k_close
dd 0; reserved for k_execve
dd 0; reserved for k_exit
dd k_sbrk
syscall_table_end:
times 256 * 4 - (syscall_table_end - syscall_table) db 0

test_func:
  push dword 65
  call k_putchar
  add esp, 4
  ret