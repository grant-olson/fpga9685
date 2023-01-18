module top
  (
   input         clk_i,
   input         rst_ni,

   // Optional external clock for prescaler. 
   input         ext_clk_i, 

   // I2C Address set. A6 always 1.
   input [5:0]   address_i,

   // Output enable
   input         oe_ni ,
   
   input         scl_i,
   inout         sda_io,

   output [0:15] led_o
   
   );

   `include "src/pca_registers.vh"
   
   // Need a shared data store for other components to use
   wire [7:0]   write_register_id_w, write_register_value_w;
   wire         write_enable_w;
   wire [0:PCA_TOTAL_BITS-1] register_blob_w;
   wire [0:511]  register_led_w;

   wire          i2c_soft_rst_nw, reg_data_rst_nw;
   // If either one is low, do a reset.
   assign reg_data_rst_nw = i2c_soft_rst_nw & rst_ni;

   wire          i2c_stopped;

   register_data reg_data (
                           .clk_i(clk_i),
                           .rst_ni(reg_data_rst_nw),
                           .write_register_id_i(write_register_id_w),
                           .write_register_value_i(write_register_value_w),
                           .write_enable_i(write_enable_w),
                           .i2c_stopped(i2c_stopped),
                           .register_blob_o(register_blob_w),
                           .register_led_o(register_led_w)
                           
                           );

   wire [11:0]    counter_w;

   wire           prescale_clk_w;

   // Support for MODE2 OUTDRV and OUTNE
   // Tells what signal to send when Output DISabled.
   
   reg [0:15]            led_oe_setting_r;
   
   wire [0:15]    pwm_w;
   

   assign led_o = (register_blob_w[PCA_MODE1_SLEEP] | oe_ni) ? 
                  led_oe_setting_r : pwm_w;

   always @(*) begin
      if (register_blob_w[PCA_MODE2_OUTNE1]) led_oe_setting_r = {{1'bz}};
      else if (register_blob_w[PCA_MODE2_OUTNE0]) begin
         // Handle open drain config if needed
         led_oe_setting_r = register_blob_w[PCA_MODE2_OUTDRV] ? {{1'b1}} : {{1'bz}};
      end else led_oe_setting_r = {{1'b0}};
   end

   // And initialize the modules

   assign clock_multiplex_w = register_blob_w[PCA_MODE1_EXTCLK] ? 
                              ext_clk_i : clk_i;
   
   assign prescale_clk_w = register_blob_w[PCA_MODE1_SLEEP] ? 
                           1'b0 : clock_multiplex_w;
   
   
   prescaled_counter counter (
                  .clk_i(prescale_clk_w),
                  .rst_ni(rst_ni),
                  .prescale_value(register_blob_w[(PCA_PRE_SCALE_INT*8) +: 8]),
                  .counter_ro(counter_w)
                  );

   pwm_driver pwm1 (
                    .counter_i(counter_w),
                    .invert_i(register_blob_w[PCA_MODE2_INVRT]),
                    
                    .pwm_0_on_i(register_led_w[(0*32)+11]),
                    .pwm_0_off_i(register_led_w[(0*32)+27]),
                    .pwm_0_high_i({
                                   {register_led_w[(0*32)+12 +: 4]},
                                   {register_led_w[(0*32) +: 8]}
                                   }),
                    .pwm_0_low_i({
                                  {register_led_w[(0*32)+28 +: 4]},
                                  {register_led_w[(0*32)+16 +: 8]}
                                  }),
                    .pwm_0_o(pwm_w[0]),

                    .pwm_1_on_i(register_led_w[(1*32)+11]),
                    .pwm_1_off_i(register_led_w[(1*32)+27]),
                    .pwm_1_high_i({
                                   {register_led_w[(1*32)+12 +: 4]},
                                   {register_led_w[(1*32) +: 8]}
                                   }),
                    .pwm_1_low_i({
                                  {register_led_w[(1*32)+28 +: 4]},
                                  {register_led_w[(1*32)+16 +: 8]}
                                  }),
                    .pwm_1_o(pwm_w[1]),

                    .pwm_2_on_i(register_led_w[(2*32)+11]),
                    .pwm_2_off_i(register_led_w[(2*32)+27]),
                    .pwm_2_high_i({
                                   {register_led_w[(2*32)+12 +: 4]},
                                   {register_led_w[(2*32) +: 8]}
                                   }),
                    .pwm_2_low_i({
                                  {register_led_w[(2*32)+28 +: 4]},
                                  {register_led_w[(2*32)+16 +: 8]}
                                  }),
                    .pwm_2_o(pwm_w[2]),

                    .pwm_3_on_i(register_led_w[(3*32)+11]),
                    .pwm_3_off_i(register_led_w[(3*32)+27]),
                    .pwm_3_high_i({
                                   {register_led_w[(3*32)+12 +: 4]},
                                   {register_led_w[(3*32) +: 8]}
                                   }),
                    .pwm_3_low_i({
                                  {register_led_w[(3*32)+28 +: 4]},
                                  {register_led_w[(3*32)+16 +: 8]}
                                  }),
                    .pwm_3_o(pwm_w[3]),

                    .pwm_4_on_i(register_led_w[(4*32)+11]),
                    .pwm_4_off_i(register_led_w[(4*32)+27]),
                    .pwm_4_high_i({
                                   {register_led_w[(4*32)+12 +: 4]},
                                   {register_led_w[(4*32) +: 8]}
                                   }),
                    .pwm_4_low_i({
                                  {register_led_w[(4*32)+28 +: 4]},
                                  {register_led_w[(4*32)+16 +: 8]}
                                  }),
                    .pwm_4_o(pwm_w[4]),

                    .pwm_5_on_i(register_led_w[(5*32)+11]),
                    .pwm_5_off_i(register_led_w[(5*32)+27]),
                    .pwm_5_high_i({
                                   {register_led_w[(5*32)+12 +: 4]},
                                   {register_led_w[(5*32) +: 8]}
                                   }),
                    .pwm_5_low_i({
                                  {register_led_w[(5*32)+28 +: 4]},
                                  {register_led_w[(5*32)+16 +: 8]}
                                  }),
                    .pwm_5_o(pwm_w[5]),

                    .pwm_6_on_i(register_led_w[(6*32)+11]),
                    .pwm_6_off_i(register_led_w[(6*32)+27]),
                    .pwm_6_high_i({
                                   {register_led_w[(6*32)+12 +: 4]},
                                   {register_led_w[(6*32) +: 8]}
                                   }),
                    .pwm_6_low_i({
                                  {register_led_w[(6*32)+28 +: 4]},
                                  {register_led_w[(6*32)+16 +: 8]}
                                  }),
                    .pwm_6_o(pwm_w[6]),

                    .pwm_7_on_i(register_led_w[(7*32)+11]),
                    .pwm_7_off_i(register_led_w[(7*32)+27]),
                    .pwm_7_high_i({
                                   {register_led_w[(7*32)+12 +:4]},
                                   {register_led_w[(7*32) +: 8]}
                                   }),
                    .pwm_7_low_i({
                                  {register_led_w[(7*32)+28 +: 4]},
                                  {register_led_w[(7*32)+16 +: 8]}
                                  }),
                    .pwm_7_o(pwm_w[7]),

                    .pwm_8_on_i(register_led_w[(8*32)+11]),
                    .pwm_8_off_i(register_led_w[(8*32)+27]),
                    .pwm_8_high_i({
                                   {register_led_w[(8*32)+12 +: 4]},
                                   {register_led_w[(8*32) +: 8]}
                                   }),
                    .pwm_8_low_i({
                                  {register_led_w[(8*32)+28 +: 4]},
                                  {register_led_w[(8*32)+16 +: 8]}
                                  }),
                    .pwm_8_o(pwm_w[8]),

                    .pwm_9_on_i(register_led_w[(9*32)+11]),
                    .pwm_9_off_i(register_led_w[(9*32)+27]),
                    .pwm_9_high_i({
                                   {register_led_w[(9*32)+12 +: 4]},
                                   {register_led_w[(9*32) +: 8]}
                                   }),
                    .pwm_9_low_i({
                                  {register_led_w[(9*32)+28 +: 4]},
                                  {register_led_w[(9*32)+16 +: 8]}
                                  }),
                    .pwm_9_o(pwm_w[9]),

                    .pwm_10_on_i(register_led_w[(10*32)+11]),
                    .pwm_10_off_i(register_led_w[(10*32)+27]),
                    .pwm_10_high_i({
                                   {register_led_w[(10*32)+12 +: 4]},
                                   {register_led_w[(10*32) +: 8]}
                                   }),
                    .pwm_10_low_i({
                                  {register_led_w[(10*32)+28 +: 4]},
                                  {register_led_w[(10*32)+16 +:8]}
                                  }),
                    .pwm_10_o(pwm_w[10]),

                    .pwm_11_on_i(register_led_w[(11*32)+11]),
                    .pwm_11_off_i(register_led_w[(11*32)+27]),
                    .pwm_11_high_i({
                                   {register_led_w[(11*32)+12 +: 4]},
                                   {register_led_w[(11*32) +: 8]}
                                   }),
                    .pwm_11_low_i({
                                  {register_led_w[(11*32)+28 +: 4]},
                                  {register_led_w[(11*32)+16 +: 8]}
                                  }),
                    .pwm_11_o(pwm_w[11]),

                    .pwm_12_on_i(register_led_w[(12*32)+11]),
                    .pwm_12_off_i(register_led_w[(12*32)+27]),
                    .pwm_12_high_i({
                                   {register_led_w[(12*32)+12 +: 4]},
                                   {register_led_w[(12*32) +: 8]}
                                   }),
                    .pwm_12_low_i({
                                  {register_led_w[(12*32)+28 +: 4]},
                                  {register_led_w[(12*32)+16 +: 8]}
                                  }),
                    .pwm_12_o(pwm_w[12]),

                    .pwm_13_on_i(register_led_w[(13*32)+11]),
                    .pwm_13_off_i(register_led_w[(13*32)+27]),
                    .pwm_13_high_i({
                                   {register_led_w[(13*32)+12 +: 4]},
                                   {register_led_w[(13*32) +: 8]}
                                   }),
                    .pwm_13_low_i({
                                  {register_led_w[(13*32)+28 +: 4]},
                                  {register_led_w[(13*32)+16 +: 8]}
                                  }),
                    .pwm_13_o(pwm_w[13]),

                    .pwm_14_on_i(register_led_w[(14*32)+11]),
                    .pwm_14_off_i(register_led_w[(14*32)+27]),
                    .pwm_14_high_i({
                                   {register_led_w[(14*32)+12 +: 4]},
                                   {register_led_w[(14*32) +: 8]}
                                   }),
                    .pwm_14_low_i({
                                  {register_led_w[(14*32)+28 +: 4]},
                                  {register_led_w[(14*32)+16 +: 8]}
                                  }),
                    .pwm_14_o(pwm_w[14]),

                    .pwm_15_on_i(register_led_w[(15*32)+11]),
                    .pwm_15_off_i(register_led_w[(15*32)+27]),
                    .pwm_15_high_i({
                                   {register_led_w[(15*32)+12 +: 4]},
                                   {register_led_w[(15*32) +: 8]}
                                   }),
                    .pwm_15_low_i({
                                  {register_led_w[(15*32)+28 +: 4]},
                                  {register_led_w[(15*32)+16 +:8]}
                                  }),
                    .pwm_15_o(pwm_w[15])
                    
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

                  .soft_rst_no(i2c_soft_rst_nw),
                  .i2c_stopped(i2c_stopped)
                  
                  );
   
                  
endmodule // top
