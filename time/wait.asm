===

// void wait_ms(uint32_t ms)
// ms ミリ秒待つ
@func_wait_ms
    // プロローグ
    // フレームポインタの退避
    subi r2 = r2, 4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    subi r2 = r2, 16
    sw r3[-4] = r1
    sw r3[-8] = r20
    sw r3[-12] = r21
    sw r3[-16] = r22

    // 引数の保存
    add r22 = r0, r10

    // 初期時間
    in r20 = r0[0x1003]
    in r21 = r0[0x1004]
    
    // 毎ループ時間を取得して差を取る
    // -> 差が r10 より大きければループを終了
    // -> そうでなければ継続
    @loop.func_wait_ms
        in r10 = r0[0x1003]
        in r11 = r0[0x1004]
    
        add r12 = r20, r0
        add r13 = r21, r0
    
        beq r1, (r0, r0) -> @func_sub64

        // 上位32bit が 1 以上ならループ終了
        ble r0, (r0, r11) -> @end.func_wait_ms
        // 上位32bit が 0 なら下位32bit の比較を行う
        // 現在時間 - 初期時間 < r22 ならループ継続
        blt r0, (r10, r22) -> @loop.func_wait_ms
        // 現在時間 - 初期時間 >= r22 ならループ終了
        beq r0, (r0, r0) -> @end.func_wait_ms
        
    @end.func_wait_ms
    
    // エピローグ
    // 保存レジスタの復元
    lw r1 = r3[-4]
    lw r20 = r3[-8]
    lw r21 = r3[-12]
    lw r22 = r3[-16]
    addi r2 = r2, 16

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]
