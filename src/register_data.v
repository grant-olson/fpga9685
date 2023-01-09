`define DF_OFFSET(DF) (DF-LED_0_ON_L);

module register_data
  (

   input               clk_i,
   input               rst_ni,

   input [7:0]         write_register_id_i,
   input [7:0]         write_register_value_i,
   input               write_enable_i,

   // Numbers are stored Least-Significant-Byte first, and the octets
   // are stored Most-Significant-Bit first. So:
   //
   // 0x0203... is register[0] = 0x02 register[1] = 0x03
   //
   // If we upgraded to systemverilog we could do a 2D output reg
   //
   // We can save some registers by skipping the unused/reserved registers
   // but for not lets not optimize to keep code simple
   //
   // The real optimization would be to use proprietary BSRAM but then
   // we're tied to a chipset.
   output reg [0:2047] register_blob_o,

   // Same storage as above, but these are the atomically updated
   // LED/PWM parameters that get updated only after all four bytes
   // have been set. Then it shadows the values at the time this happens.
   //
   // We can save a few bits since we really only need 26 bits to store
   // values, but lets keep code simple now.
   output reg [0:511]  register_led_o
   );

   // For the actual LED params, we need to mark them as dirty,
   // then only update the values used by the PWM driver when
   // all four bytes have been updated.
   //
   // To keep the math simple we store the least significant
   // bit first.
   reg [0:64]          dirty_flags_r;
   wire                led_reg_w;

   assign led_reg_w = (write_register_id_i >= PCA_LED_0_ON_L && 
                       write_register_id_i <= PCA_LED_15_OFF_H);
   
   
`include "src/pca_registers.vh"

   localparam OFFSET = PCA_LED_0_ON_L;
   
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

         register_led_o <= {{1'b0}};
         dirty_flags_r <= {{1'b0}};
         
      end else if (write_enable_i) begin
         register_blob_o[write_register_id_i*8] <= write_register_value_i[7];
         register_blob_o[write_register_id_i*8+1] <= write_register_value_i[6];
         register_blob_o[write_register_id_i*8+2] <= write_register_value_i[5];
         register_blob_o[write_register_id_i*8+3] <= write_register_value_i[4];
         register_blob_o[write_register_id_i*8+4] <= write_register_value_i[3];
         register_blob_o[write_register_id_i*8+5] <= write_register_value_i[2];
         register_blob_o[write_register_id_i*8+6] <= write_register_value_i[1];
         register_blob_o[write_register_id_i*8+7] <= write_register_value_i[0];

         if (led_reg_w) begin
            dirty_flags_r[write_register_id_i - PCA_LED_0_ON_L] <= 1;
         end
         
      end else begin // if (write_enable_i)

         // It seems there HAS to be a way to do this without cut and paste,
         // but I haven't figured that out yet.
         if (dirty_flags_r[PCA_LED_0_ON_L-OFFSET:PCA_LED_0_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_0_ON_L-OFFSET:PCA_LED_0_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_0_ON_L-OFFSET)*8:(PCA_LED_0_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_0_ON_L*8):(PCA_LED_0_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_1_ON_L-OFFSET:PCA_LED_1_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_1_ON_L-OFFSET:PCA_LED_1_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_1_ON_L-OFFSET)*8:(PCA_LED_1_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_1_ON_L*8):(PCA_LED_1_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_2_ON_L-OFFSET:PCA_LED_2_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_2_ON_L-OFFSET:PCA_LED_2_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_2_ON_L-OFFSET)*8:(PCA_LED_2_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_2_ON_L*8):(PCA_LED_2_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_3_ON_L-OFFSET:PCA_LED_3_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_3_ON_L-OFFSET:PCA_LED_3_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_3_ON_L-OFFSET)*8:(PCA_LED_3_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_3_ON_L*8):(PCA_LED_3_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_4_ON_L-OFFSET:PCA_LED_4_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_4_ON_L-OFFSET:PCA_LED_4_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_4_ON_L-OFFSET)*8:(PCA_LED_4_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_4_ON_L*8):(PCA_LED_4_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_5_ON_L-OFFSET:PCA_LED_5_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_5_ON_L-OFFSET:PCA_LED_5_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_5_ON_L-OFFSET)*8:(PCA_LED_5_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_5_ON_L*8):(PCA_LED_5_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_6_ON_L-OFFSET:PCA_LED_6_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_6_ON_L-OFFSET:PCA_LED_6_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_6_ON_L-OFFSET)*8:(PCA_LED_6_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_6_ON_L*8):(PCA_LED_6_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_7_ON_L-OFFSET:PCA_LED_7_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_7_ON_L-OFFSET:PCA_LED_7_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_7_ON_L-OFFSET)*8:(PCA_LED_7_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_7_ON_L*8):(PCA_LED_7_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_8_ON_L-OFFSET:PCA_LED_8_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_8_ON_L-OFFSET:PCA_LED_8_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_8_ON_L-OFFSET)*8:(PCA_LED_8_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_8_ON_L*8):(PCA_LED_8_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_9_ON_L-OFFSET:PCA_LED_9_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_9_ON_L-OFFSET:PCA_LED_9_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_9_ON_L-OFFSET)*8:(PCA_LED_9_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_9_ON_L*8):(PCA_LED_9_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_10_ON_L-OFFSET:PCA_LED_10_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_10_ON_L-OFFSET:PCA_LED_10_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_10_ON_L-OFFSET)*8:(PCA_LED_10_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_10_ON_L*8):(PCA_LED_10_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_11_ON_L-OFFSET:PCA_LED_11_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_11_ON_L-OFFSET:PCA_LED_11_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_11_ON_L-OFFSET)*8:(PCA_LED_11_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_11_ON_L*8):(PCA_LED_11_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_12_ON_L-OFFSET:PCA_LED_12_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_12_ON_L-OFFSET:PCA_LED_12_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_12_ON_L-OFFSET)*8:(PCA_LED_12_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_12_ON_L*8):(PCA_LED_12_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_13_ON_L-OFFSET:PCA_LED_13_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_13_ON_L-OFFSET:PCA_LED_13_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_13_ON_L-OFFSET)*8:(PCA_LED_13_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_13_ON_L*8):(PCA_LED_13_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_14_ON_L-OFFSET:PCA_LED_14_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_14_ON_L-OFFSET:PCA_LED_14_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_14_ON_L-OFFSET)*8:(PCA_LED_14_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_14_ON_L*8):(PCA_LED_14_ON_L*8)+31];
            
         end

         if (dirty_flags_r[PCA_LED_15_ON_L-OFFSET:PCA_LED_15_OFF_H-OFFSET]
             == 4'b1111) begin
            dirty_flags_r[PCA_LED_15_ON_L-OFFSET:PCA_LED_15_OFF_H-OFFSET] <= 4'b0000;

            register_led_o[
                           (PCA_LED_15_ON_L-OFFSET)*8:(PCA_LED_15_ON_L-OFFSET)*8+31
                           ] <= register_blob_o[(PCA_LED_15_ON_L*8):(PCA_LED_15_ON_L*8)+31];
            
         end


         
      end // else: !if(write_enable_i)
      
      
   end
   
endmodule // register_data
