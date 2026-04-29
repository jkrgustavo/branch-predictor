.text
.global _main
.align 2

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    str x19, [sp, #-16]!    // save x19, stack must be 16 byte aligned
    mov x19, #0

loop_test:
    cmp x19, #10
loop_branch:
    bge taken   // break from loop
    
// loop body
not_taken:
    adrp x0, loop_branch@PAGE
    add x0, x0, loop_branch@PAGEOFF
    mov x1, #0

    bl printTrace

    add x19, x19, #1

    b loop_test

taken:
    adrp x0, loop_branch@PAGE
    add x0, x0, loop_branch@PAGEOFF
    mov x1, #1

    bl printTrace

done:
    ldr x19, [sp], #16      // restore x19 and update sp
    ldp x29, x30, [sp], #16     // restore fp and lr

    mov w0, #0

    ret
