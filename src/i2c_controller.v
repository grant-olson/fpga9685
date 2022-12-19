/* I2C controller meant primarily to make it easy to test the device. */

module i2c_controller
  #( parameter ticks = 27 // 2.7 Mhz / 100kbps
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
 
   output 	    scl_o,
   inout 	    sda_io,

   output 	    busy_o	    
   );

   localparam WAIT = 4'd0;
   localparam START = 4'd1;
   localparam LOAD_BIT = 4'd2;
   localparam SEND_BIT = 4'd3;
   localparam FINALIZE_BIT = 4'd4;
   localparam GET_ACK = 4'd5;
   localparam SEND_ACK = 4'd6;
   localparam SEND_NACK = 4'd7;
   localparam STOP = 4'd8;
   localparam RETRIEVE_BIT = 4'd9;
   
   localparam READ = 1'b1;
   localparam WRITE = 1'b1;
   
   reg [23:0] 	    buffer;
   reg 		    rw_r;
   
   reg [3:0] 	    state = WAIT; 
   
   reg [3:0] 	    bits_sent;
   reg [2:0] 	    bytes_sent;
 	    
   reg 		    sda_r = 1'bz;
   reg 		    scl_r = 1'bz;
		    
   reg [15:0] 	    tick_counter;
   
   assign sda_io = sda_r;
   assign scl_o = scl_r;
   
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

		// Save independently since we shift bits out of buffer.
		rw_r <= rw_i; 
		
		bits_sent <= 4'd0;
		bytes_sent <= 3'd0;

		tick_counter <= 16'd0;
		
		state <= START;
	     end
	   
	end // case: WAIT

	START: begin // Bring SDA low while SCL is still high
	   if(tick_counter < ticks / 2) begin
	      tick_counter <= tick_counter + 1'b1;
	   end else if (tick_counter < ticks) begin
	      sda_r <= 1'b0;
	      tick_counter <= tick_counter + 1'b1;
	   end else begin
	      tick_counter <= 16'd0;
	      state <= LOAD_BIT;
	   end
	      
	end
	
	LOAD_BIT: begin
	   scl_r <= 1'b0;
	   tick_counter <= tick_counter + 1'b1;
	   
	   if (tick_counter >= 1) sda_r <= buffer[23] ? 1'bz : 1'b0 ;
	   if (tick_counter >= ticks / 2 - 2) state <= SEND_BIT;
	   
	end

	SEND_BIT: begin
	   scl_r <= 1'bz;
	   tick_counter <= tick_counter + 1'b1;

	   if (tick_counter >= ticks - 2) state <= FINALIZE_BIT;
	end

	FINALIZE_BIT: begin
	   scl_r <= 1'b1;
	   buffer[23:1] <= buffer[22:0];
	   if(bits_sent >= 7) begin // we just sent the eighth.
	      state <= GET_ACK;
	      tick_counter <= 0;
	   end else begin
	      bits_sent <= bits_sent + 1'b1;
	      state <= LOAD_BIT;
	      tick_counter <= 0;
	   end
	   
	end // case: FINALIZE_BIT

	// READ bit in from CLIENT to WRITE to REGISTER
	// Come up with a better name.
	RETRIEVE_BIT: begin
	   tick_counter <= tick_counter + 1'b1;
	   if (tick_counter < ticks / 2 - 1) scl_r <= 1'bz;
	   else if (tick_counter < ticks / 2) begin
	      data_o[6:0] <= data_o[7:1];
	      data_o[7] <= sda_io;
	      bits_sent <= bits_sent + 1'b1;
	      if (bits_sent > 7) state <= GET_ACK;
	   end
	   else if (tick_counter < ticks - 2) scl_r <= 1'b0;
	   else begin
	      tick_counter <= 16'b0;
	      
	      scl_r <= 1'bz;
	   end
	   
	   
	end
	
	
	GET_ACK: begin
	   tick_counter <= tick_counter + 1'b1;
	   
	   if (tick_counter < ticks / 2 - 1) scl_r <= 1'bz;
	   
	   else if (tick_counter < ticks - 2) scl_r <= 1'b0;
	   
	   else if (tick_counter >= ticks - 1) begin

	      if (bytes_sent == 1 && ~rw_r ) begin
		 tick_counter <= 16'd0;

		 state <= RETRIEVE_BIT;
		 bits_sent <= 4'd0;
		 bytes_sent <= bytes_sent + 1'b1;
		 
	      end else if(bytes_sent >= 2) begin
		 tick_counter <= 16'd0;
		 state <= STOP;
	      end else begin
		 scl_r <= 1'bz;
		 bytes_sent <= bytes_sent + 1'b1;
		 bits_sent <= 4'd0;
		 tick_counter <= 16'd0;
		 
		 state <= LOAD_BIT;
	      end
	   end
	   
	end // case: GET_ACK

	STOP: begin // Release SDA AFTER SCL is released.
	   if (tick_counter < ticks / 2) begin
	      scl_r <= 1'bz;
	      sda_r <= 1'b0;
	      tick_counter <= tick_counter + 1'b1;
	   end else if (tick_counter < ticks) begin
	      sda_r <= 1'bz;
	      tick_counter <= tick_counter + 1'b1;
	   end else state <= WAIT;
	end
	
      endcase // case state
   end
   
endmodule // i2c_controller



