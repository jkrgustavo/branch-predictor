.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 - lcv
    // x20 - # loops
    // x21 - rng seed
    // x22 - extra scratch for 16-byte alignment
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, #0
    mov x20, #1000
    mov x21, #0x1F45

loop:
    mov x0, x21
    bl kindaRandom
    mov x21, x0

    and x1, x21, #16     // shared condition bit

conditional_branch_1:
    cbnz x1, if_taken_1

branch_1_not_taken:
    adrp x0, conditional_branch_1@PAGE
    add x0, x0, conditional_branch_1@PAGEOFF
    mov x1, #0

    bl printTrace

    b test_branch_2

if_taken_1:
    adrp x0, conditional_branch_1@PAGE
    add x0, x0, conditional_branch_1@PAGEOFF
    mov x1, #1

    bl printTrace

test_branch_2:
    // Recompute condition
    and x1, x21, #16

conditional_branch_2:
    cbz x1, if_taken_2       // opposite of branch 1

branch_2_not_taken:
    adrp x0, conditional_branch_2@PAGE
    add x0, x0, conditional_branch_2@PAGEOFF
    mov x1, #0
    bl printTrace

    b after

if_taken_2:
    adrp x0, conditional_branch_2@PAGE
    add x0, x0, conditional_branch_2@PAGEOFF
    mov x1, #1
    bl printTrace

    b after

after:
    add x19, x19, #1
    cmp x19, x20
    blt loop

done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    mov w0, #0
    ret
