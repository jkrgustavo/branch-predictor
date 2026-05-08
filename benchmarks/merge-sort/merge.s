.text
.global _merge
.align 2

.macro LOAD_ADDR, reg, sym
    adrp \reg, \sym@PAGE
    add \reg, \reg, \sym@PAGEOFF
.endm

.macro TRACE_BRANCH, sym, val
    stp x0, x1, [sp, #-16]!
    LOAD_ADDR x0, \sym
    mov x1, \val
    bl printTrace
    ldp x0, x1, [sp], #16
.endm

// x0 -> array ptr
// x1 -> temp array ptr
// x2 -> left idx
// x3 -> mid idx
// x4 -> right idx
_merge:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 -> array ptr
    // x20 -> temp array ptr
    // x21 -> left idx
    // x22 -> mid idx
    // x23 -> right idx
    // x24 -> i (left)
    // x25 -> j (mid)
    // x26 -> k (left)
    // x27 -> branch condition result for tracing
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!


    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4
    mov x24, x21
    mov x25, x22
    mov x26, x21

    merge_loop_compare:
        cmp x24, x22
        cset x27, ge
        TRACE_BRANCH branch_i_ge_mid, x27
        branch_i_ge_mid:
        cbnz x27, merge_loop_right      // if i >= mid, finish right array

        cmp x25, x23
        cset x27, ge
        TRACE_BRANCH branch_j_ge_right, x27
        branch_j_ge_right:
        cbnz x27, merge_loop_left       // if j >= right, finish left array

        ldr w9, [x19, x24, lsl 2]       // w9  -> array[i]
        ldr w10, [x19, x25, lsl 2]      // w10 -> array[j]
        cmp w9, w10
        cset x27, gt
        TRACE_BRANCH branch_left_gt_right, x27
        branch_left_gt_right:
        cbnz x27, greater_than

        less_than_or_equal:
            str w9, [x20, x26, lsl 2]   // temp[k] = array[i]
            add x24, x24, #1
            TRACE_BRANCH branch_lte_to_endif, #1
            branch_lte_to_endif:
            b endif_compare
            
        greater_than:
            str w10, [x20, x26, lsl 2]  // temp[k] = array[j]
            add x25, x25, #1
            TRACE_BRANCH branch_gt_to_endif, #1
            branch_gt_to_endif:
            b endif_compare

        endif_compare:
            add x26, x26, #1
            TRACE_BRANCH branch_endif_to_compare, #1
            branch_endif_to_compare:
            b merge_loop_compare

    merge_loop_left:
        cmp x24, x22
        cset x27, ge
        TRACE_BRANCH branch_left_done, x27
        branch_left_done:
        cbnz x27, done_merge

        ldr w9, [x19, x24, lsl 2]
        str w9, [x20, x26, lsl 2]

        add x24, x24, #1
        add x26, x26, #1

        TRACE_BRANCH branch_left_loop, #1
        branch_left_loop:
        b merge_loop_left

    merge_loop_right:
        cmp x25, x23
        cset x27, ge
        TRACE_BRANCH branch_right_done, x27
        branch_right_done:
        cbnz x27, done_merge

        ldr w10, [x19, x25, lsl 2]
        str w10, [x20, x26, lsl 2]

        add x25, x25, #1
        add x26, x26, #1

        TRACE_BRANCH branch_right_loop, #1
        branch_right_loop:
        b merge_loop_right

done_merge:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret
