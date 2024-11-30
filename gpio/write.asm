// 戻り値なし、引数はhighにするかlowにするかとpin番号

===
// void  gpio_write(uint32_t pin, uint32_t value)
@func_gpio_write
    // r5 = 0x10: 0001_0000
    // gpio =     0000_0000
    // -------------------- or
    //            0001_0000
    
    // r5 = 0xef: 1110_1111
    // gpio =     0001_0000
    // -------------------- and
    //            0000_0000
    
    // r4 = シフト量
    add r4 = r0, r10
    addi r5 = r0, 1


    // 書き込む値を決定
    beq r0, (r11, r0) -> @low.func_gpio_write
    beq r0, (r0, r0) -> @high.func_gpio_write
    // lowを書き込む処理
    @low.func_gpio_write
        // マスク準備
        sll r4 = r5, r4
        xori r5 = r4, 0xFFFFFFFF

        // GPIOの現在状態を取得
        in r6 = r0[4]
        
        // 現在状態にマスクをかける
        and r7 = r5, r6

        // GPIOの現在状態を更新
        out r0[4] = r7

        // return
        jal r0, r1[0]

    // highを書き込む処理
    @high.func_gpio_write
        // マスク準備
        sll r4 = r5, r4

        // GPIOの現在状態を取得
        in r6 = r0[4]
        
        // 現在状態にマスクをかける
        or r7 = r4, r6

        // GPIOの現在状態を更新
        out r0[4] = r7
    
        // return
        jal r0, r1[0]
