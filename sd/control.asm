===

// uint8_t func_sd_init(uint8_t cs, uint8_t clk_shamt)
@func_sd_init
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

    //////////////////////////////////////////////////////////////
    
    // 引数の保存
    add r20 = r0, r10   // cs
    add r21 = r0, r11   // clk_shamt

    //////////////////////////////////////////////////////////////
    
    // GPIO: io空間の0x04番地 32bit の値が入る
    // 0bit: GPIO0
    // 31: GPIO31
    
    // Gpio:Init
    add r10 = r0, r21
    addi r11 = r0, 1
    beq r1, (r0, r0) -> @func_gpio_write

    // Spi:Mode
    addi r4 = r0, 0
    out r0[2] = r4                  // Mode = 0

    // Spi:Clockshamt
    add r4 = r0, r11
    out r0[3] = r4                  // Clockshamt = 4
    // spiモードの初期化
    // チップセレクト

    //////////////////////////////////////////////////////////////

    // 1. 1ms待機
    addi r10 = r0, 0x01
    beq r1, (r0, r0) -> @func_wait_ms

    // 2. CS = High
    add r10 = r0, r20
    addi r11 = r0, 1
    beq r1, (r0, r0) -> @func_gpio_write

    // 3. DI = High & 74 クロック待機
    addi r4 = r0, 0
    @dummy_clk_loop.func_sd_init
        beq r0, (r4, 10) -> @dummy_clk_loop_end.func_sd_init
        addi r4 = r4, 1

        add r22 = r0, r4
        addi r10 = r0, 0xff
        beq r1, (r0, r0) -> @func_spi_transfer
        add r4 = r0, r22
    @dummy_clk_loop_end.func_sd_init

    // 4. CS = Low
    add r10 = r0, r20
    addi r11 = r0, 0
    beq r1, (r0, r0) -> @func_gpio_write

    //////////////////////////////////////////////////////////////

    // CMD0
    // arg: 0x00000000
    addi r10 = r0, 0x00 // cmd0
    addi r11 = r0, 0x00 // arg
    addi r12 = r0, 0x95 // crc
    beq r1, (r0, r0) -> @func_spi_sd_command
    // R1 resp が 0x01 であることを確認、それまでpolling
    beq r1, (r0, r0) -> @func_polling_r1_response
    addi r4 = r0, 0x01
    add r5 = r0, r10
    andi r10 = r5, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @cmd8.func_sd_init

    // 失敗ならエラーコード1
    addi r10 = r0, 0x01
    beq r0, (r0, r0) -> @epilogue.func_sd_init

    //////////////////////////////////////////////////////////////

    // CMD8
    // arg: 0x000001aa
    @cmd8.func_sd_init

    addi r10 = r0, 8    // cmd8
    addi r11 = r0, 0x000001aa // arg
    addi r12 = r0, 0x87 // crc
    beq r1, (r0, r0) -> @func_spi_sd_command
    
    // R7 resp の下位12bit が 0x1aa であることを確認
    beq r1, (r0, r0) -> @func_polling_r3_r7_response
    addi r4 = r0, 0x1aa
    add r5 = r0, 10
    andi r10 = r5, 0xFFF // 下位12bitをマスク
    beq r0, (r10, r4) -> @acmd41.func_sd_init

    // 失敗ならエラーコード2
    addi r10 = r0, 0x02
    beq r0, (r0, r0) -> @epilogue.func_sd_init

    //////////////////////////////////////////////////////////////

    // TODO: このループが1秒以上続いた場合、エラー(エラーコード5)とする処理を書く

    // ACMD41            // ACMD<n> は CMD55 と CMD<n> のコマンドシーケンス
    // arg: 0x40000000
    @acmd41.func_sd_init

    // cmd55
    addi r10 = r0, 55     // cmd55
    addi r11 = r0, 0      // arg
    addi r12 = r0, 0      // crc は cmd8までなのでテキトーで大丈夫
    beq r1, (r0, r0) -> @func_spi_sd_command

    // cmd55 の R1 レスポンス
    beq r1, (r0, r0) -> @func_polling_r1_response
    addi r4 = r0, 0x01                                  // REVIEW: 00かもしれねぇぞ
    add r5 = r0, r10
    andi r10 = r5, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @cmd41.func_sd_init

    // 失敗ならエラーコード3
    addi r10 = r0, 0x03
    beq r0, (r0, r0) -> @epilogue.func_sd_init

    // cmd41
    @cmd41.func_sd_init
    addi r10 = r0, 41            // cmd41
    addi r11 = r0, 0x40000000    // arg
    addi r12 = r0, 0             // crc は cmd8までなのでテキトーで大丈夫
    beq r1, (r0, r0) -> @func_spi_sd_command

    // cmd41 の R1 レスポンス
    beq r1, (r0, r0) -> @func_polling_r1_response

    // if (R1 resp) == 0x01 : もう一度 ACMD41 を送信 (0x01 なら初期化中)
    addi r4 = r0, 0x01
    add r5 = r0, r10
    andi r10 = r5, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @acmd41.func_sd_init

    // if (R1 resp) == 0x00 : 次に進む (0x00 は「初期化完了合図」)
    addi r4 = r0, 0x00
    add r5 = r0, r10
    andi r10 = r5, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @cmd58.func_sd_init

    // 失敗ならエラーコード4
    addi r10 = r0, 0x04
    beq r0, (r0, r0) -> @epilogue.func_sd_init

    //////////////////////////////////////////////////////////////

    // CMD58 
    // arg: 0x00000000
    @cmd58.func_sd_init
    addi r10 = r0, 58            // cmd58
    addi r11 = r0, 0             // arg
    addi r12 = r0, 0             // crc は cmd8までなのでテキトーで大丈夫
    beq r1, (r0, r0) -> @func_spi_sd_command
    
    // R3 resp の 30bit 目が 1 であることを確認（SDHC/SDXC）
    addi r4 = r0, 0x40000000
    add r5 = r0, r10
    andi r10 = r5, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @success.func_sd_init

    // 失敗ならエラーコード6
    addi r10 = r0, 0x06
    beq r0, (r0, r0) -> @epilogue.func_sd_init
    
    // SUCCESS (return 0)
    // SD Ver.2+ (Block address) であることが確定
    // 512 bytes/block
    @success.func_sd_init
    addi r10 = r0, 0
    beq r0, (r0, r0) -> @epilogue.func_sd_init

    //////////////////////////////////////////////////////////////

    // エピローグ
    @epilogue.func_sd_init
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
