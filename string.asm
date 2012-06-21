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
    
  
  