`timescale 1ns/1ns

module i2c_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;
   
   always #1 clk_r = ~clk_r;

   wire pin;
   pullup(pin);

   wire led_recv_1;
   wire led_recv_2;
   wire led_done_1;
   wire led_done_2;
   
   open_drain_test #(
		     .tick_interval(10)
		     ) odt (
			    .clk_i(clk_r),
			    .rst_ni(rst_nr),
				    
			    .pin1_io(pin),
			    .pin2_io(pin),
				    
			    .led_recv_1_o(led_recv_1),
			    .led_done_1_o(led_done_1),
			    
			    .led_recv_2_o(led_recv_2),
			    .led_done_2_o(led_done_2)
			    
			    );
   
		  
   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;
      #400;
      $finish();
   end
   
   initial begin
      $dumpfile("output/test_open_drain_dump.vcd");
      $dumpvars(3);
   end
endmodule
