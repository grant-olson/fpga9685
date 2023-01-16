#!/bin/bash

# Auto incremenet lets us bulk set registers. Try setting
# LED 1

I2C_BUS=${I2C_BUS:-1}

# Auto increment / Sleep / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x31

# 50 Hertz
i2ctransfer -y ${I2C_BUS} w2@0x40 0xFE 0x84

# Start 0x400 - end 0xb00 = 50% duty cycle 25% phase offset
i2ctransfer -y ${I2C_BUS} w5@0x40 0x06 0x00 0x04 0x00 0x0b

# Take out of sleep
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x21
