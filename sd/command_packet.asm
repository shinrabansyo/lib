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

    // Setup
    addi r5 = r0, @func_spi_transfer
    add  r6 = r0, r11

    // cmd
    ori r4 = cmd, 0x40
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
    ori r4 = crc, 0x01
    // add r10 = r0, r4 これ違いそう
    jal r1, r5[0]

    // pooling
    ...

    // return
    jal r0, r1[0]
