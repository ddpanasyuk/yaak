;write(), read()
k_write:;write(FILE* f_ptr, char* buff, u32int len)
	push ebp
	mov ebp, esp
	cmp dword [ebp + 8], 1; is it stdout?
	je k_write_stdout
	jmp k_write_end
	
	k_write_stdout:
	push ecx
	xor ecx, ecx
	k_write_loop:
		cmp ecx, dword [ebp + 16]
		je k_write_stdout_end; if len == reached, end
		mov eax, [ebp + 12]
		add eax, ecx ;get str address + offset
		xor edx, edx
		mov dl, [eax];get write byte
		push edx
		call k_putchar;write to stdout
		add esp, 4
		inc ecx
		jmp k_write_loop
	k_write_stdout_end:
	pop ecx
k_write_end:
	pop ebx
	ret

k_read:;read(FILE* f_ptr, char* buff, u32int len);
	push ebp
	mov ebp, esp
	cmp dword [ebp + 8], 0; is it stdin
	je k_read_stdin
	jmp k_read_end
	
	k_read_stdin:
	push ecx
	xor ecx, ecx
	k_read_loop:
		cmp ecx, dword [ebp + 16]
		je k_read_stdin_end
		mov edx, [ebp + 12]
		add edx, ecx ;get buff address + offset
		call k_getchar
		mov [edx], al
		inc ecx
		jmp k_read_loop
	k_read_stdin_end:
	pop ecx
k_read_end:
	pop ebp
	ret

std_mode:;std_mode(u32int std_num, u32int attrib) change stdio
  ;0 = stdin,  attribute = 0 (no echo) 1 (echo)
  ;1 = stdout, attribute = background / text color
  push ebp
  mov ebp, esp
  
  mov eax, [ebp + 8];stdin/stdout
  cmp eax, 0
  je std_mode_in
  jmp std_mode_out
  
  std_mode_in:
    mov eax, [ebp + 12]
    mov [echo_on], al; echo on/off
    pop ebp
    ret
  
  std_mode_out:
    mov eax, [ebp + 12]
    mov [text_color], al; textcolor
    pop ebp
    ret