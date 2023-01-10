module single_pwm_driver 
  (
   input [11:0] counter_i,

   input        on_i,
   input        off_i,
   input [11:0] high_i,
   input [11:0] low_i,

   input        invert_i,
   
   output reg   pwm_o
   );

   always @(*) begin
      if (on_i) pwm_o = invert_i ? 1'b0 : 1'b1;
      else if (off_i) pwm_o = invert_i ? 1'b1 : 1'b0;
      else if (counter_i >= high_i && counter_i < low_i) pwm_o = invert_i ? 1'b0 : 1'b1;
      else pwm_o = invert_i ? 1'b1 : 1'b0;
   end

   
endmodule // single_pwm_driver

module pwm_driver
  (
   input [11:0] counter_i,

   input        invert_i,
   
   input        pwm_0_on_i,
   input        pwm_0_off_i,
   input [11:0] pwm_0_high_i,
   input [11:0] pwm_0_low_i,

   output       pwm_0_o,

   input        pwm_1_on_i,
   input        pwm_1_off_i,
   input [11:0] pwm_1_high_i,
   input [11:0] pwm_1_low_i,

   output       pwm_1_o,

   input        pwm_2_on_i,
   input        pwm_2_off_i,
   input [11:0] pwm_2_high_i,
   input [11:0] pwm_2_low_i,

   output       pwm_2_o,

   input        pwm_3_on_i,
   input        pwm_3_off_i,
   input [11:0] pwm_3_high_i,
   input [11:0] pwm_3_low_i,

   output       pwm_3_o,

   input        pwm_4_on_i,
   input        pwm_4_off_i,
   input [11:0] pwm_4_high_i,
   input [11:0] pwm_4_low_i,

   output       pwm_4_o,

   input        pwm_5_on_i,
   input        pwm_5_off_i,
   input [11:0] pwm_5_high_i,
   input [11:0] pwm_5_low_i,

   output       pwm_5_o,

   input        pwm_6_on_i,
   input        pwm_6_off_i,
   input [11:0] pwm_6_high_i,
   input [11:0] pwm_6_low_i,

   output       pwm_6_o,

   input        pwm_7_on_i,
   input        pwm_7_off_i,
   input [11:0] pwm_7_high_i,
   input [11:0] pwm_7_low_i,

   output       pwm_7_o,

   input        pwm_8_on_i,
   input        pwm_8_off_i,
   input [11:0] pwm_8_high_i,
   input [11:0] pwm_8_low_i,

   output       pwm_8_o,

   input        pwm_9_on_i,
   input        pwm_9_off_i,
   input [11:0] pwm_9_high_i,
   input [11:0] pwm_9_low_i,

   output       pwm_9_o,

   input        pwm_10_on_i,
   input        pwm_10_off_i,
   input [11:0] pwm_10_high_i,
   input [11:0] pwm_10_low_i,

   output       pwm_10_o,

   input        pwm_11_on_i,
   input        pwm_11_off_i,
   input [11:0] pwm_11_high_i,
   input [11:0] pwm_11_low_i,

   output       pwm_11_o,

   input        pwm_12_on_i,
   input        pwm_12_off_i,
   input [11:0] pwm_12_high_i,
   input [11:0] pwm_12_low_i,

   output       pwm_12_o,

   input        pwm_13_on_i,
   input        pwm_13_off_i,
   input [11:0] pwm_13_high_i,
   input [11:0] pwm_13_low_i,

   output       pwm_13_o,

   input        pwm_14_on_i,
   input        pwm_14_off_i,
   input [11:0] pwm_14_high_i,
   input [11:0] pwm_14_low_i,

   output       pwm_14_o,

   input        pwm_15_on_i,
   input        pwm_15_off_i,
   input [11:0] pwm_15_high_i,
   input [11:0] pwm_15_low_i,

   output       pwm_15_o   
   );

   single_pwm_driver led0 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_0_on_i),
                           .off_i(pwm_0_off_i),
                           .high_i(pwm_0_high_i),
                           .low_i(pwm_0_low_i),
                           .pwm_o(pwm_0_o)
                           );
   
   single_pwm_driver led1 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_1_on_i),
                           .off_i(pwm_1_off_i),
                           .high_i(pwm_1_high_i),
                           .low_i(pwm_1_low_i),
                           .pwm_o(pwm_1_o)
                           );
   
   single_pwm_driver led2 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_2_on_i),
                           .off_i(pwm_2_off_i),
                           .high_i(pwm_2_high_i),
                           .low_i(pwm_2_low_i),
                           .pwm_o(pwm_2_o)
                           );
   
   single_pwm_driver led3 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_3_on_i),
                           .off_i(pwm_3_off_i),
                           .high_i(pwm_3_high_i),
                           .low_i(pwm_3_low_i),
                           .pwm_o(pwm_3_o)
                           );
   
  
   single_pwm_driver led4 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_4_on_i),
                           .off_i(pwm_4_off_i),
                           .high_i(pwm_4_high_i),
                           .low_i(pwm_4_low_i),
                           .pwm_o(pwm_4_o)
                           );
   
   single_pwm_driver led5 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_5_on_i),
                           .off_i(pwm_5_off_i),
                           .high_i(pwm_5_high_i),
                           .low_i(pwm_5_low_i),
                           .pwm_o(pwm_5_o)
                           );
   
   single_pwm_driver led6 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_6_on_i),
                           .off_i(pwm_6_off_i),
                           .high_i(pwm_6_high_i),
                           .low_i(pwm_6_low_i),
                           .pwm_o(pwm_6_o)
                           );
   
   single_pwm_driver led7 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_7_on_i),
                           .off_i(pwm_7_off_i),
                           .high_i(pwm_7_high_i),
                           .low_i(pwm_7_low_i),
                           .pwm_o(pwm_7_o)
                           );
   
   single_pwm_driver led8 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_8_on_i),
                           .off_i(pwm_8_off_i),
                           .high_i(pwm_8_high_i),
                           .low_i(pwm_8_low_i),
                           .pwm_o(pwm_8_o)
                           );
   
   single_pwm_driver led9 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_9_on_i),
                           .off_i(pwm_9_off_i),
                           .high_i(pwm_9_high_i),
                           .low_i(pwm_9_low_i),
                           .pwm_o(pwm_9_o)
                           );
   
   single_pwm_driver led10 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_10_on_i),
                           .off_i(pwm_10_off_i),
                           .high_i(pwm_10_high_i),
                           .low_i(pwm_10_low_i),
                           .pwm_o(pwm_10_o)
                           );
   
   single_pwm_driver led11 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_11_on_i),
                           .off_i(pwm_11_off_i),
                           .high_i(pwm_11_high_i),
                           .low_i(pwm_11_low_i),
                           .pwm_o(pwm_11_o)
                           );
   
   single_pwm_driver led12 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_12_on_i),
                           .off_i(pwm_12_off_i),
                           .high_i(pwm_12_high_i),
                           .low_i(pwm_12_low_i),
                           .pwm_o(pwm_12_o)
                           );
   
   single_pwm_driver led13 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_13_on_i),
                           .off_i(pwm_13_off_i),
                           .high_i(pwm_13_high_i),
                           .low_i(pwm_13_low_i),
                           .pwm_o(pwm_13_o)
                           );
   
   single_pwm_driver led14 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_14_on_i),
                           .off_i(pwm_14_off_i),
                           .high_i(pwm_14_high_i),
                           .low_i(pwm_14_low_i),
                           .pwm_o(pwm_14_o)
                           );
   
   single_pwm_driver led15 (
                           .counter_i(counter_i),
                           .invert_i(invert_i),
                           
                           .on_i(pwm_15_on_i),
                           .off_i(pwm_15_off_i),
                           .high_i(pwm_15_high_i),
                           .low_i(pwm_15_low_i),
                           .pwm_o(pwm_15_o)
                           );

endmodule // pwm_driver
