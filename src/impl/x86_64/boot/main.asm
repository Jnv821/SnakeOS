global start ; make it global so we can access when trying to link.
extern long_mode_start ; The 64 bit bootloader

section .text   ; Actual code of the bootloader
bits 32         ; Everything is 32 bits before we go to 64 bits.
start:
    mov esp, stack_top
    ; Checking CPU for long mode.
    call check_multiboot
    call check_cpuid
    call check_long_mode
    ; Page tables for virtual mem
    call setup_page_tables
    call enable_paging
    ;global descriptor table
    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start


check_multiboot:
    ; Compares EAX register to the magix number. If not jump into no multiboot.
    cmp eax, 0x36d76289 ; More magic numbers for multiboot compliance >:(
    jne .no_multiboot ;
    ret
.no_multiboot:
    mov al, "M"
    jmp error


check_cpuid:
; We need to flip the bit of flag registers to check if it is a CPU we can work with.
    pushfd              ; Push Flag register onto Stack
    pop eax             ; Popping it into the eax register.
    mov ecx, eax        ; copy eax value onto ecx register 
    xor eax, 1 << 21    ; Try flipping eax register (Flags) bit 21 with XOR 
    push eax            ; copy to eax
    popfd               ; Pop it into the Flag register
    pushfd               
    pop eax             ; copy it to EAX
    push ecx            
    popfd               ; set the flag as it where since we have our value to compare on eax
    cmp eax, ecx        ; compare eax and ecx
    je  .no_cpuid       ; if they are the same jump to error since the processor flipped it back. It means it doesnt' support CPU ID
    ret
.no_cpuid:
    mov al, "C"
    jmp error

check_long_mode:
    
    mov eax, 0x80000000    ; Magic number for cpuid
    cpuid                  ; cpuid checks with that number as implicit parameter. If Ok puts a value on EAX
    cmp eax, 0x80000001    ; Compare EAX to Magic Number again, If all goes good they are not equals
    jb .no_long_mode

    mov eax, 0x80000001    ; Mov magic number in to eax to compare.
    cpuid                  ; cpuid will set edx lsb to 1 if long mode is supported
    test edx, 1 << 29      ; test lsb
    jz .no_long_mode       ; if long mode is not supported jump to error.

    ret
.no_long_mode:
    mov al, "L"
    jmp error

setup_page_tables:
    mov eax, page_table_l3
    or eax, 0b11 ; Enable present and writeable Flags
    mov [page_table_l4], eax

    ; Do the same for page_table_level_2
    mov eax, page_table_l2
    or eax, 0b11
    mov [page_table_l3], eax
    
    mov ecx, 0 ; Init of counter for exc
.loop:
    
   	mov eax, 0x200000 ; 2MiB
	mul ecx
	or eax, 0b10000011 ; present, writable, huge page
	mov [page_table_l2 + ecx * 8], eax
    
    inc ecx
    cmp ecx, 512 ; If reaches 512 page table is mapped and good to go.
    jne .loop
    
    ret


enable_paging:
    ; pass page table location
    mov eax, page_table_l4
    mov cr3, eax
    
    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5 ; set bit 5 of cr4 to 1
    mov cr4, eax

    ; Enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8 ; enable long mode flag
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31 
    mov cr0, eax
    
    ret



error: 
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

section .bss
align 4096
page_table_l4:
	resb 4096
page_table_l3:
	resb 4096
page_table_l2:
	resb 4096
stack_bottom:
	resb 4096 * 4
stack_top:

section .rodata

gdt64:
	dq 0 ; zero entry
.code_segment: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment
.pointer:
	dw $ - gdt64 - 1 ; length
	dq gdt64 ; address