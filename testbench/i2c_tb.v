`timescale 1ns/1ns

module i2c_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;
   reg scl_r = 1'b1;
   reg sda_r;
   wire sda_w;

   assign sda_w = sda_r;
   
   always #1 clk_r = ~clk_r;

   i2c i2c1 (
	     .clk_i(clk_r),
	     .rst_ni(rst_nr),

	     .address5_i(1'b0), 
	     .address4_i(1'b0), 
	     .address3_i(1'b0), 
	     .address2_i(1'b0), 
	     .address1_i(1'b0), 
	     .address0_i(1'b1), 

	     .scl_i(scl_r),
	     .sda_io(sda_w)
	
	     );

   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      $display("Sending address...");

      #1 sda_r <= 1;
      
      
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      #1 scl_r <= 0;
      #1 scl_r <= 1;
      

      
      #40;
      $finish();
   end

   initial begin
      $dumpfile("output/i2c_dump.vcd");
      $dumpvars(2);
   end
   
endmodule      
