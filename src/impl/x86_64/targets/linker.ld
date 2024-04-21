ENTRY(start) /*The entry point defined as global in main.asm*/

SECTIONS
{
    . = 1M; /*We start our OS at 1M*/

    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    .text :
    {
        *(.text)
    }
}