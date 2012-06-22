strcmp: ;strcmp(char* str1, char* str2)
  push ebp
  mov ebp, esp
  
  mov eax, [ebp + 8]
  mov edx, [ebp + 12]
  
  push ebx
  push ecx
  xor ecx, ecx
  xor ebx, ebx
  strcmp_loop:
    mov bl, [eax + ecx]
    cmp bl, 0
    je strcmp_equ
    
    cmp bl, [edx + ecx]
    jne strcmp_neg
    inc ecx
    jmp strcmp_loop
    
    strcmp_neg:
      pop ecx
      pop ebx
      pop ebp
      mov eax, 1
      ret
    strcmp_equ:
      pop ecx
      pop ebx
      pop ebp
      mov eax, 0
      ret

memcpy: ;memcpy(u32int to, u32int from, u32int sz)
  push ebp
  mov ebp, esp
  
  push ebx
  xor ecx, ecx
  mov eax, [ebp + 8]
  mov edx, [ebp + 12]
  memcpy_loop:
    cmp ecx, [ebp + 16]
    je memcpy_end
    mov bl, [eax + ecx]
    mov [edx + ecx], bl
    
    jmp memcpy_loop
    
memcpy_end:
  pop ebx
  pop ebp
  ret