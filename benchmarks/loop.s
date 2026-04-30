.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 - lcv
    // x20 - # loops
    stp x19, x20, [sp, #-16]!

    mov x19, #0
    mov x20, #1000

    b loop

loop_print:
    adrp x0, loop_branch@PAGE
    add x0, x0, loop_branch@PAGEOFF

    mov x1, #1

    bl printTrace

loop:
    add x19, x19, #1
    cmp x19, x20

loop_branch:
    blt loop_print

done:
    adrp x0, loop_branch@PAGE
    add x0, x0, loop_branch@PAGEOFF

    mov x1, #0

    bl printTrace

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    mov w0, #0

    ret
