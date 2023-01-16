#!/bin/bash

I2C_BUS=${I2C_BUS:-1}

# Sleep / Allcall /Auto-increment enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x31

# 50 Hertz
i2ctransfer -y ${I2C_BUS} w2@0x40 0xFE 0x84

# Set values
i2ctransfer -y ${I2C_BUS} w5@0x40 0x06 0x00 0x00 0x00 0x08

# Take out of sleep
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x21

echo LED1 PWM for 10 seconds...
sleep 10

# EXTCLK / Sleep / auto-increment / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x71

echo EXT CLOCK ENABLED, but asleep...

sleep 1

# EXTCLK / auto-increment / Allcall enabled
i2ctransfer -y ${I2C_BUS} w2@0x40 0x00 0x21

echo Removed sleep, didn\'t set EXTCLK, but it should be sticky and show 0x61...

i2ctransfer -y ${I2C_BUS} w1@0x40 0x00 r1

sleep 1

echo forcing software reset

i2ctransfer -a ${I2C_BUS} w1@0x00 0x06
