===
    
// uint32_t single_block_read(uint32_t block_addr, uint8_t *buffer)
// success: return 0
// fail: return 1
@func_single_block_read

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
    
    add r20 = r0, r10
    add r21 = r0, r11
    
    addi r10 = r0, 17  // cmd17
    addi r11 = r0, r20 // arg = block_addr
    addi r12 = r0, 0   // crc テキトー
    
    beq r1, (r0, r0) -> @func_spi_sd_command
    beq r1, (r0, r0) -> @func_polling_r1_response
    
    addi r4 = r0, 5
    srl r4 = r10, r4   // Address Error フィールドを取得
    andi r4 = r4, 1
    bne r0, (r4, r0) -> @address_error.func_single_block_read
    
    // data token を待つ
    beq r1, (r0, r0) -> @func_polling_data_token_for_cmd17_18_24

    // バッファに書き込み
    add r22 = r0, r0
    @store_loop.func_single_block_read
    addi r4 = r0, 512
    beq r0, (r22, r4) -> @store_loop_end.func_single_block_read
    
    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    
    add r5 = r0, r21
    sb r5[0] = r10

    addi r4 = r0, 1
    add r21 = r21, r4
    add r22 = r22, r4
    
    beq r0, (r0, r0) -> @store_loop.func_single_block_read
    @store_loop_end.func_single_block_read

    // CRC 読み出し（無視）
    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    
    // エラーコードの設定
    @address_error.func_single_block_read
    addi r10 = r0, 1
    beq r0, (r0, r0) -> @epilogue.func_single_block_read

    @epilogue.func_single_block_read
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
