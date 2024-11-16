// 戻り値なし、引数はhighにするかlowにするかとpin番号

===
// void  gpio_write(uint32_t pin, uint32_t value)
@func_gpio_write
    
    // シフト量 ピン番号-1 を計算
    add r4 = r0, r10
    subi r4 = r4, 1

    // 書き込む値を決定
    beq r0, (r11, r0) -> @zero.func_gpio_write
    addi r5 = r0, 1
    beq r0, (r0, r0) -> @zero_end.func_gpio_write
    @zero.func_gpio_write
        addi r5 = r0, 0
    @zero_end.func_gpio_write

    // マスク準備
    srl r4 = r5, r4
    xori r5 = r4, 0xFFFFFFFF

    // GPIOの現在状態を取得
    in r6 = r0[4]

    // 現在状態にマスクをかける
    and r7 = r5, r6

    // GPIOの現在状態を更新
    out r0[4] = r7

    // return
    jal r0, r1[0]
