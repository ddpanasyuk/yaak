cursor_x: db 0
cursor_y: db 0
text_color: db 0x07
;Video memory is at 0xB8000
;---- on black text is ----
;dark blue    -> 0x01
;green		  -> 0x02
;light blue   -> 0x03
;dark red     -> 0x04
;purple       -> 0x05
;brown orange -> 0x06
;light grey   -> 0x07
;light green  -> 0x0A

;backgrounds
;0x40 -> red

k_putchar:
	push ebp
	mov ebp, esp

	mov edx, [ebp + 8] ;get char
	cmp dl, 0x0A ;0x0A = newline
	je put_newline
	cmp dl, 0x08 ;0x08 = backspace
	je put_backspace
	cmp dl, 0x09 ;0x09 = tab
	je put_tab

	;Not an escape character, so print it
	movzx eax, byte [cursor_y]
	mov edx, 80
	mul edx ;eax == y offset
	movzx edx, byte [cursor_x]
	add eax, edx ;screen offset
	shl eax, 1
	add eax, 0xB8000 ;Final address

	mov dl, [text_color]
	shl edx, 8
	mov dl, [ebp + 8] ;Get char to print

	mov [eax], dx ;put char to screen
	mov al, [cursor_x]
	cmp al, 80
	je put_newline 
	mov al, [cursor_x]
	inc al
	mov [cursor_x], al ;increment x offset
	jmp k_putchar_cleanup

put_newline:
	mov [cursor_x], byte 0 ;reset X
	mov al, [cursor_y]
	inc al
	mov [cursor_y], al ;increment y offset
	call k_scroll ;scroll if needed
	jmp k_putchar_cleanup

put_backspace:
	mov al, [cursor_x]
	cmp al, 0
	je k_putchar_cleanup
	dec al
	mov[cursor_x], al ;if not 0, decrement x offset
	jmp k_putchar_cleanup

put_tab:
	push dword ' '
	call k_putchar
	add esp, 4
	jmp k_putchar_cleanup
	
k_putchar_cleanup:
	pop ebp ; ????
	ret

k_putstr:
	push ebp
	mov ebp, esp
	push ecx
	mov ecx, [ebp + 8] ;get address of string
	xor edx, edx
check_for_null:
	mov dl, [ecx] 
	cmp dl, 0 ;check for termination byte
	je k_putstr_cleanup
	push edx
	call k_putchar ;not termination byte, print it
	pop edx
	inc ecx ;increment string pointer
	jmp check_for_null
k_putstr_cleanup:
	pop ecx
	pop ebp
	ret

k_clear:
	push ebp
	mov ebp, esp
	push ecx

	xor ecx, ecx
k_clear_loop:
	mov eax, ecx
	shl eax, 1
	add eax, 0xb8000 ;get screen position
	mov dl, [text_color]
	shl edx, 8
	add edx, 0x20
	mov [eax], dx ;blank character
	inc ecx
	cmp ecx, 2000 ;jump if not finished
	jne k_clear_loop
	mov [cursor_x], byte 0;x = 0
	mov [cursor_y], byte 0;y = 0
	pop ecx
	pop ebp
	ret

k_scroll:
	push ebp
	mov ebp, esp
	push ecx

	mov al, [cursor_y]
	cmp al, 25 ; if y == 25, scroll up
	jne k_scroll_cleanup
	xor ecx, ecx
k_scroll_loop:
	mov eax, ecx
	shl eax, 1
	add eax, 0xb8000
	mov dx, [eax + 160]
	mov [eax], dx ;character = character + 80 (one line down)
	inc ecx
	cmp ecx, 24 * 80 ;if all lines aren't scrolled up yet, go again
	jne k_scroll_loop
bottom_line_clear:
	mov eax, ecx
	shl eax, 1
	add eax, 0xb8000
	mov [eax], word 0x0020
	inc ecx
	cmp ecx, 2000 ;fill last line with spaces
	jne bottom_line_clear
	mov [cursor_y], byte 24 ;y == last line
k_scroll_cleanup:
	pop ecx
	pop ebp
	ret

k_puthex:
	push ebp
	mov ebp, esp
	
	push ecx
	mov ecx, 28
	k_puthex_loop:
		mov eax, [ebp + 8]
		shr eax, cl; get lowest byte
		and eax, 0x0F; nibble
		cmp eax, 0x0A
		jge k_puthex_letter; if 0x0A -> 0x0F
		;else
		add eax, 0x30
		jmp k_puthex_char
		k_puthex_letter:
			add eax, 0x37
			jmp k_puthex_char
		k_puthex_char:
			push eax
			call k_putchar
			add esp, 4
			cmp ecx, 0
			je k_puthex_end; if 0, end
			sub ecx, 4
			jmp k_puthex_loop
	
	k_puthex_end:
	pop ecx
	pop ebp
	ret
	