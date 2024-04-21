; Multiboot2 Specs
section .multiboot_header
header_start:

    dd 0xE85250D6                   ; magic multiboot numbers :D
    dd 0                            ; protected mode of i386. Serves for backwards compatibility. 
    dd header_end - header_start    ; header_length
    
    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; End tag. The end tag is a b
    dd 0    ; type
    dd 0    ; flags
    dw 8    ; size
header_end: