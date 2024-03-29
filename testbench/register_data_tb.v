`timescale 1ns/1ns

module register_data_tb
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   reg [7:0] write_register_id_r, write_register_value_r;
   reg       write_enable_r = 1'b0;
   wire [0:2047] register_blob_r;

   wire [7:0]    register_bytes_w[0:255];

   generate
      genvar     i;
   
      for(i = 0; i < 256; i = i + 1) begin
         assign register_bytes_w[i] = register_blob_r[i*8:i*8+7];
      end
   endgenerate
   
   assign test_w = register_bytes_w[0];
 
   always #1 clk_r <= ~clk_r;

   register_data reg_data (
                           .clk_i(clk_r),
                           .rst_ni(rst_nr),
                           .write_register_id_i(write_register_id_r),
                           .write_register_value_i(write_register_value_r),
                           .write_enable_i(write_enable_r),

                           .register_blob_o(register_blob_r)
                           );

   initial begin
      $display("Starting Testbench...");
      #1 rst_nr <= 1;
      #1 rst_nr <= 0;
      #1 rst_nr <= 1;

      #1 write_register_id_r <= 8'h04;
      write_register_value_r <= 8'hAA;

      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;

      #1 write_register_id_r <= 8'h00;
      write_register_value_r <= 8'hBB;

      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;

      $display("Writing 4 values to single LED settings");

      #1 write_register_id_r <= 8'h42;
      write_register_value_r <= 8'hDE;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   
      #1 write_register_id_r <= 8'h43;
      write_register_value_r <= 8'h4D;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   
      #1 write_register_id_r <= 8'h44;
      write_register_value_r <= 8'hBE;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   
      #1 write_register_id_r <= 8'h45;
      write_register_value_r <= 8'hEF;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   
      #10;

      $display("Write an ALL value, see if it sets all and dirty flags");

      #1 write_register_id_r <= 8'hFC;
      write_register_value_r <= 8'hBE;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   

      $display("And the rest see if atomic update happens");

      #1 write_register_id_r <= 8'hFD;
      write_register_value_r <= 8'hEF;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;
   
      #1 write_register_id_r <= 8'hFA;
      write_register_value_r <= 8'hDE;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;


      #1 write_register_id_r <= 8'hFB;
      write_register_value_r <= 8'h4D;
      
      #1 write_enable_r <= 1;
      #5 write_enable_r <= 0;

      #1000; // So gtkwave doesn't truncate result

  
      $finish();
   end
   
   initial begin
      $dumpfile("output/register_data_dump.vcd");
      $dumpvars(2);
   end
   
   
endmodule // register_data_tb
