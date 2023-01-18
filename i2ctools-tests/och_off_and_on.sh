#!/bin/bash

I2C_BUS=${I2C_BUS:-1}

# Sleep / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x11

# 50 Hertz
i2ctransfer -y ${I2C_BUS} w2@0x40 0xFE 0x84

echo DEFAULT SETTING. JUST UPDATING LED0_OFF_H SHOULD MAKE CHANGES.
echo PWM SIGNAL SHOULD INCREASE EVERY TWO SECONDS.

# Take out of sleep
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x01

i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x00
sleep 2

i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x04
sleep 2

i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x08
sleep 2

i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x0b
sleep 2

i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x0f
sleep 2

echo DONE DEFAULT

# back off
i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x10

# Sleep / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x11

# On ACK / Totem pole
i2ctransfer -y ${I2C_BUS} w2@0x40 0x01 0x0c

# Take out of sleep
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x01

echo ACK MODE. UPDATE TO LED0_OFF_H ONLY SHOULD DO NOTHING.
i2ctransfer -y ${I2C_BUS} w2@0x40 0x09 0x0f
sleep 2

echo LED0_OFF_L and LED0_ON_H SHOULD STILL DO NOTHING
i2ctransfer -y ${I2C_BUS} w2@0x40 0x08 0x00 w2@0x40 0x07 0x00
sleep 2

echo FINALLY SETTING LED0_ON_L SHOULD TRIGGER ATOMIC COMMIT
i2ctransfer -y ${I2C_BUS} w2@0x40 0x06 0x00
sleep 2

# Return to On STOP / Totem pole
i2ctransfer -y ${I2C_BUS} w2@0x40 0x01 0x04

