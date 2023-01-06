/* Allow us to divide the main clock to get the appropriate frequency
 for our PWM signals, and output a counter so we know when to set the
 PWM signals high and low.
 */
module prescaled_counter
  (
   input       clk_i,
   input       rst_ni,

   input [7:0] prescale_value,

   output reg [11:0] counter_ro
   );

   reg [15:0]  scale_counter_r = 16'b0;

   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         scale_counter_r <= 8'b0;
         counter_ro <= 12'b0;
      end else begin
         if (scale_counter_r >= prescale_value) begin
            counter_ro <= counter_ro + 1'b1;
            scale_counter_r <= 0;
         end else scale_counter_r <= scale_counter_r + 1'b1;
      end

   end
   
endmodule // prescaler
