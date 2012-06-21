gdt_table:
dd 0 ;first entry is null
dd 0 ;null
dw 0xffff ;next entry, code selector
dw 0
db 0
db 10011010b; Access byte
db 11001111b; Flags / limit
db 0
dw 0xffff ;next entry, data selector
dw 0
db 0
db 10010010b; Access byte
db 11001111b; Flags / limit
db 0
gdt_end:
gdt_ptr:
dw gdt_end - gdt_table -1; size - 1
dd gdt_table

%macro ISR 1
	isr_%1:
	cli
	push dword %1
	jmp handle_isr
%endmacro

%macro IRQ 2
	irq_%1:
	cli
	push dword %2
	jmp handle_irq
%endmacro

idt_table:
times 8 * 256 db 0

idt_ptr:
dw 8 * 256 - 1
dd idt_table

ISR 0
ISR 1
ISR 2
ISR 3
ISR 4
ISR 5
ISR 6
ISR 7
ISR 8
ISR 9
ISR 10
ISR 11
ISR 12
ISR 13
ISR 14
ISR 15
ISR 16
ISR 17
ISR 18
ISR 19
ISR 20
ISR 21
ISR 22
ISR 23
ISR 24
ISR 25
ISR 26
ISR 27
ISR 28
ISR 29
ISR 30
ISR 31
IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47
ISR 48

isr_addr_table:
dd isr_0
dd isr_1
dd isr_2
dd isr_3
dd isr_4
dd isr_5
dd isr_6
dd isr_7
dd isr_8
dd isr_9
dd isr_10
dd isr_11
dd isr_12
dd isr_13
dd isr_14
dd isr_15
dd isr_16
dd isr_17
dd isr_18
dd isr_19
dd isr_20
dd isr_21
dd isr_22
dd isr_23
dd isr_24
dd isr_25
dd isr_26
dd isr_27
dd isr_28
dd isr_29
dd isr_30
dd isr_31
dd irq_0
dd irq_1
dd irq_2
dd irq_3
dd irq_4
dd irq_5
dd irq_6
dd irq_7
dd irq_8
dd irq_9
dd irq_10
dd irq_11
dd irq_12
dd irq_13
dd irq_14
dd irq_15
dd isr_48
isr_addr_table_end:
times 256 * 4 - (isr_addr_table_end - isr_addr_table) db 0

interrupt_call_table:
times 256 * 4 db 0