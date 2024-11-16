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
