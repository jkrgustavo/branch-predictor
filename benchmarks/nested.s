.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Save callee-saved registers we use
    // x19 - outer lcv
    // x20 - outer num loops
    // x21 - middle lcv
    // x22 - middle num loops
    // x23 - inner lcv
    // x24 - inner num loops
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, #0
    mov x20, #10

outer_loop:
    mov x21, #0
    mov x22, #10

middle_loop:
    mov x23, #0
    mov x24, #10

inner_loop:
    add x23, x23, #1
    cmp x23, x24

inner_branch:
    blt inner_branch_taken

inner_branch_not_taken:
    adrp x0, inner_branch@PAGE
    add x0, x0, inner_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after_inner_loop

inner_branch_taken:
    adrp x0, inner_branch@PAGE
    add x0, x0, inner_branch@PAGEOFF
    mov x1, #1

    bl printTrace

    b inner_loop

after_inner_loop:
    add x21, x21, #1
    cmp x21, x22

middle_branch:
    blt middle_branch_taken

middle_branch_not_taken:
    adrp x0, middle_branch@PAGE
    add x0, x0, middle_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b after_middle_loop

middle_branch_taken:
    adrp x0, middle_branch@PAGE
    add x0, x0, middle_branch@PAGEOFF
    mov x1, #1

    bl printTrace

    b middle_loop

after_middle_loop:
    add x19, x19, #1
    cmp x19, x20

outer_branch:
    blt outer_branch_taken

outer_branch_not_taken:
    adrp x0, outer_branch@PAGE
    add x0, x0, outer_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    b done

outer_branch_taken:
    adrp x0, outer_branch@PAGE
    add x0, x0, outer_branch@PAGEOFF
    mov x1, #1

    bl printTrace

    b outer_loop

done:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    mov w0, #0

    ret
