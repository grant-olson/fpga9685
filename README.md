# FPGA-9685

This project reimplements the behavior of the venerable PCA9685
16-Channel 12-Bit PWM controller in Verilog for deployment to
FPGAs. The PCA9685 is used by hobbyists around the world to drive
multiple servos from a microcontroller while minimizing GPIO usage.

Currently we have basic functionality:

* Clock prescaler can be set to determine PWM Hertz signals.
* Individual PWM settings can be set.

Known things on the todo list:

* Check clock prescaler values, and only allow update in `SLEEP` mode.
* External Clock Support.
* Signal Inversion.
* `_ALL_` set registers should propogate values to individual registers.
* `ALLCALL` and `RESET` i2c addresses need to be implemented.
* Custom assigned address via input pins.
* More, I'm sure...

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

