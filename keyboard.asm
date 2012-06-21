KEY_REL equ 0x80
r_shift: db 0
l_shift: db 0
echo_on: db 1; is echo turned on?
key_new: db 0; is there a key waiting for the program?
key_buffer:  db 0


start_keyboard:
	push handle_keyboard
	mov eax, 33
	push eax
	call add_isr
	add esp, 8
	ret
	
handle_keyboard:
	xor eax, eax
	xor edx, edx
	in al, 0x60; get scancode
	mov dl, al
	and dl, 0x80
	cmp dl, 0x80
	je handle_key_release; released key
	; pressed key
	cmp al, 0x36; right shift
	je handle_rshift_press
	cmp al, 0x2A; left shift
	je handle_lshift_press
	cmp byte[r_shift], 1
	je key_shift
	cmp byte[l_shift], 1
	je key_shift
	key_noshift:
		add eax, keyboard_table_us
		jmp key_print
	key_shift:
		add eax, keyboard_table_us_shift
		jmp key_print
	key_print:
		mov dl, [eax]
		cmp dl, 0
		je handle_key_end;invalid byte
		cmp byte [echo_on], 1
		jne handle_key_buff; if no echo, skip to writing to buffer
		push edx
		call k_putchar; print if echo
		add esp,4
	handle_key_buff:
		mov [key_buffer], dl
		mov byte[key_new], 1
		jmp handle_key_end
	handle_rshift_press:
		mov byte[r_shift], 1
		jmp handle_key_end
	handle_lshift_press:
		mov byte[l_shift], 1
		jmp handle_key_end
	handle_key_release:
		cmp al, 0xB6; right shift
		je handle_rshift_release
		cmp al, 0xAA; left shift
		je handle_lshift_release
		jmp handle_key_end
	handle_rshift_release:
		mov byte[r_shift], 0
		jmp handle_key_end
	handle_lshift_release:
		mov byte[l_shift], 0
		jmp handle_key_end
	handle_key_end:
		ret	
		
k_getchar:
	k_getchar_wait:
	cmp byte[key_new], 1
	je key_getchar_ret
	jmp k_getchar_wait
	key_getchar_ret:
	mov byte[key_new], 0
	xor eax, eax
	mov al, byte[key_buffer]
	ret

;kbdus_jmp:; 0 = print character, 
;dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,
;dd handle_key_backspace, handle_key_tab
;dd 0,0,0,0,0,0,0,0,0,0,0,0,
;dd handle_key_enter, handle_key_ctrl
;dd 0,0,0,0,0,0,0,0,0,0,0,0,
;dd handle_key_lshift
;dd 0,0,0,0,0,0,0,0
;dd handle_key_rshift
;dd 0
;dd handle_key_alt
;dd 0
;dd handle_key_caps
;dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
keyboard_table_us:
db 0, 27,"1234567890-="
db 0x08, 0x09
db "qwertyuiop[]"
db 0x0A, 0
db "asdfghjkl;"
db "'", '`', 0, "\"
db "zxcvbnm,."
db 0x2F, 0
db '*', 0 , ' '
db 0  ; caps lock
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
db 0, 0, 0, 0, 0
db '-'
db 0, 0, 0
db '+'
db 0,0,0,0,0,0,0,0,0,0,0

keyboard_table_us_shift:
db 0, 27
db "!@#$%^&*()_+"
db 0, 0
db "QWERTYUIOP{}"
db 0, 0
db "ASDFGHJKL:"
db '"', '~', 0
db "|ZXCVBNM<>?", 0
db 0, 0, ' '
db 0,0,0, 0, 0, 0, 0, 0, 0, 0
db 0, 0, 0, 0, 0,
db '_'
db 0, 0, 0
db '+'
db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0