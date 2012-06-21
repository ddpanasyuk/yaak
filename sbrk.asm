k_sbrk: ;sbrk(int sz)
	push ebp
	mov ebp, esp
	
	mov eax, [ebp + 8]
	mov edx, [current_endpoint]
	mov dword [last_endpoint], edx
	add dword [current_endpoint], eax
	mov eax, [last_endpoint];adds memory and returns allocated address
	pop ebp
	ret
	
last_endpoint:   dd 0
current_endpoint:dd end_point
end_point: ;previous endpoint, current endpoint, last address of the program