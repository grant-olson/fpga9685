# FPGA-9685

This project reimplements the behavior of the venerable PCA9685
16-Channel 12-Bit PWM controller in Verilog for deployment to
FPGAs. The PCA9685 is used by hobbyists around the world to drive
multiple servos from a microcontroller while minimizing GPIO usage.

## Makefile

A Makefile is provided to run test benches in Icarus Verilog. Since
your choice of FPGA will likely determine the IDE you use to compile a
working system, the Makefile does not attempt to automate this.

To run a test run `make *module_name*_gtk`. This should figure
everything out and open the results in `gtkwave` for your review.

## I2C SDA Note

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

After that use the settings used on the test pins for the SDA line
when building the full project.
