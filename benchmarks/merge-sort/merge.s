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
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    # sub sp, sp, #64
    # str x19, [x29, #-8]
    # str x20, [x29, #-16]
    # str x21, [x29, #-24]
    # str x22, [x29, #-32]
    # str x23, [x29, #-40]
    # str x24, [x29, #-48]
    # str x25, [x29, #-56]
    # str x26, [x29, #-64]

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
        bge merge_loop_right            // if i >= mid, finish right array

        cmp x25, x23
        bge merge_loop_left             // if j >= right, finish left array

        ldr w9, [x19, x24, lsl 2]       // w9  -> array[i]
        ldr w10, [x19, x25, lsl 2]      // w10 -> array[j]
        cmp w9, w10
        bgt greater_than

        less_than_or_equal:
            str w9, [x20, x26, lsl 2]   // temp[k] = array[i]
            add x24, x24, #1
            b endif_compare
            
        greater_than:
            str w10, [x20, x26, lsl 2]  // temp[k] = array[j]
            add x25, x25, #1
            b endif_compare

        endif_compare:
            add x26, x26, #1
            b merge_loop_compare

    merge_loop_left:
        cmp x24, x22
        bge done_merge

        ldr w9, [x19, x24, lsl 2]
        str w9, [x20, x26, lsl 2]

        add x24, x24, #1
        add x26, x26, #1

        b merge_loop_left

    merge_loop_right:
        cmp x25, x23
        bge done_merge

        ldr w10, [x19, x25, lsl 2]
        str w10, [x20, x26, lsl 2]

        add x25, x25, #1
        add x26, x26, #1

        b merge_loop_right

done_merge:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret
