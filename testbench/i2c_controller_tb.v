`timescale 1ns/1ns

module i2c_controller_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   reg [6:0] address;
   reg       rw;
   reg [7:0] register;

   reg [7:0]  data_in_r;
   wire [7:0] data_out;

   reg 	      trigger = 1'b0;
   
   wire       scl, sda, busy;

   pullup(scl);
   pullup(sda);

   
   always #1 clk_r = ~clk_r;

   i2c_controller i2c_c1 (
		      .clk_i(clk_r),
		      .rst_ni(rst_nr),
		      .address_i(address),
		      .rw_i(rw),
		      .register_id_i(register),
		      .register_value_i(data_in_r),
		      .register_value_o(data_out),
		      
		      .execute_i(trigger),

		      .scl_o(scl),
		      .sda_io(sda),
		      .busy_o(busy)
		      );
   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      $display("Reading Data...");
      
      address <= 7'h78;
      rw <= 1'b1;
      register <= 8'h0F;
      data_in_r <= 8'b00000000;
      
      #1 trigger <= 1;
      wait(busy == 1'b1);
      #1 trigger <= 0;
      
      wait(busy == 1'b0);
      
      $display("Getting Data");
      #1 rw <= 1'b0;
      data_in_r <= 8'b01010101;

      #1 trigger <= 1;
      wait(busy == 1'b1);
      
      #1 trigger <= 0;

      wait(busy == 1'b0);
      
      $finish();
   end

   
   initial begin
      $dumpfile("output/i2c_controller_dump.vcd");
      $dumpvars(2);
   end

endmodule // i2c_controller_tb



