module top
  (
   input        clk_i,
   input        rst_ni,

   // Optional external clock for prescaler. 
   input        ext_clk_i, 

   // I2C Address set. A6 always 1.
   input [5:0]  address_i,

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

   `include "src/pca_registers.vh"
   
   // Need a shared data store for other components to use
   wire [7:0]   write_register_id_w, write_register_value_w;
   wire         write_enable_w;
   wire [0:2047] register_blob_w;
   wire [0:511]  register_led_w;
   
   register_data reg_data (
                           .clk_i(clk_i),
                           .rst_ni(rst_ni),
                           .write_register_id_i(write_register_id_w),
                           .write_register_value_i(write_register_value_w),
                           .write_enable_i(write_enable_w),
                           .register_blob_o(register_blob_w),
                           .register_led_o(register_led_w)
                           );

   wire [11:0]    counter_w;

   wire           prescale_clk_w;

   assign prescale_clk_w = register_blob_w[PCA_MODE1_EXTCLK] ? ext_clk_i : clk_i;
   
   prescaled_counter counter (
                  .clk_i(prescale_clk_w),
                  .rst_ni(rst_ni),
                  .prescale_value(register_blob_w[8'hFE*8:8'hFE*8+7]),
                  .counter_ro(counter_w)
                  );

   pwm_driver pwm1 (
                    .counter_i(counter_w),

                    .pwm_0_on_i(register_led_w[(0*32)+11]),
                    .pwm_0_off_i(register_led_w[(0*32)+27]),
                    .pwm_0_high_i({
                                   {register_led_w[(0*32)+12:(0*32)+15]},
                                   {register_led_w[(0*32)+0:(0*32)+7]}
                                   }),
                    .pwm_0_low_i({
                                  {register_led_w[(0*32)+28:(0*32)+31]},
                                  {register_led_w[(0*32)+16:(0*32)+23]}
                                  }),
                    .pwm_0_o(led_0_o),

                    .pwm_1_on_i(register_led_w[(1*32)+11]),
                    .pwm_1_off_i(register_led_w[(1*32)+27]),
                    .pwm_1_high_i({
                                   {register_led_w[(1*32)+12:(1*32)+15]},
                                   {register_led_w[(1*32)+0:(1*32)+7]}
                                   }),
                    .pwm_1_low_i({
                                  {register_led_w[(1*32)+28:(1*32)+31]},
                                  {register_led_w[(1*32)+16:(1*32)+23]}
                                  }),
                    .pwm_1_o(led_1_o),

                    .pwm_2_on_i(register_led_w[(2*32)+11]),
                    .pwm_2_off_i(register_led_w[(2*32)+27]),
                    .pwm_2_high_i({
                                   {register_led_w[(2*32)+12:(2*32)+15]},
                                   {register_led_w[(2*32)+0:(2*32)+7]}
                                   }),
                    .pwm_2_low_i({
                                  {register_led_w[(2*32)+28:(2*32)+31]},
                                  {register_led_w[(2*32)+16:(2*32)+23]}
                                  }),
                    .pwm_2_o(led_2_o),

                    .pwm_3_on_i(register_led_w[(3*32)+11]),
                    .pwm_3_off_i(register_led_w[(3*32)+27]),
                    .pwm_3_high_i({
                                   {register_led_w[(3*32)+12:(3*32)+15]},
                                   {register_led_w[(3*32)+0:(3*32)+7]}
                                   }),
                    .pwm_3_low_i({
                                  {register_led_w[(3*32)+28:(3*32)+31]},
                                  {register_led_w[(3*32)+16:(3*32)+23]}
                                  }),
                    .pwm_3_o(led_3_o),

                    .pwm_4_on_i(register_led_w[(4*32)+11]),
                    .pwm_4_off_i(register_led_w[(4*32)+27]),
                    .pwm_4_high_i({
                                   {register_led_w[(4*32)+12:(4*32)+15]},
                                   {register_led_w[(4*32)+0:(4*32)+7]}
                                   }),
                    .pwm_4_low_i({
                                  {register_led_w[(4*32)+28:(4*32)+31]},
                                  {register_led_w[(4*32)+16:(4*32)+23]}
                                  }),
                    .pwm_4_o(led_4_o),

                    .pwm_5_on_i(register_led_w[(5*32)+11]),
                    .pwm_5_off_i(register_led_w[(5*32)+27]),
                    .pwm_5_high_i({
                                   {register_led_w[(5*32)+12:(5*32)+15]},
                                   {register_led_w[(5*32)+0:(5*32)+7]}
                                   }),
                    .pwm_5_low_i({
                                  {register_led_w[(5*32)+28:(5*32)+31]},
                                  {register_led_w[(5*32)+16:(5*32)+23]}
                                  }),
                    .pwm_5_o(led_5_o),

                    .pwm_6_on_i(register_led_w[(6*32)+11]),
                    .pwm_6_off_i(register_led_w[(6*32)+27]),
                    .pwm_6_high_i({
                                   {register_led_w[(6*32)+12:(6*32)+15]},
                                   {register_led_w[(6*32)+0:(6*32)+7]}
                                   }),
                    .pwm_6_low_i({
                                  {register_led_w[(6*32)+28:(6*32)+31]},
                                  {register_led_w[(6*32)+16:(6*32)+23]}
                                  }),
                    .pwm_6_o(led_6_o),

                    .pwm_7_on_i(register_led_w[(7*32)+11]),
                    .pwm_7_off_i(register_led_w[(7*32)+27]),
                    .pwm_7_high_i({
                                   {register_led_w[(7*32)+12:(7*32)+15]},
                                   {register_led_w[(7*32)+0:(7*32)+7]}
                                   }),
                    .pwm_7_low_i({
                                  {register_led_w[(7*32)+28:(7*32)+31]},
                                  {register_led_w[(7*32)+16:(7*32)+23]}
                                  }),
                    .pwm_7_o(led_7_o),

                    .pwm_8_on_i(register_led_w[(8*32)+11]),
                    .pwm_8_off_i(register_led_w[(8*32)+27]),
                    .pwm_8_high_i({
                                   {register_led_w[(8*32)+12:(8*32)+15]},
                                   {register_led_w[(8*32)+0:(8*32)+7]}
                                   }),
                    .pwm_8_low_i({
                                  {register_led_w[(8*32)+28:(8*32)+31]},
                                  {register_led_w[(8*32)+16:(8*32)+23]}
                                  }),
                    .pwm_8_o(led_8_o),

                    .pwm_9_on_i(register_led_w[(9*32)+11]),
                    .pwm_9_off_i(register_led_w[(9*32)+27]),
                    .pwm_9_high_i({
                                   {register_led_w[(9*32)+12:(9*32)+15]},
                                   {register_led_w[(9*32)+0:(9*32)+7]}
                                   }),
                    .pwm_9_low_i({
                                  {register_led_w[(9*32)+28:(9*32)+31]},
                                  {register_led_w[(9*32)+16:(9*32)+23]}
                                  }),
                    .pwm_9_o(led_9_o),

                    .pwm_10_on_i(register_led_w[(10*32)+11]),
                    .pwm_10_off_i(register_led_w[(10*32)+27]),
                    .pwm_10_high_i({
                                   {register_led_w[(10*32)+12:(10*32)+15]},
                                   {register_led_w[(10*32)+0:(10*32)+7]}
                                   }),
                    .pwm_10_low_i({
                                  {register_led_w[(10*32)+28:(10*32)+31]},
                                  {register_led_w[(10*32)+16:(10*32)+23]}
                                  }),
                    .pwm_10_o(led_10_o),

                    .pwm_11_on_i(register_led_w[(11*32)+11]),
                    .pwm_11_off_i(register_led_w[(11*32)+27]),
                    .pwm_11_high_i({
                                   {register_led_w[(11*32)+12:(11*32)+15]},
                                   {register_led_w[(11*32)+0:(11*32)+7]}
                                   }),
                    .pwm_11_low_i({
                                  {register_led_w[(11*32)+28:(11*32)+31]},
                                  {register_led_w[(11*32)+16:(11*32)+23]}
                                  }),
                    .pwm_11_o(led_11_o),

                    .pwm_12_on_i(register_led_w[(12*32)+11]),
                    .pwm_12_off_i(register_led_w[(12*32)+27]),
                    .pwm_12_high_i({
                                   {register_led_w[(12*32)+12:(12*32)+15]},
                                   {register_led_w[(12*32)+0:(12*32)+7]}
                                   }),
                    .pwm_12_low_i({
                                  {register_led_w[(12*32)+28:(12*32)+31]},
                                  {register_led_w[(12*32)+16:(12*32)+23]}
                                  }),
                    .pwm_12_o(led_12_o),

                    .pwm_13_on_i(register_led_w[(13*32)+11]),
                    .pwm_13_off_i(register_led_w[(13*32)+27]),
                    .pwm_13_high_i({
                                   {register_led_w[(13*32)+12:(13*32)+15]},
                                   {register_led_w[(13*32)+0:(13*32)+7]}
                                   }),
                    .pwm_13_low_i({
                                  {register_led_w[(13*32)+28:(13*32)+31]},
                                  {register_led_w[(13*32)+16:(13*32)+23]}
                                  }),
                    .pwm_13_o(led_13_o),

                    .pwm_14_on_i(register_led_w[(14*32)+11]),
                    .pwm_14_off_i(register_led_w[(14*32)+27]),
                    .pwm_14_high_i({
                                   {register_led_w[(14*32)+12:(14*32)+15]},
                                   {register_led_w[(14*32)+0:(14*32)+7]}
                                   }),
                    .pwm_14_low_i({
                                  {register_led_w[(14*32)+28:(14*32)+31]},
                                  {register_led_w[(14*32)+16:(14*32)+23]}
                                  }),
                    .pwm_14_o(led_14_o),

                    .pwm_15_on_i(register_led_w[(15*32)+11]),
                    .pwm_15_off_i(register_led_w[(15*32)+27]),
                    .pwm_15_high_i({
                                   {register_led_w[(15*32)+12:(15*32)+15]},
                                   {register_led_w[(15*32)+0:(15*32)+7]}
                                   }),
                    .pwm_15_low_i({
                                  {register_led_w[(15*32)+28:(15*32)+31]},
                                  {register_led_w[(15*32)+16:(15*32)+23]}
                                  }),
                    .pwm_15_o(led_15_o)
                    
                    );

   
   
   i2c_target ic2(
                  .clk_i(clk_i),
                  .rst_ni(rst_ni),
                  .assigned_address_i({{1'b1},{address_i}}),
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
