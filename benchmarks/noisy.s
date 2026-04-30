.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 - outer counter
    // x20 - outer limit
    // x21 - middle counter
    // x22 - middle limit
    // x23 - inner counter
    // x24 - inner limit
    // x25 - random seed
    // x26 - extra scratch, keeps 16-byte alignment
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, #0
    mov x20, #20
    mov x25, #0x1F45

outer_loop:
    mov x21, #0
    mov x22, #8

    // branch 1 - biased branch
    // taken 7 times, not taken once, repeating
    // uses outer counter % 8

    mov x9, #8
    udiv x10, x19, x9
    msub x11, x10, x9, x19   // x11 = x19 % 8

    cmp x11, #7

biased_branch:
    bne biased_taken         // taken when x19 % 8 != 7

biased_not_taken:
    adrp x0, biased_branch@PAGE
    add x0, x0, biased_branch@PAGEOFF
    mov x1, #0
    bl printTrace

    b after_biased

biased_taken:
    adrp x0, biased_branch@PAGE
    add x0, x0, biased_branch@PAGEOFF
    mov x1, #1
    bl printTrace

after_biased:

middle_loop:
    mov x23, #0
    mov x24, #6

    // branch 2 - alternating branch
    // changes with middle counter based on whether it's even or odd
    // taken if even, otherwise not taken

    and x9, x21, #1
    cmp x9, #0

alternating_branch:
    beq alternating_taken

alternating_not_taken:
    adrp x0, alternating_branch@PAGE
    add x0, x0, alternating_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after_alternating

alternating_taken:
    adrp x0, alternating_branch@PAGE
    add x0, x0, alternating_branch@PAGEOFF
    mov x1, #1

    bl printTrace

after_alternating:

inner_loop:
    // branch 3 - random-ish branch
    // updates x25 as the seed, then branches on one bit

    mov x0, x25
    bl kindaRandom
    mov x25, x0

    // use bit 4 instead of bit 0
    and x9, x25, #16
    cmp x9, #0

random_branch:
    bne random_taken

random_not_taken:
    adrp x0, random_branch@PAGE
    add x0, x0, random_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after_random

random_taken:
    adrp x0, random_branch@PAGE
    add x0, x0, random_branch@PAGEOFF
    mov x1, #1

    bl printTrace

after_random:
    add x23, x23, #1
    cmp x23, x24
    blt inner_loop

    add x21, x21, #1
    cmp x21, x22
    blt middle_loop

    add x19, x19, #1
    cmp x19, x20
    blt outer_loop

done:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    mov w0, #0
    ret
