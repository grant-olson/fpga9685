module top
  (
   input clk_i,
   input rst_ni,
   input scl_i,
   inout sda_io,

   output dbg_start_o,
   output [3:0] dbg_state_o
   
   );

   i2c_target ic2(
                  .clk_i(clk_i),
                  .rst_ni(rst_ni),
                  .assigned_address_i(7'b1110000),
                  .scl_i(scl_i),
                  .sda_io(sda_io),
                  // To track state with a hardware logic analyzer
                  // for debugging. Not needed when not debugging
                  .dbg_start_o(dbg_start_o),
                  .dbg_state_o(dbg_state_o)
                  );
   
                  
endmodule // top
