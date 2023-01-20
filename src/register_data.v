`define DF_OFFSET(DF) (DF-LED_0_ON_L);



module register_data
  (

   input               clk_i,
   input               rst_ni,

   input [7:0]         write_register_id_i,
   input [7:0]         write_register_value_i,
   input               write_enable_i,

   input               i2c_stopped,
   
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
   output reg [0:PCA_TOTAL_BITS-1] register_blob_o,

   // Same storage as above, but these are the atomically updated
   // LED/PWM parameters that get updated only after all four bytes
   // have been set. Then it shadows the values at the time this happens.
   //
   // We can save a few bits since we really only need 26 bits to store
   // values, but lets keep code simple now.
   output reg [0:511]  register_led_o
   );

   `include "src/pca_registers.vh"

   
   // For the actual LED params, we need to mark them as dirty,
   // then only update the values used by the PWM driver when
   // all four bytes have been updated.
   //
   // To keep the math simple we store the least significant
   // bit first.
   reg [0:64]          dirty_flags_r;
   wire                led_reg_w;

   reg                 clear_restart = 1'b0;
   
   assign led_reg_w = (write_register_id_i >= PCA_LED_0_ON_L && 
                       write_register_id_i <= PCA_LED_15_OFF_H);

   assign led_all_w = (write_register_id_i >= PCA_ALL_LED_ON_L && 
                       write_register_id_i <= PCA_ALL_LED_OFF_H);

   
   localparam OFFSET = PCA_LED_0_ON_L;
   integer             i;
   
   always @(posedge clk_i or negedge rst_ni) begin
      if(~rst_ni) begin
         // All the low default values
         register_blob_o <= PCA_DEFAULT_VALUES;

         register_led_o <= {{1'b0}};
         dirty_flags_r <= {{1'b0}};
         
      end else if (write_enable_i) begin
         register_blob_o[(write_register_id_i*8) +: 8] <= write_register_value_i[7:0];

         if (led_reg_w) begin
            dirty_flags_r[write_register_id_i - PCA_LED_0_ON_L] <= 1;
         end

         if (led_all_w) begin
            for (i = 0; i < 64; i = i + 4) begin
               register_blob_o[(write_register_id_i-PCA_ALL_LED_ON_L
                                +PCA_LED_0_ON_L+i)*8 +: 8] <= write_register_value_i[7:0];
               dirty_flags_r[write_register_id_i-PCA_ALL_LED_ON_L+i] <= 1'b1;
            end
         end

         // We are in UPDATE ON STOP mode, and a LED register was modified.
         // So undo RESET when we update registers.
         if (~register_blob_o[PCA_MODE2_OCH] & (led_all_w | led_reg_w)) begin
            clear_restart <= 1'b1;
         end
         
      end else begin // if (write_enable_i)

         if (register_blob_o[PCA_MODE2_OCH]) begin

            // Write on ACK.
            //
            // We can implicitly assume this because any register write happens
            // when we transition to the ACK state in the i2c_target module.
            //
            // If all 4 value registers for an LED have been updated, we do an
            // atomic write here, and set the values that the counter uses.
            for (i = 0; i < 16; i = i + 1) begin
            
               if (dirty_flags_r[4*(PCA_LED_0_ON_L-OFFSET+i) +: 4] == 4'b1111) begin
                  // Clear out dirty flags
                  dirty_flags_r[4*(PCA_LED_0_ON_L-OFFSET+i) +: 4] <= 4'b0000;
                  
                  // If we were in RESTART mode, we're not anymore after commit.
                  register_blob_o[PCA_MODE1_RESTART] <= 1'b0;

                  // (i*4) because we have ON_L, ON_H, OFF_L, OFF_H = 4 bytes per group
                  register_led_o[8*(PCA_LED_0_ON_L-OFFSET+(i*4)) +: 32] <= register_blob_o[8*(PCA_LED_0_ON_L+(i*4)) +: 32];

               end

            end
         end else if (i2c_stopped) begin // if (register_blob_o[PCA_MODE2_OCH])
            // Write on stop
            register_led_o[8*(PCA_LED_0_ON_L-OFFSET) +: 512] <= register_blob_o[8*PCA_LED_0_ON_L +: 512];

            if (clear_restart) begin
               register_blob_o[PCA_MODE1_RESTART] <= 1'b0;
               clear_restart <= 1'b0;
            end
            
         end
      end // else: !if(write_enable_i)
      
      
   end
   
endmodule // register_data
