file_sys_famount: dd 0
file_sys_location: dd 0
file_sys_curr_offset: dd 0

file_amount_msg: db " files found in directory /", 0x0A, 0
file_found_msg:  db "Found file ", 0
file_size_msg:   db " bytes in size.", 0x0A, 0

file_sys_parse:;file_sys_parse(u32int addr)
  push ebp
  mov ebp, esp
  
  mov eax, [ebp + 8]
  mov [file_sys_location], eax
  
  mov edx, [eax]
  add eax, 4; first file offset
  mov [file_sys_curr_offset], eax
  
  mov [file_sys_famount], edx;move address and amount to global vars
  
  push dword [file_sys_famount]
  call k_puthex
  add esp, 4
  
  push file_amount_msg
  call k_putstr
  add esp, 4
  
  xor ecx, ecx
  push ecx; counter
  push ebx; pointer
  file_parse_loop:
  
    cmp ecx, [file_sys_famount]
    je file_parse_end
    
    inc ecx
  
    push file_found_msg
    call k_putstr
    add esp, 4
    
    mov edx, [file_sys_curr_offset]
    add edx, 4; string
    push edx
    call k_putstr
    add esp,4
    
    push dword ' '
    call k_putchar
    add esp, 4
    
    mov ebx, [file_sys_curr_offset]
    push dword [ebx]
    call k_puthex
    add esp,4
    
    push file_size_msg
    call k_putstr
    add esp, 4
    
    mov edx, [file_sys_curr_offset]
    mov ebx, [edx]
    add ebx, 16
    
    add [file_sys_curr_offset], ebx
    
    jmp file_parse_loop

file_parse_end:
    pop ebx
    pop ecx
    pop ebp
    ret
    
k_open:
  

k_close:
  ret  
;struct FILE (RAM)
;u32int size
;u32int address
;u32int current_offset
;u32int attrib
;char name[12]
  
  
  