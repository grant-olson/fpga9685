`timescale 1ns/1ns



module top
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   wire i2c_scl, i2c_sda;
   pullup(i2c_scl);
   pullup(i2c_sda);
   
   
   always #1 clk_r = ~clk_r;

   i2c_controller i2c_c1 (
			  .clk_i(clk_r),
			  .rst_ni(rst_nr),

			  .address_i(7'b1110000),
			  .rw_i(1'b1),
			  .register_id_i(8'hDE),
			  .register_value_i(8'h4D),
			  
			  .scl_o(i2c_scl),
			  .sda_io(i2c_sda)
			  );


   
   initial begin
      $display("Starting Testbench...");
      #20 rst_nr <= 1;
      #5 rst_nr <= 0;
      #20 rst_nr <= 1;

      #2000;
      
      
      
      $finish();
   end

   initial begin
      $dumpfile("output/i2c_test_dump.vcd");
      $dumpvars(3);
   end
   

   
endmodule // top
