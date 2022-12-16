/* I2C controller meant primarily to make it easy to test the device. */

module i2c_controller
  #( parameter ticks = 10
    )
   
  (
   input 	    clk_i,
   input 	    rst_ni,

   input [6:0] 	    address_i,
   input 	    rw_i,
   input [7:0] 	    register_i,
   input [7:0] 	    data_i,
   output reg [7:0] data_o,

   input 	    execute_i,
 
   output reg 	    scl_ro,
   inout 	    sda_io,

   output 	    busy_o	    
   );

   localparam WAIT = 3'd0;
   localparam LOAD_BIT = 3'd1;
   localparam SEND_BIT = 3'd2;
   localparam FINALIZE_BIT = 3'd3;
   localparam GET_ACK = 3'd4;
   localparam DONE = 3'd5;

   reg [23:0] 	    buffer;

   reg [3:0] 	    state = WAIT; 
   
   reg [3:0] 	    bits_sent;
   reg [2:0] 	    bytes_sent;
 	    
   reg 		    sda_r = 1'bz;

   reg [15:0] 	    tick_counter;
   
   assign sda_io = sda_r;
   assign busy_o = state != WAIT;
   
   always @(posedge clk_i) begin
      case (state)
	WAIT: begin
	   if (execute_i)
	     begin
		buffer[23:17] <= address_i;
		buffer[16] <= rw_i;
		buffer[15:8] <= register_i;
		buffer[7:0] <= data_i;
		
		bits_sent <= 4'd0;
		bytes_sent <= 3'd0;

		tick_counter <= 16'd0;
		
		state <= LOAD_BIT;
	     end
	   
	end // case: WAIT

	LOAD_BIT: begin
	   scl_ro <= 1'bz;
	   tick_counter <= tick_counter + 1'b1;
	   
	   if (tick_counter >= ticks / 2 - 2) state <= SEND_BIT;
	   else sda_r <= buffer[23] ? 1'bz : 1'b0 ;
	   
	end

	SEND_BIT: begin
	   scl_ro <= 1'b0;
	   tick_counter <= tick_counter + 1'b1;

	   if (tick_counter >= ticks - 2) state <= FINALIZE_BIT;
	end

	FINALIZE_BIT: begin
	   scl_ro <= 1'bz;
	   buffer[23:1] <= buffer[23:0];
	   if(bits_sent >= 7) begin // we just sent the eighth.
	      state <= GET_ACK;
	      tick_counter <= 0;
	   end else begin
	      bits_sent <= bits_sent + 1'b1;
	      state <= LOAD_BIT;
	      tick_counter <= 0;
	   end
	   
	end // case: FINALIZE_BIT

	GET_ACK: begin
	   tick_counter <= tick_counter + 1'b1;
	   
	   if (tick_counter < ticks / 2 - 1) scl_ro <= 1'bz;
	   
	   else if (tick_counter < ticks - 2) scl_ro <= 1'b0;
	   
	   else if (tick_counter >= ticks - 1) begin
	      scl_ro <= 1'bz;

	      if (bytes_sent >= 2) begin
		 state <= WAIT;
	      end else begin
		 bytes_sent <= bytes_sent + 1'b1;
		 bits_sent <= 4'd0;
		 tick_counter <= 16'd0;
		 
		 state <= LOAD_BIT;
	      end
	   end
	   
	end // case: GET_ACK
	    
      endcase // case state
   end
   
   
   
endmodule // i2c_controller



