localparam PCA_MODE1 = 8'h00;
localparam PCA_MODE2 = 8'h01;
localparam PCA_SUBADR1 = 8'h02;
localparam PCA_SUBADR2 = 8'h03;
localparam PCA_SUBADR3 = 8'h04;
localparam PCA_ALLCALLADR= 8'h05;
localparam PCA_LED_0_ON_L = 8'h06;
localparam PCA_LED_0_ON_H = 8'h07;
localparam PCA_LED_0_OFF_L = 8'h08;
localparam PCA_LED_0_OFF_H = 8'h09;
localparam PCA_LED_1_ON_L = 8'h0A;
localparam PCA_LED_1_ON_H = 8'h0B;
localparam PCA_LED_1_OFF_L = 8'h0C;
localparam PCA_LED_1_OFF_H = 8'h0D;
localparam PCA_LED_2_ON_L = 8'h0E;
localparam PCA_LED_2_ON_H = 8'h0F;
localparam PCA_LED_2_OFF_L = 8'h10;
localparam PCA_LED_2_OFF_H = 8'h11;
localparam PCA_LED_3_ON_L = 8'h12;
localparam PCA_LED_3_ON_H = 8'h13;
localparam PCA_LED_3_OFF_L = 8'h14;
localparam PCA_LED_3_OFF_H = 8'h15;
localparam PCA_LED_4_ON_L = 8'h16;
localparam PCA_LED_4_ON_H = 8'h17;
localparam PCA_LED_4_OFF_L = 8'h18;
localparam PCA_LED_4_OFF_H = 8'h19;
localparam PCA_LED_5_ON_L = 8'h1A;
localparam PCA_LED_5_ON_H = 8'h1B;
localparam PCA_LED_5_OFF_L = 8'h1C;
localparam PCA_LED_5_OFF_H = 8'h1D;
localparam PCA_LED_6_ON_L = 8'h1E;
localparam PCA_LED_6_ON_H = 8'h1F;
localparam PCA_LED_6_OFF_L = 8'h20;
localparam PCA_LED_6_OFF_H = 8'h21;
localparam PCA_LED_7_ON_L = 8'h22;
localparam PCA_LED_7_ON_H = 8'h23;
localparam PCA_LED_7_OFF_L = 8'h24;
localparam PCA_LED_7_OFF_H = 8'h25;
localparam PCA_LED_8_ON_L = 8'h26;
localparam PCA_LED_8_ON_H = 8'h27;
localparam PCA_LED_8_OFF_L = 8'h28;
localparam PCA_LED_8_OFF_H = 8'h29;
localparam PCA_LED_9_ON_L = 8'h2A;
localparam PCA_LED_9_ON_H = 8'h2B;
localparam PCA_LED_9_OFF_L = 8'h2C;
localparam PCA_LED_9_OFF_H = 8'h2D;
localparam PCA_LED_10_ON_L = 8'h2E;
localparam PCA_LED_10_ON_H = 8'h2F;
localparam PCA_LED_10_OFF_L = 8'h30;
localparam PCA_LED_10_OFF_H = 8'h31;
localparam PCA_LED_11_ON_L = 8'h32;
localparam PCA_LED_11_ON_H = 8'h33;
localparam PCA_LED_11_OFF_L = 8'h34;
localparam PCA_LED_11_OFF_H = 8'h35;
localparam PCA_LED_12_ON_L = 8'h36;
localparam PCA_LED_12_ON_H = 8'h37;
localparam PCA_LED_12_OFF_L = 8'h38;
localparam PCA_LED_12_OFF_H = 8'h39;
localparam PCA_LED_13_ON_L = 8'h3A;
localparam PCA_LED_13_ON_H = 8'h3B;
localparam PCA_LED_13_OFF_L = 8'h3C;
localparam PCA_LED_13_OFF_H = 8'h3D;
localparam PCA_LED_14_ON_L = 8'h3E;
localparam PCA_LED_14_ON_H = 8'h3F;
localparam PCA_LED_14_OFF_L = 8'h40;
localparam PCA_LED_14_OFF_H = 8'h41;
localparam PCA_LED_15_ON_L = 8'h42;
localparam PCA_LED_15_ON_H = 8'h43;
localparam PCA_LED_15_OFF_L = 8'h44;
localparam PCA_LED_15_OFF_H = 8'h45;
// 0x46-0xF9 unused/reserved for future use
localparam PCA_ALL_LED_ON_L = 8'hFA;
localparam PCA_ALL_LED_ON_H = 8'hFB;
localparam PCA_ALL_LED_OFF_L = 8'hFC;
localparam PCA_ALL_LED_OFF_H = 8'hFD;
localparam PCA_PRE_SCALE = 8'hFE;
localparam PCA_TEST_MODE = 8'hFF;

// Mode bits, as they sit in our big blob of data
localparam PCA_MODE1_RESTART = 0;
localparam PCA_MODE1_EXTCLK = 1;
localparam PCA_MODE1_AI = 2;
localparam PCA_MODE1_SLEEP = 3;
localparam PCA_MODE1_SUB1 = 4;
localparam PCA_MODE1_SUB2 = 5;
localparam PCA_MODE1_SUB3 = 6;
localparam PCA_MODE1_ALLCALL = 7;

