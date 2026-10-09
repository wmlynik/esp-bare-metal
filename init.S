.section .text.start
.global _start
.type _start, @function

_start:
    movi    a1, stack_top

    movi    a2, _bss_start
    movi    a3, _bss_end
    movi    a4, 0

zero_bss:
    beq     a2, a3, bss_done

    s32i    a4, a2, 0

    addi    a2, a2, 4
    j       zero_bss

bss_done:
    call0   main

1:
    j       1b
