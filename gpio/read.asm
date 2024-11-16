// pin番号の決定、読み取ってシフトして返すだけっ

===
// uint32_t  gpio_read(uint32_t pin, uint32_t value)
@func_gpio_read
     
    // GPIOの現在状態を取得
    in r6 = r0[4]

    // シフト量 ピン番号-1 を計算
    add r4 = r0, r10
    subi r4 = r4, 1

    // ピン番号の位置のビットを取得
    srl r10 = r6, r4
    addi r7 = r0, 1
    and r10 = r10, r7

    // return
    jal r0, r1[0]
