`timescale 1ns/1ns

module i2c_target_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;
   reg scl_r = 1'bz;
   reg sda_r = 1'bz;
   
   wire sda_w, scl_w;

   assign sda_w = sda_r;
   assign scl_w = scl_r;
   
   pullup(sda_w);
   pullup(scl_w);
   
   always #1 clk_r = ~clk_r;

   i2c_target i2c_t1 (
	     .clk_i(clk_r),
	     .rst_ni(rst_nr),

	     .address5_i(1'b0), 
	     .address4_i(1'b0), 
	     .address3_i(1'b0), 
	     .address2_i(1'b0), 
	     .address1_i(1'b0), 
	     .address0_i(1'b1), 

	     .scl_i(scl_w),
	     .sda_io(sda_w)
	
	     );

   reg 	trigger_r;
   wire busy;


   reg [6:0] c1_address_r = 7'h48;
   reg 	     c1_rw_r = 1'b1;
   reg [7:0] c1_register_r = 8'hBE;
   reg [7:0] c1_value_r = 8'hEE;
   
   i2c_controller i2c_c1 (
		      .clk_i(clk_r),
		      .rst_ni(rst_nr), 
		      .address_i(c1_address_r),
		      .rw_i(c1_rw_r),
		      .register_i(c1_register_r),
		      .data_i(c1_value_r),
		      .data_o(),
		      
		      .execute_i(trigger_r),

		      .scl_o(scl_w),
		      .sda_io(sda_w),
		      .busy_o(busy)
		      );
   

   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      #5 trigger_r <= 0;
      #1 trigger_r <= 1;
      #5 trigger_r <= 0;

      wait(busy == 1'b0);

      #1 c1_address_r <= 7'b0110111;
      c1_register_r <= 8'hDE;
      c1_rw_r <= 1'b0;
      c1_value_r <= 8'h4D;

      #5 trigger_r <= 0;
      #1 trigger_r <= 1;
      #5 trigger_r <= 0;

      wait(busy == 1'b0);

      #400;
      $finish();
   end

   initial begin
      $dumpfile("output/i2c_target_dump.vcd");
      $dumpvars(2);
   end
   
endmodule      
