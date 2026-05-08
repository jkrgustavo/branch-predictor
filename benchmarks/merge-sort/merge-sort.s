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
        str w13, [x29, #-48]   // variadic arg, save to top of the stack

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

    bl _print_array


    done:
        ldp x29, x30, [sp], #16
        mov w0, #0
        ret



.data
    N: .word 1024

    array: .space 4096
    temp: .space 4096

.section __TEXT,__cstring
    fmt: .asciz "%d\n"
