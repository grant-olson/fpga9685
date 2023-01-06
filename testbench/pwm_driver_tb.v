`timescale 1ns/1ns

module pwm_driver_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   reg [11:0] counter_r = 12'b0;
   
   always #1 clk_r <= ~clk_r;

   always #1 counter_r <= counter_r + 1'b1;

   wire       pwm_0_w, pwm_1_w, pwm_2_w, pwm_3_w,
              pwm_4_w, pwm_5_w, pwm_6_w, pwm_7_w,
              pwm_8_w, pwm_9_w, pwm_10_w, pwm_11_w,
              pwm_12_w, pwm_13_w, pwm_14_w, pwm_15_w;
   
   pwm_driver ld1 (
                   .counter_i(counter_r),

                   // Always On
                   .pwm_0_on_i(1'b1),
                   .pwm_0_o(pwm_0_w),

                   // 50 % duty cycle
                   .pwm_1_high_i(12'h00),
                   .pwm_1_low_i(12'h888),
                   .pwm_1_o(pwm_1_w),


                   // 10% duty cycle
                   .pwm_2_high_i(12'd0),
                   .pwm_2_low_i(12'd409),
                   .pwm_2_o(pwm_2_w),

                   // 10% duty cycle, starting 5% in
                   .pwm_3_high_i(12'd204),
                   .pwm_3_low_i(12'd613),
                   .pwm_3_o(pwm_3_w),

                   // 10% duty cycle, starting 10% in
                   .pwm_4_high_i(410*1),
                   .pwm_4_low_i(409*1+409),
                   .pwm_4_o(pwm_4_w),

                   // 10% duty cycle, starting 20% in
                   .pwm_5_high_i(409*2),
                   .pwm_5_low_i(409*2+409),
                   .pwm_5_o(pwm_5_w),

                   // 10% duty cycle, starting 30% in
                   .pwm_6_high_i(409*3),
                   .pwm_6_low_i(409*3+409),
                   .pwm_6_o(pwm_6_w),

                   // 10% duty cycle, starting 40% in
                   .pwm_7_high_i(409*4),
                   .pwm_7_low_i(409*4+409),
                   .pwm_7_o(pwm_7_w),

                   // 10% duty cycle, starting 50% in
                   .pwm_8_high_i(409*5),
                   .pwm_8_low_i(409*5+409),
                   .pwm_8_o(pwm_8_w),

                   // 10% duty cycle, starting 60% in
                   .pwm_9_high_i(409*6),
                   .pwm_9_low_i(409*6+409),
                   .pwm_9_o(pwm_9_w),

                   // 10% duty cycle, starting 70% in
                   .pwm_10_high_i(409*7),
                   .pwm_10_low_i(409*7+409),
                   .pwm_10_o(pwm_10_w),

                   // 10% duty cycle, starting 80% in
                   .pwm_11_high_i(409*8),
                   .pwm_11_low_i(409*8+409),
                   .pwm_11_o(pwm_11_w),

                   // 10% duty cycle, starting 90% in
                   .pwm_12_high_i(409*9),
                   .pwm_12_low_i(409*9+409),
                   .pwm_12_o(pwm_12_w),

                   // always OFF
                   .pwm_13_off_i(1'b1),
                   .pwm_13_o(pwm_13_w),

                   // Start 0, end 4095
                   .pwm_14_high_i(0),
                   .pwm_14_low_i(4095),
                   .pwm_14_o(pwm_14_w),

                   // 50% duty cycle, 25 % offset
                   .pwm_15_high_i(1024),
                   .pwm_15_low_i(1024+2048),
                   .pwm_15_o(pwm_15_w)
                   
                   );
   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      #10240;
      
      $finish();
   end

   initial begin
      $dumpfile("output/pwm_driver_dump.vcd");
      $dumpvars(3);
   end

endmodule // pwm_driver_tb
