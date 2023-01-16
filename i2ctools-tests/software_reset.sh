#!/bin/bash
65;6800;1c
I2C_BUS=${I2C_BUS:-1}

# Sleep / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x31

# 50 Hertz
i2ctransfer -y ${I2C_BUS} w2@0x40 0xFE 0x84

# Set values
i2ctransfer -y ${I2C_BUS} w5@0x40 0x06 0x01+

# Take out of sleep
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x21

echo BAD RESET MAGIC NUMBER. VALUES SHOULD BE 0x01 0x02 0x02 0x04
# Issue BAD software reset, wrong magic number
i2ctransfer -a -y ${I2C_BUS} w1@0x00 0x05

i2ctransfer -y ${I2C_BUS} w1@0x40 0x06 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x07 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x08 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x09 r1

echo GOOD RESET MAGIC NUMBER. VALUES SHOULD BE 0x00 0x00 0x00 0x01
# Issue BAD software reset, wrong magic number
i2ctransfer -a -y ${I2C_BUS} w1@0x00 0x06

i2ctransfer -y ${I2C_BUS} w1@0x40 0x06 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x07 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x08 r1
i2ctransfer -y ${I2C_BUS} w1@0x40 0x09 r1
