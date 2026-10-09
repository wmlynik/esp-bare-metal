ENTRY(_start)

MEMORY
{
    IRAM (rwx) : ORIGIN = 0x40370000, LENGTH = 0x50000
    DRAM (rw)  : ORIGIN = 0x3FC88000, LENGTH = 0x50000
}

/*
 * Create two actual ELF loadable segments.
 *
 * text = readable + executable
 * data = readable + writable
 */
PHDRS
{
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS
{
    /*
     * Everything in this segment is loaded by the ROM into IRAM.
     */
    .text : ALIGN(4)
    {
        _text_start = .;

        *(.literal.start)
        *(.literal .literal.*)

        KEEP(*(.text.start))
        *(.text)
        *(.text.*)

        _text_end = .;
    } > IRAM :text

    .rodata : ALIGN(4)
    {
        _rodata_start = .;

        *(.rodata)
        *(.rodata.*)

        _rodata_end = .;
    } > DRAM :text


    /*
     * This is a separate loadable segment.
     *
     * Its runtime address is DRAM.
     * The ROM loader should therefore put the initial
     * contents directly into DRAM.
     */
    .data : ALIGN(4)
    {
        _data_start = .;

        *(.data)
        *(.data.*)

        _data_end = .;
    } > DRAM :data


    /*
     * BSS has no bytes in the image.
     * We'll deal with this separately.
     */
    .bss (NOLOAD) : ALIGN(4)
    {
        _bss_start = .;

        *(.bss)
        *(.bss.*)
        *(COMMON)

        _bss_end = .;
    } > DRAM


    .stack (NOLOAD) : ALIGN(16)
    {
        stack_bottom = .;
        . += 16K;
        stack_top = .;
    } > DRAM


    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
    }
}
