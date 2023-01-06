`timescale 1ns/1ns

module prescaled_counter_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   always #1 clk_r <= ~clk_r;

   wire[11:0] counter_w;
   
   prescaled_counter  pcl (
                           .clk_i(clk_r),
                           .rst_ni(rst_nr),
                           .prescale_value(8'h03), // Lowest valid value
                           .counter_ro(counter_w)
                           );
   
   
   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      // Get past early numbers, then wait til we loop
      #4096;
      wait (counter_w == 12'h0A);

      
      $finish();
   end

   initial begin
      $dumpfile("output/prescaled_counter_dump.vcd");
      $dumpvars(2);
   end
   

endmodule // register_data_tb
