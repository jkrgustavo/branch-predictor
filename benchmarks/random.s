.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 - lcv
    // x20 - # loops
    // x21 - rng seed
    sub sp, sp, #32
    str x19, [x29, #-8]
    str x20, [x29, #-16]
    str x21, [x29, #-24]

    mov x19, #0
    mov x20, #10
    mov x21, #0x1F45

loop:
    mov x0, x21
    bl kindaRandom
    mov x21, x0

    and x1, x21, #1     // just use the first bit

random_branch:
    cbnz x1, taken

not_taken:
    adrp x0, random_branch@PAGE
    add x0, x0, random_branch@PAGEOFF

    bl printTrace

    b after

taken:
    adrp x0, random_branch@PAGE
    add x0, x0, random_branch@PAGEOFF

    bl printTrace

after:
    add x19, x19, #1
    cmp x19, x20
    blt loop

done:
    ldr x19, [x29, #-8]
    ldr x20, [x29, #-16]
    ldr x21, [x29, #-24]
    mov sp, x29

    ldp x29, x30, [sp], #16
    mov w0, #0

    ret
