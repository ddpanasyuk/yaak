LOAD_PROGRAM_TO equ 0x00200000

load_program:;load_program(u32int from, u32int sz)
  push ebp
  mov ebp, esp
  
  push ecx
  xor ecx, ecx
  mov eax, [ebp + 8]
  load_program_loop:
    mov dl, [eax + ecx]
    mov [ecx + LOAD_PROGRAM_TO], dl
    cmp ecx, [ebp + 12]
    je end_load_program
    inc ecx
    jmp load_program_loop
    
end_load_program:
  pop ecx
  call LOAD_PROGRAM_TO
  pop ebp
  ret