===

// (uint32_t, uint32_t) func_udiv32(uint32_t a, uint32_t b)
// 戻り値1: a / b
// 戻り値2: a % b
@func_udiv32
    // a / b
    // 0 より大きければ a から b を引く
    // 引けた回数が商、残った値があまり
    
    // uint32_t count = 0;
    // while (a >= b) {
    //     a -= b;
    //     count++;
    // }
    // a: 余り
    // count: 商
    // 
    // r10: a
    // r11: b
    // r4: count

    
    add r4 = r0, r0
    @loop.func_udiv32
        blt r0, (r10, r11) -> @end.func_udiv32
        sub r10 = r10, r11
        addi r4 = r4, 1
        beq r0, (r0, r0) -> @loop.func_udiv32

    @end.func_udiv32
    add r11 = r10, r0
    add r10 = r4, r0

    // return
    jal r0, r1[0]

// (uint_32t, uint32_t, uint32_t) func_udiv64(uint64_t ah, uint64_t al, uint32_t b)
// 戻り値1: ((ah << 32)+al / b) >> 32
// 戻り値2: ((ah << 32)+al / b) & 0xFFFFFFFF
// 戻り値3: (ah << 32)+al % b
@func_udiv64
    // プロローグ
    // フレームポインタの退避
    subi r2 = r2, 4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    subi r2 = r2, 4
    sw r3[-4] = r1

    // 引数の退避
    add r20 = r10, r0
    add r21 = r11, r0
    add r22 = r12, r0
    
    // (ah * 2^32 + al) / b
    // = (ah / b) * 2^32 + (al / b)
    
    // ah / b
    add r10 = r20, r0
    add r11 = r22, r0
    beq r1, (r0, r0) -> @func_udiv32
    add r23 = r10, r0 // ah / b
    add r24 = r11, r0 // ah % b
    
    // al / b
    add r10 = r21, r0
    add r11 = r22, r0
    beq r1, (r0, r0) -> @func_udiv32
    add r25 = r10, r0 // al / b
    add r26 = r11, r0 // al % b
    
    // TODO: ((ah%b) << 32) + (al%b) がオーバーフローする問題への対処

    // エピローグ
    // 保存レジスタの復元
    lw r1 = r3[-4]
    addi r2 = r2, 4

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]
