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

   // Need a shared data store for other components to use
   wire [7:0] write_register_id_w, write_register_value_w;
   wire       write_enable_w;
   wire [0:2047] register_blob_w;
   
   register_data reg_data (
                           .clk_i(clk_r),
                           .rst_ni(rst_nr),
                           .write_register_id_i(write_register_id_w),
                           .write_register_value_i(write_register_value_w),
                           .write_enable_i(write_enable_w),
                           .register_blob_o(register_blob_w)
                           );
   i2c_target i2c_t1 (
		      .clk_i(clk_r),
		      .rst_ni(rst_nr),

		      .assigned_address_i(7'h48), 

		      .scl_i(scl_w),
		      .sda_io(sda_w),
                      
                      .write_register_id_o(write_register_id_w),
                      .write_register_value_o(write_register_value_w),
                      .write_enable_o(write_enable_w),
                      .register_blob_i(register_blob_w)
	     );

   
   
   reg 	trigger_r = 1'b0;
   wire busy;


   reg [6:0] c1_address_r = 7'h48;
   reg 	     c1_rw_r = 1'b1;
   reg [7:0] c1_register_r = 8'h0E;
   reg [7:0] c1_value_r = 8'hAF;
   reg       c1_send_register_value_r = 1'b1;
   
   i2c_controller i2c_c1 (
		          .clk_i(clk_r),
		          .rst_ni(rst_nr), 
		          .address_i(c1_address_r),
		          .rw_i(c1_rw_r),
		          .register_id_i(c1_register_r),
		          .register_value_i(c1_value_r),
		          .register_value_ro(),
      
		          .execute_i(trigger_r),
                          .send_register_value_i(c1_send_register_value_r),

		          .scl_o(scl_w),
		          .sda_io(sda_w),
		          .busy_o(busy)
		          );
   

   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      $display("Sending WRITE request...");
      
      
      #1 c1_address_r <= 7'h48;
      c1_register_r <= 8'h0E;
      c1_value_r <= 8'hB1;
      c1_rw_r <= 1'b0;
      c1_send_register_value_r <= 1'b1;
      
      #1 trigger_r <= 1;
      wait(busy == 1'b1);
      #1 trigger_r <= 0;

      wait(busy == 1'b0);

      $display("Sending READ request, part one WRITE REGISTER ADDRESS ONLY...");

      #1 c1_rw_r <= 1'b0;
      c1_send_register_value_r <= 1'b0;
      
      #1 trigger_r <= 1;
      wait(busy == 1'b1);
      #1 trigger_r <= 0;

      wait(busy == 1'b0);

      $display("Sending READ request, part two READ VALUE ONLY...");

      #1 c1_rw_r <= 1'b1;
      
      #1 trigger_r <= 1;
      wait(busy == 1'b1);
      #1 trigger_r <= 0;

      wait(busy == 1'b0);

  
      
      $finish();
   end

   initial begin
      $dumpfile("output/i2c_target_dump.vcd");
      $dumpvars(2);
   end
   
endmodule      
