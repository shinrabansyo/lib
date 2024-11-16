===

// (uint32_t, uint32_t) sub64(uint64_t ah, uint64_t al, uint64_t bh, uint64_t bl)
@func_sub64
    // return a - b
    // r10 = al, r11 = ah, r12 = bl, r13 = bh
    
    // 繰り下がりが発生したかを確認
    blt r0, (r10, r12) -> @borrow.func_sub64

    // 繰り下がりが発生しないならそのまま引き算
    sub r10 = r10, r12
    sub r11 = r11, r13
    
    // 早期リターン
    jal r0, r1[0]

    // 繰り下がりが発生
    @borrow.func_sub64
    // 下位はそのまま引き算
    sub r10 = r10, r12
    // 上位はそのまま引き算ののち -1
    sub r11 = r11, r13
    addi r4 = r0, 1
    sub r11 = r11, r4

    // return 
    jal r0, r1[0]
