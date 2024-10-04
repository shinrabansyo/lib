===

// uint8_t spi_sd_command(uint8_t cmd, uint32_t arg, uint8_t crc)

@func_sd_init
    // プロローグ
    // フレームポインタの退避
    add r2 = r2, -4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    addi r2 = r2, -4
    sw r3[-4] = r1

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
    andi r10 = r10, 0xFF // 下位8bitをマスク
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
    andi r10 = r10, 0xFFF // 下位12bitをマスク
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
    andi r10 = r10, 0xFF // 下位8bitをマスク
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
    andi r10 = r10, 0xFF // 下位8bitをマスク
    beq r0, (r10, r4) -> @acmd41.func_sd_init

    // if (R1 resp) == 0x00 : 次に進む (0x00 は「初期化完了合図」)
    addi r4 = r0, 0x00
    andi r10 = r10, 0xFF // 下位8bitをマスク
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
    andi r10 = r10, 0x40000000 // 30bit目をマスク
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
    addi r2 = r2, 4

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]
