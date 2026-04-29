.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 is lcv
    // x20 is # iterations
    // x21 decides which branch
    stp x19, x20, [sp, #-16]!
    sub sp, sp, #16
    str x21, [sp]

    mov x19, #0     // loop control
    mov x20, #10    // num iterations

loop:
    and x21, x19, #1
    cmp x21, #0

altern_branch:
    beq taken

not_taken:
    adrp x0, altern_branch@PAGE
    add x0, x0, altern_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after

taken:
    adrp x0, altern_branch@PAGE
    add x0, x0, altern_branch@PAGEOFF
    mov x1, #1

    bl printTrace

after:
    add x19, x19, #1
    cmp x19, x20
    blt loop

done:
    ldr x21, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    mov w0, #0

    ret