localparam PCA_MODE2_INVRT = 11;
localparam PCA_MODE2_OCH = 12;
localparam PCA_MODE2_OUTDRV = 13;
localparam PCA_MODE2_OUTNE1 = 14;
localparam PCA_MODE2_OUTNE0 = 15;

// register defaults for 0x00-0x45
localparam PCA_DEFAULT_VALUES_LOW = {
                                     {8'b00010001}, // MODE 1
                                     {8'b00000100}, // MODE 2

                                     // Use first 7 bits for i2c address
                                     {8'b11100010}, // SUBADR1 - 0x71
                                     {8'b11100100}, // SUBADR2 - 0x72
                                     {8'b11101000}, // SUBADR3 - 0x74
                                     {8'b11100000}, // ALLCALL - 0X70
                                     
                                     {8'h00}, // LED 0 ON L
                                     {8'h00}, // LED 0 ON H
                                     {8'h00}, // LED 0 OFF L
                                     {8'h10}, // LED 0 OFF H - start always off
                                     {8'h00}, // LED 1 ON L
                                     {8'h00}, // LED 1 ON H
                                     {8'h00}, // LED 1 OFF L
                                     {8'h10}, // LED 1 OFF H - start always off
                                     {8'h00}, // LED 2 ON L
                                     {8'h00}, // LED 2 ON H
                                     {8'h00}, // LED 2 OFF L
                                     {8'h10}, // LED 2 OFF H - start always off
                                     {8'h00}, // LED 3 ON L
                                     {8'h00}, // LED 3 ON H
                                     {8'h00}, // LED 3 OFF L
                                     {8'h10}, // LED 3 OFF H - start always off
                                     {8'h00}, // LED 4 ON L
                                     {8'h00}, // LED 4 ON H
                                     {8'h00}, // LED 4 OFF L
                                     {8'h10}, // LED 4 OFF H - start always off
                                     {8'h00}, // LED 5 ON L
                                     {8'h00}, // LED 5 ON H
                                     {8'h00}, // LED 5 OFF L
                                     {8'h10}, // LED 5 OFF H - start always off
                                     {8'h00}, // LED 6 ON L
                                     {8'h00}, // LED 6 ON H
                                     {8'h00}, // LED 6 OFF L
                                     {8'h10}, // LED 6 OFF H - start always off
                                     {8'h00}, // LED 7 ON L
                                     {8'h00}, // LED 7 ON H
                                     {8'h00}, // LED 7 OFF L
                                     {8'h10}, // LED 7 OFF H - start always off
                                     {8'h00}, // LED 8 ON L
                                     {8'h00}, // LED 8 ON H
                                     {8'h00}, // LED 8 OFF L
                                     {8'h10}, // LED 8 OFF H - start always off
                                     {8'h00}, // LED 9 ON L
                                     {8'h00}, // LED 9 ON H
                                     {8'h00}, // LED 9 OFF L
                                     {8'h10}, // LED 9 OFF H - start always off
                                     {8'h00}, // LED 10 ON L
                                     {8'h00}, // LED 10 ON H
                                     {8'h00}, // LED 10 OFF L
                                     {8'h10}, // LED 10 OFF H - start always off
                                     {8'h00}, // LED 11 ON L
                                     {8'h00}, // LED 11 ON H
                                     {8'h00}, // LED 11 OFF L
                                     {8'h10}, // LED 11 OFF H - start always off
                                     {8'h00}, // LED 12 ON L
                                     {8'h00}, // LED 12 ON H
                                     {8'h00}, // LED 12 OFF L
                                     {8'h10}, // LED 12 OFF H - start always off
                                     {8'h00}, // LED 13 ON L
                                     {8'h00}, // LED 13 ON H
                                     {8'h00}, // LED 13 OFF L
                                     {8'h10}, // LED 13 OFF H - start always off
                                     {8'h00}, // LED 14 ON L
                                     {8'h00}, // LED 14 ON H
                                     {8'h00}, // LED 14 OFF L
                                     {8'h10}, // LED 14 OFF H - start always off
                                     {8'h00}, // LED 15 ON L
                                     {8'h00}, // LED 15 ON H
                                     {8'h00}, // LED 15 OFF L
                                     {8'h10} // LED 15 OFF H - start always off
                                 };


localparam PCA_LOW_MAX_REG = 8'h45;

// Ignore a bunch of registers.
// start back up at 0xFA
localparam PCA_DEFAULT_VALUES_HIGH = {
                                  {8'h00}, // ALL_LED_ON_L
                                  {8'h10}, // ALL LED ON H
                                  {8'h00}, // ALL LED OFF L
                                  {8'h10}, // ALL LED OFF H
                                  {8'h1E} // PRE SCALE 20 Mhz
                                  };

localparam PCA_HIGH_MIN_REG = 8'hFA;
localparam PCA_HIGH_MAX_REG = 8'hFE;
