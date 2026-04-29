.text
.global kindaRandom
.align 2

// arg x0 is old state, must not be 0
// ret x0 new state
kindaRandom:
    eor x0, x0, x0, lsl #13
    eor x0, x0, x0, lsl #7
    eor x0, x0, x0, lsl #17
    ret
