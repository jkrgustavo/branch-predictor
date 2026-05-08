.text
.global _main
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

_init_array:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x9 -> array addr
    // x10 -> array size
    // x11 -> curr elm ptr
    // x12 -> arr end ptr
    // x13 -> "random" value
    // x14-x16 -> mod 1000
    LOAD_ADDR x9, array

    LOAD_ADDR x10, N
    ldr w10, [x10]

    mov x11, x9
    add x12, x9, x10, lsl #2
    mov x13, #13
    
    // reserve space on the stack
    // most of it doesn't need to be updated. x13 is just the initial seed, reg 
    // itself isn't needed after just the stack addr. 
    sub sp, sp, #48
    str x9,  [x29, #-8]
    str w10, [x29, #-16]
    str x11, [x29, #-24]    // will be overwritten
    str x12, [x29, #-32]
    str x13, [x29, #-40]

    loop_init_array:
        cmp x11, x12
        bge done_init_array

        str x11, [x29, #-24]    // store curr elm ptr in case of clobbering
                                // no need to save end ptr bc it never changes

        ldr x0, [x29, #-40]     // load seed
        bl kindaRandom
        str x0, [x29, #-40]     // save seed

        // use seed to calc val [0, 1000]
        mov x14, #1001
        udiv x15, x0, x14
        msub x16, x15, x14, x0  // x16 = x0 % 1001

        // reload curr elm ptr and end ptr 
        ldr x11, [x29, #-24]
        ldr x12, [x29, #-32]

        str w16, [x11]      // store rand value, use w reg because arr stores 32-bit ints

        add x11, x11, #4    // incr curr elm

        b loop_init_array

    done_init_array:
        add sp, sp, #48     // de-init stack
        ldp x29, x30, [sp], #16
        ret

_print_array:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x9 -> array addr
    // w10 -> array size
    // x11 -> curr elm ptr
    // x12 -> arr end ptr
    // x13-x14 -> print-scratch
    LOAD_ADDR x9, array

    LOAD_ADDR x10, N
    ldr w10, [x10]

    mov x11, x9
    add x12, x9, x10, lsl #2
    mov x13, #-1

    sub sp, sp, #48
    str x9,  [x29, #-8]
    str w10, [x29, #-16]
    str x11, [x29, #-24]    // will be overwritten
    str x12, [x29, #-32]
    str x13, [x29, #-48]    // variadic arg to printf, saved at -48 bc it should be at
                            // [sp] and stack must be 16byte aligned

    loop_print_array:
        cmp x11, x12
        bge done_print_array

        str x11, [x29, #-24]    // save curr-elm ptr

        ldr w13, [x11]
        sxtw x13, w13
        str x13, [x29, #-48]   // variadic arg, save to top of the stack

        LOAD_ADDR x0, fmt       // named arg, stays in x0

        bl _printf

        ldr x11, [x29, #-24]
        ldr x12, [x29, #-32]

        add x11, x11, #4

        b loop_print_array

    done_print_array:
        add sp, sp, #48
        ldp x29, x30, [sp], #16

        ret


_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _init_array    // init array with vals [0, 1000]

    bl _merge_sort

    done:
        ldp x29, x30, [sp], #16
        mov w0, #0
        ret

_merge_sort:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // x19 -> array ptr
    // x20 -> temp array ptr
    // x21 -> array size
    // x22 -> width
    // x23 -> left idx
    // x24 -> mid idx
    // x25 -> right idx
    // x26-x28 -> scratch
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    LOAD_ADDR x19, array
    LOAD_ADDR x20, temp

    LOAD_ADDR x21, N
    ldr w21, [x21]

    mov x22, #1

    loop_merge_sort:
        cmp x22, x21
        cset x28, ge
        TRACE_BRANCH branch_width_ge_n, x28
        branch_width_ge_n:
        cbnz x28, done_merge_sort

        mov x23, #0

        inner_loop_merge_sort:
            cmp x23, x21
            cset x28, ge
            TRACE_BRANCH branch_left_ge_n, x28
            branch_left_ge_n:
            cbnz x28, inner_loop_merge_sort_done

            add x26, x23, x22
            cmp x26, x21
            csel x24, x26, x21, lt

            mov x27, #2
            madd x25, x22, x27, x23
            cmp x25, x21
            csel x25, x25, x21, lt
            
            mov x0, x19
            mov x1, x20
            mov x2, x23
            mov x3, x24
            mov x4, x25
            bl _merge

            lsl x26, x22, #1
            add x23, x23, x26
            
            TRACE_BRANCH branch_continue_inner_merge_sort, #1
            branch_continue_inner_merge_sort:
            b inner_loop_merge_sort

    inner_loop_merge_sort_done:

        mov x26, #0     // array idx
        copy_loop:
            cmp x26, x21
            cset x28, ge
            TRACE_BRANCH branch_copy_idx_ge_n, x28
            branch_copy_idx_ge_n:
            cbnz x28, copy_loop_done

            ldr w27, [x20, x26, lsl 2]
            str w27, [x19, x26, lsl 2]

            add x26, x26, #1

            TRACE_BRANCH branch_continue_copy_loop, #1
            branch_continue_copy_loop:
            b copy_loop

        copy_loop_done:

        lsl x22, x22, #1
        TRACE_BRANCH branch_continue_outer_merge_sort, #1
        branch_continue_outer_merge_sort:
        b loop_merge_sort

done_merge_sort:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16

    ret

.data
    N: .word 1024

    array: .space 4096
    temp: .space 4096

.section __TEXT,__cstring
    fmt: .asciz "%d, "
