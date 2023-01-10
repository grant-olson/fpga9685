# FPGA-9685

This project reimplements the behavior of the venerable PCA9685
16-Channel 12-Bit PWM controller in Verilog for deployment to
FPGAs. The PCA9685 is used by hobbyists around the world to drive
multiple servos from a microcontroller while minimizing GPIO usage.

The manufacturer describes the chip as a PWM LED controller. To be
consistent with the documentation in the datasheet we will frequently
refer to PWM pins as LED pins, such as `LED0`. In practice the terms
PWM and LED are interchangeable.

Current implemented functionality:

* Custom address lines `A0`-`A5`.
* Clock prescaler can be set to determine PWM Hertz signals.
* Individual PWM settings for LED0 - LED15 can be set.
* Optional External Clock Support.

Known things on the todo list:

* Check clock prescaler values, and only allow update in `SLEEP` mode.
* Signal Inversion.
* `_ALL_` set registers should propogate values to individual registers.
* `ALLCALL` and `RESET` i2c addresses need to be implemented.
* More, I'm sure...

## Custom Addresses

To mimic the PCA9685 there are 6 input pins `A0`-`A5` which you
probably want to configure with Pull Down resistors. Then the device
will operate at a default i2c address of `0x40`. You can then connect
the pins to `V+` to change the address to support more than one device
on the bus.

Alternately, if you're trying to save pins you can hard-code the address
for an individual FPGA in `src/top_module.v`.

Note that you should avoid the the ALL CALL address `0x70` although it is
physically possible to set this address via the pins.

## Clock and PreScale

The PCA9865 provides equations to set the base PWM hertz in the
datasheet. This assumes you are using a clock speed of 25 Mhz. If your
main FPGA clock does not run at this speed you'll need to set up a PLL
to get identical behavior.

If you have access to your controller and choose to change the value
written to the FPGA9685 and the pre-scaler, the new equation is:

```

    Mhz of FPGA
--------------------  -  1
4096 x Desired Hertz

```

For example, if we want to generate a 50 Hz servo PWM signal on a Tang
Nano 9k with a clock speed of 27 Mhz.

```
27 MHz
--------- - 1 = **131.8** *rounded to **132**
4096 * 50

```

## Makefile

A Makefile is provided to run test benches in Icarus Verilog. Since
your choice of FPGA will likely determine the IDE you use to compile a
working system, the Makefile does not attempt to automate this.

To run a test run `make *module_name*_gtk`. This should figure
everything out and open the results in `gtkwave` for your review.

## I2C SDA Open Drain Test

The I2C SDA line is an **open-drain** configuration to allow both
client and server to control the bus. The line rests at a state of 1
via pullup resistors and is pulled down by either the server or client
depending on when the server is reading or writing. This means you
must configure your GPIO pin for SDA to Open Drain mode with a pull-up
resistor.

If you need to confirm that you've done this correctly, the file
`src/test_open_drain.v` can be deployed to your FPGA. It has two pins
that connect as an open drain to each other. One pin will first pull
the pin low five times while the other pin counts, then the other pin
will pull low five times while the first pin counts. If you have
configured your FPGA correctly the RECV LEDs will show activity, and
the DONE LEDs will show that both pins counted five LOW states while
listening.

When choosing pins for this test be sure to use pins that are NOT
hooked up to any other capacitors/resistors/ICs/components that allow
different peripherals on your board to share the GPIO pins. The author
wasted a day and much confusion after using pins 68 and 69 on his Tang
Nano 9K. These are also attached to a HDMI output voltage matching
network and broke the open drain functionality in very confusing and
unpredictable ways.

After testing successfully use the settings used on the test pins for
the SDA line when building the full project.

