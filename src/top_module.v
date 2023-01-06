module top
  (
   input        clk_i,
   input        rst_ni,
   input        scl_i,
   inout        sda_io,

   output       led_0_o,
   output       led_1_o,
   output       led_2_o,
   output       led_3_o,
   output       led_4_o,
   output       led_5_o,
   output       led_6_o,
   output       led_7_o,
   output       led_8_o,
   output       led_9_o,
   output       led_10_o,
   output       led_11_o,
   output       led_12_o,
   output       led_13_o,
   output       led_14_o,
   output       led_15_o,
   
   output       dbg_start_o,
   output [3:0] dbg_state_o
   
   );

   // Need a shared data store for other components to use
   wire [7:0] write_register_id_w, write_register_value_w;
   wire       write_enable_w;
   wire [0:2047] register_blob_w;
   
   register_data reg_data (
                           .clk_i(clk_i),
                           .rst_ni(rst_ni),
                           .write_register_id_i(write_register_id_w),
                           .write_register_value_i(write_register_value_w),
                           .write_enable_i(write_enable_w),
                           .register_blob_o(register_blob_w)
                           );

   wire [11:0]    counter_w;
   
   prescaled_counter counter (
                  .clk_i(clk_i),
                  .rst_ni(rst_ni),
                  .prescale_value(8'h1E),
                  .counter_ro(counter_w)
                  );

   pwm_driver pwm1 (
                    .counter_i(counter_w),

                    .pwm_0_on_i(1'b0),
                    .pwm_0_off_i(1'b0),
                    .pwm_0_high_i(12'd0),
                    .pwm_0_low_i(12'd0),
                    .pwm_0_o(led_0_o),

                    .pwm_1_on_i(1'b0),
                    .pwm_1_off_i(1'b0),
                    .pwm_1_high_i(12'd0),
                    .pwm_1_low_i(12'd0),
                    .pwm_1_o(led_1_o),

                    .pwm_2_on_i(1'b0),
                    .pwm_2_off_i(1'b0),
                    .pwm_2_high_i(12'd0),
                    .pwm_2_low_i(12'd0),
                    .pwm_2_o(led_2_o),

                    .pwm_3_on_i(1'b0),
                    .pwm_3_off_i(1'b0),
                    .pwm_3_high_i(12'd0),
                    .pwm_3_low_i(12'd0),
                    .pwm_3_o(led_3_o),

                    .pwm_4_on_i(1'b0),
                    .pwm_4_off_i(1'b0),
                    .pwm_4_high_i(12'd0),
                    .pwm_4_low_i(12'd0),
                    .pwm_4_o(led_4_o),

                    .pwm_5_on_i(1'b0),
                    .pwm_5_off_i(1'b0),
                    .pwm_5_high_i(12'd0),
                    .pwm_5_low_i(12'd0),
                    .pwm_5_o(led_5_o),

                    .pwm_6_on_i(1'b0),
                    .pwm_6_off_i(1'b0),
                    .pwm_6_high_i(12'd0),
                    .pwm_6_low_i(12'd0),
                    .pwm_6_o(led_6_o),

                    .pwm_7_on_i(1'b0),
                    .pwm_7_off_i(1'b0),
                    .pwm_7_high_i(12'd0),
                    .pwm_7_low_i(12'd0),
                    .pwm_7_o(led_7_o),

                    .pwm_8_on_i(1'b0),
                    .pwm_8_off_i(1'b0),
                    .pwm_8_high_i(12'd0),
                    .pwm_8_low_i(12'd0),
                    .pwm_8_o(led_8_o),

                    .pwm_9_on_i(1'b0),
                    .pwm_9_off_i(1'b0),
                    .pwm_9_high_i(12'd0),
                    .pwm_9_low_i(12'd0),
                    .pwm_9_o(led_9_o),

                    .pwm_10_on_i(1'b0),
                    .pwm_10_off_i(1'b0),
                    .pwm_10_high_i(12'd0),
                    .pwm_10_low_i(12'd0),
                    .pwm_10_o(led_10_o),

                    .pwm_11_on_i(1'b0),
                    .pwm_11_off_i(1'b0),
                    .pwm_11_high_i(12'd0),
                    .pwm_11_low_i(12'd0),
                    .pwm_11_o(led_11_o),

                    .pwm_12_on_i(1'b0),
                    .pwm_12_off_i(1'b0),
                    .pwm_12_high_i(12'd0),
                    .pwm_12_low_i(12'd0),
                    .pwm_12_o(led_12_o),

                    .pwm_13_on_i(1'b0),
                    .pwm_13_off_i(1'b0),
                    .pwm_13_high_i(12'd0),
                    .pwm_13_low_i(12'd0),
                    .pwm_13_o(led_13_o),

                    .pwm_14_on_i(1'b0),
                    .pwm_14_off_i(1'b0),
                    .pwm_14_high_i(12'd0),
                    .pwm_14_low_i(12'd0),
                    .pwm_14_o(led_14_o),

                    .pwm_15_on_i(1'b0),
                    .pwm_15_off_i(1'b0),
                    .pwm_15_high_i(12'd0),
                    .pwm_15_low_i(12'd0),
                    .pwm_15_o(led_15_o)
                    );

   
   
   i2c_target ic2(
                  .clk_i(clk_i),
                  .rst_ni(rst_ni),
                  .assigned_address_i(7'b1110000),
                  .scl_i(scl_i),
                  .sda_io(sda_io),

                      .write_register_id_o(write_register_id_w),
                      .write_register_value_o(write_register_value_w),
                      .write_enable_o(write_enable_w),
                      .register_blob_i(register_blob_w),

                  
                  // To track state with a hardware logic analyzer
                  // for debugging. Not needed when not debugging
                  .dbg_start_o(dbg_start_o),
                  .dbg_state_o(dbg_state_o)
                  );
   
                  
endmodule // top
