.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp


    // x19 - lcv
    // x20 - # iterations
    // x21 - whether to branch
    // x22 x23 - scratch
    sub sp, sp, #48
    str x19, [x29, #-8]
    str x20, [x29, #-16]
    str x21, [x29, #-24]
    str x22, [x29, #-32]
    str x23, [x29, #-40]

    mov x19, #0
    mov x20, #1000

loop:
    // x21 = x19 % 6
    mov x22, #75
    udiv x23, x19, x22
    msub x21, x23, x22, x19

    cmp x21, #1

biased_branch:
    beq taken

not_taken:
    adrp x0, biased_branch@PAGE
    add x0, x0, biased_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after

taken:
    adrp x0, biased_branch@PAGE
    add x0, x0, biased_branch@PAGEOFF
    mov x1, #1

    bl printTrace

after:
    add x19, x19, #1
    cmp x19, x20
    blt loop

done:
    ldr x19, [x29, #-8]
    ldr x20, [x29, #-16]
    ldr x21, [x29, #-24]
    ldr x22, [x29, #-32]
    ldr x23, [x29, #-40]
    mov sp, x29

    ldp x29, x30, [sp], #16

    mov w0, #0

    ret
