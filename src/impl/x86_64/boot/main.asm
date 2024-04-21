global start ; make it global so we can access when trying to link.

section .text   ; Actual code of the bootloader
bits 32         ; Everything is 32 bits before we go to 64 bits.

start:
    ; Print OK chars to see if it works. 0x2f4b2f4f = OK
    mov dword [0xb8000], 0x2f4b2f4e
    hlt

