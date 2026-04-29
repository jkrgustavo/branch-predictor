.text
.global printTrace
.align 2

// x0 is the address
// x1 is 0 if branch isn't taken, 1 otherwise

printTrace:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    stp x0, x1, [sp, #-16]! // printf is variadic, so x0 and x1 must be on the stack

    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF

    bl _printf

    add sp, sp, 16  // dealloc printf args
    ldp x29, x30, [sp], #16
    ret

.section __TEXT,__cstring
fmt:
    .asciz "%p %d\n"
