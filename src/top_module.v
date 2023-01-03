module top
  (
   input clk_i,
   input rst_ni,
   input scl_i,
   inout sda_io,

   output dbg_start_o,
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
