
module register_data
  (

   input               clk_i,
   input               rst_ni,

   input [7:0]         write_register_id_i,
   input [7:0]         write_register_value_i,
   input               write_enable_i,

   // Numbers are stored Least-Significant-Byte first, and the octets
   // are stored Most-Significant-Bit first. So
   //
   // 0x0203... is register[0] = 0x02 register[1] = 0x03
   output reg [0:2047] register_blob_o
   );

`include "src/pca_registers.vh"

   
   always @(posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
         // All the low default values
         register_blob_o[0:PCA_LOW_MAX_REG*8+7] <= PCA_DEFAULT_VALUES_LOW;

         // Unused, but without this the simulator things we have
         // undefined values
         register_blob_o[(PCA_LOW_MAX_REG+1)*8:(PCA_HIGH_MIN_REG-1)*8+7] <= {{1'b0}};

         // All the high default values
         register_blob_o[PCA_HIGH_MIN_REG*8:PCA_HIGH_MAX_REG*8+7] <= PCA_DEFAULT_VALUES_HIGH;

         // Unused, but without this the simulator things we have
         // undefined values
         register_blob_o[(PCA_HIGH_MAX_REG+1)*8:(PCA_HIGH_MAX_REG+1)*8+7] <= {{1'b1}};
         
      end else if (write_enable_i) begin
         register_blob_o[write_register_id_i*8] <= write_register_value_i[7];
         register_blob_o[write_register_id_i*8+1] <= write_register_value_i[6];
         register_blob_o[write_register_id_i*8+2] <= write_register_value_i[5];
         register_blob_o[write_register_id_i*8+3] <= write_register_value_i[4];
         register_blob_o[write_register_id_i*8+4] <= write_register_value_i[3];
         register_blob_o[write_register_id_i*8+5] <= write_register_value_i[2];
         register_blob_o[write_register_id_i*8+6] <= write_register_value_i[1];
         register_blob_o[write_register_id_i*8+7] <= write_register_value_i[0];
      end
      
   end
   
endmodule // register_data
