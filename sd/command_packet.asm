===

// uint8_t spi_transfer(uint8_t data)
@func_spi_transfer

    // Spi:Send
    add r4 = r0, r10
    out r0[1] = r4

    // Spi:Receive
    in r10 = r0[1]

    // Return
    jal r0, r1[0]


// uint8_t spi_sd_command(uint8_t cmd, uint32_t arg, uint8_t crc)
@func_spi_sd_command

    // フレームポインタの退避
    add r2 = r2, -4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    addi r2 = r2, -4
    sw r3[-4] = r1
 

    // Setup
    addi r5 = r0, @func_spi_transfer
    add  r6 = r0, r11
    add  r7 = r0, r12

    // cmd
    add r4 = r0, r10
    ori r4 = r4, 0x40
    andi r4 = r4, 0x7F
    add r10 = r0, r4
    jal r1, r5[0]

    // arg3
    srli r4 = r6, 24
    add r10 = r0, r4
    jal r1, r5[0]

    // arg2
    srli r4 = r6, 16
    add r10 = r0, r4
    jal r1, r5[0]

    // arg1
    srli r4 = r6, 8
    add r10 = r0, r4
    jal r1, r5[0]

    // arg0
    add r10 = r0, r6
    jal r1, r5[0]

    // crc
    ori r4 = r7, 0x01
    add r10 = r0, r4
    jal r1, r5[0]


    // 保存レジスタの復元
    lw r1 = r3[-4]
    addi r2 = r2, 4

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]



@func_polling_r1_response
    // フレームポインタの退避
    add r2 = r2, -4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    addi r2 = r2, -4
    sw r3[-4] = r1


    @loop.func_polling_r1_response
        // spi_transfer
        addi r10 = r0, 0xFF
        beq r1, (r0, r0) -> @func_spi_transfer

        // loop check
        add r4 = r0, r10
        andi r4 = r4, 0x80
        bne r0, (r4, r0) -> @loop.func_polling_r1_response


    // 保存レジスタの復元
    lw r1 = r3[-4]
    addi r2 = r2, 4

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]



@func_polling_r3_r7_response
    // フレームポインタの退避
    add r2 = r2, -4
    sw r2[0] = r3
    addi r3 = r2, 0

    // リターンアドレスの退避
    addi r2 = r2, -12
    sw r3[-4] = r1
    sw r3[-8] = r20
    sw r3[-12] = r21
    

    @loop.func_polling_r3_r7_response
        // spi_transfer
        addi r10 = r0, 0xFF
        beq r1, (r0, r0) -> @func_spi_transfer

        // loop check
        add r4 = r0, r10
        andi r4 = r4, 0x80
        bne r0, (r4, r0) -> @loop.func_polling_r3_r7_response
        
    add r20 = r0, r10


    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    add r21 = r0, r10

    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    slli r21 = r21, 8
    and r10 = r10, 0xFF
    or r21 = r21, r10

    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    slli r21 = r21, 8
    and r10 = r10, 0xFF
    or r21 = r21, r10

    addi r10 = r0, 0xFF
    beq r1, (r0, r0) -> @func_spi_transfer
    slli r21 = r21, 8
    and r10 = r10, 0xFF
    or r21 = r21, r10

    // r20: r1 resp.
    // r21: r7 resp.(4byte)
    // r10 <- 戻り値レジスタ1
    // r11 <- 戻り値レジスタ2
    // | r19 | ... | r11 | r10 |
    // 39                      0
    add r10 = r0, r21
    add r11 = r0, r20
    

    // 保存レジスタの復元
    lw r1 = r3[-4]
    lw r20 = r3[-8]
    lw r21 = r3[-12]
    addi r2 = r2, 12

    // フレームポインタの復元
    lw r3 = r3[0]
    addi r2 = r2, 4

    // return
    jal r0, r1[0]
