; Define idt_flush function
global idt_flush
idt_flush:
    mov rax, qword [rsp + 8]  ; Load the address of the IDT from the stack (first argument)
    lidt [rax]                ; Load the interrupt descriptor table (IDT) from the given address
    sti                       ; Enable interrupts
    ret                       ; Return from the function

; Macro for ISR without error code
%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        cli
        push rax                ; Save a placeholder for error code (0)
        push qword %1           ; Push the interrupt number
        jmp isr_common_stub
%endmacro

; Macro for ISR with error code
%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        cli
        push qword %1           ; Push the error code
        jmp isr_common_stub
%endmacro

; Macro for IRQ
%macro IRQ 2
    global irq%1
    irq%1:
        cli
        push rax                ; Save a placeholder for error code (0)
        push qword %2           ; Push the interrupt number
        jmp irq_common_stub
%endmacro

ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE 8
ISR_NOERRCODE 9 
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31
ISR_NOERRCODE 128
ISR_NOERRCODE 177
IRQ 0, 32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47

; Define isr_common_stub for ISR handling
extern isr_handler
isr_common_stub:
    push rax                    ; Save registers
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push rsp
    mov rax, ds                 ; Save ds
    push rax
    mov rax, cr2                ; Save cr2
    push rax
    mov rbx, 0x10               ; Set data segment to 0x10 (kernel data segment)
    mov ds, rbx
    mov es, rbx
    mov fs, rbx
    mov gs, rbx
    call isr_handler            ; Call ISR handler
    add rsp, 8                  ; Clean up stack after handler call
    pop rbx                     ; Restore original ds from stack
    mov ds, rbx                 ; Restore ds
    mov es, rbx                 ; Restore es
    mov fs, rbx                 ; Restore fs
    mov gs, rbx                 ; Restore gs
    pop rsp                     ; Restore rsp
    pop rbp                     ; Restore rbp
    pop rdi                     ; Restore rdi
    pop rsi                     ; Restore rsi
    pop rdx                     ; Restore rdx
    pop rcx                     ; Restore rcx
    pop rbx                     ; Restore rbx
    pop rax                     ; Restore rax
    sti                         ; Enable interrupts
    iret                        ; Return from interrupt

; Define irq_common_stub for IRQ handling
extern irq_handler
irq_common_stub:
    push rax                    ; Save registers
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push rsp
    mov rax, ds                 ; Save ds
    push rax
    mov rax, cr2                ; Save cr2
    push rax
    mov rbx, 0x10               ; Set data segment to 0x10 (kernel data segment)
    mov ds, rbx
    mov es, rbx
    mov fs, rbx
    mov gs, rbx
    call irq_handler            ; Call IRQ handler
    add rsp, 8                  ; Clean up stack after handler call
    pop rbx                     ; Restore original ds from stack
    mov ds, rbx                 ; Restore ds
    mov es, rbx                 ; Restore es
    mov fs, rbx                 ; Restore fs
    mov gs, rbx                 ; Restore gs
    pop rsp                     ; Restore rsp
    pop rbp                     ; Restore rbp
    pop rdi                     ; Restore rdi
    pop rsi                     ; Restore rsi
    pop rdx                     ; Restore rdx
    pop rcx                     ; Restore rcx
    pop rbx                     ; Restore rbx
    pop rax                     ; Restore rax
    sti                         ; Enable interrupts
    iret                        ; Return from interrupt
