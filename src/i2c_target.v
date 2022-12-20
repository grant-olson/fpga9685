module i2c_target
  (
   input clk_i,
   input rst_ni,
   
   input [6:0] assigned_address_i, // This is the address we respond to.

   input scl_i,
   inout sda_io
   
   );

   reg 	     sda_r = 1'bz;
   assign sda_io = sda_r;

   // Track the controller sending start and stop signals
   // so we aren't sucking in random bits and sticking them
   // in the wrong slots.
   // 
   // For now keep this simple but since we're running at
   // 27 Mhz and the clock is < 1 Mhz I imagine we need
   // some debouncing type logic to make sure it's not
   // triggered spuriously
   reg 	     last_scl_r;
   reg 	     last_sda_r;
 
   reg 	     started = 1'b0;
   
   always @(posedge clk_i) begin
      if (last_scl_r & scl_i) begin
	 if (last_sda_r & ~sda_io) started <= 1'b1;
	 else if (~last_sda_r & sda_io) started <= 1'b0;
      end
      
      last_scl_r <= scl_i;
      last_sda_r <= sda_io;

   end

   // And with that out of the way on to the real FSM
   
   localparam IGNORE = 8'd0; // Wait until we get a stop signal.
   localparam COUNTER = 8'd1; // Test pattern
   localparam RECV_ADDRESS = 8'd2;
   localparam RECV_RW = 8'd3;
   localparam RECV_REGISTER_ID = 8'd4;
   localparam RECV_REGISTER_VALUE = 8'd5;
   localparam SEND_REGISTER_VALUE = 8'd6;
   localparam ACK = 8'd7;
   localparam NACK = 8'd8;
   
   reg [7:0] state = RECV_ADDRESS;
   reg [7:0] post_ack_state;

   reg [7:0] counter_r = 8'd0;

   // These are the values sent by the controller to respond to
   // not internal values
   reg [6:0] address_r;
   reg 	     rw_r;
   reg [7:0] register_id_r;
   reg [7:0] register_value_r;

   always @(posedge scl_i or negedge scl_i or negedge started) begin
      if (~started) begin
	 state <= RECV_ADDRESS;
	 counter_r <= 0;
      end else begin
	 if (~scl_i) begin // Negative edge, get ready for clock
	    case (state)
	      COUNTER: begin
		 counter_r <= counter_r + 1'b1;
		 sda_r <= counter_r[0] ? 1'bz : 1'b0;
	      end

	      RECV_ADDRESS: counter_r <= counter_r + 1'b1;
	      RECV_REGISTER_ID: counter_r <= counter_r + 1'b1;
	      RECV_REGISTER_VALUE: counter_r <= counter_r + 1'b1;
	      SEND_REGISTER_VALUE: begin
		 counter_r <= counter_r + 1'b1;
		 sda_r <= register_value_r[7] ? 1'bz : 1'b0;
		 register_value_r <= {register_value_r[6:0], 1'b0};
	      end
	      
	      
	      ACK: sda_r <= 1'b0; // For now always ACK
	      
	      endcase // case (state)
	    
	 end else begin // Positive edge, change state with good counter count
	    case (state)
	      COUNTER: if (counter_r == 8) state <= IGNORE;

	      RECV_ADDRESS: begin
		 address_r <= {address_r[5:0], sda_io};
		 if (counter_r == 7) state <= RECV_RW;
	      end

	      RECV_RW: begin
		 rw_r <= sda_io;
		 post_ack_state <= RECV_REGISTER_ID;
		 state <= ACK;
		 counter_r <= 8'b0;
	      end

	      RECV_REGISTER_ID: begin
		 register_id_r <= {register_id_r[6:0], sda_io};
		 if (counter_r == 8) begin
		    counter_r <= 8'd0;

		    if (rw_r) post_ack_state <= SEND_REGISTER_VALUE;
		    else post_ack_state <= RECV_REGISTER_VALUE;
		    
		    state <= ACK;
		 end
		 
	      end

	      RECV_REGISTER_VALUE: begin
		 register_value_r <= {register_value_r[6:0], sda_io};
		 if (counter_r == 8) begin
		    counter_r <= 8'd0;

		    // Assume we only get one byte, don't check to
		    // see if controller is sending more.
		    state <= IGNORE; 
		 end
	      end

	      SEND_REGISTER_VALUE: begin
		 if (counter_r == 8) begin
		    sda_r <= 1'bz; // Release SDA
		    counter_r <= 8'b0;
		    state <= IGNORE;
		 end
	      end
	      
	      ACK: begin
		 sda_r <= 1'bz; // Clear out ACK
		 state <= post_ack_state;

		 if(post_ack_state == SEND_REGISTER_VALUE) begin
		    // For now, swap nibbles
		    register_value_r <= {register_id_r[3:0], register_id_r[7:4]};
		 end
	      end
	      
	    endcase // case (state)
	    
	 end
      end
   end

endmodule // i2c
