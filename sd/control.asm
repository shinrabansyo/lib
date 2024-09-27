===

// uint8_t spi_sd_command(uint8_t cmd, uint32_t arg, uint8_t crc)

@func_sd_init
    
    addi r5 = r0, @func_spi_sd_command
    
    // CMD0
    addi r10 = r0, 0x00 // cmd0
    addi r11 = r0, 0x00 // arg
    addi r12 = r0, 0x95 // crc
    jal r1, r5[0]
    // r10 が 0x01 になっているはず

    // CMD8
    addi r10 = r0, 0x08 // cmd8
    addi r11 = r0, 0x000001aa // arg
    addi r12 = r0, 0x87 // crc
    jal r1, r5[0]

    // ACMD41
    
