module i2c_clock
  #( parameter ticks_per_clock=27//0 // 27 Mhz / 100Khz
     )
   (
    input      clk_i,
    input      rst_ni,
    output reg clock_ro = 1'b1
    );

   reg [11:0]  counter_r = 12'b0;

   
   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
	 clock_ro <= 1'b1;
	 counter_r <= 12'd0;
      end else begin
	 if (counter_r < ticks_per_clock / 2) clock_ro <= 1'b1;
	 else if (counter_r < ticks_per_clock) clock_ro <= 1'b0;
      
	 if (counter_r > ticks_per_clock) counter_r <= 12'b0;
	 else counter_r <= counter_r + 1'b1;
      end
      
      
   end
   
endmodule // i2c_clock

module i2c_controller
  (
   input 	    clk_i,
   input 	    rst_ni,

   input [6:0] 	    address_i,
   input 	    rw_i,
   input [7:0] 	    register_id_i,
   input [7:0] 	    register_value_i, // In - writing TO target
   output reg [7:0] register_value_ro, // out - reading FROM target

   input 	    execute_i,
   output 	    busy_o,
   
   output 	    scl_o,
   inout 	    sda_io
   );


   
   // We do a bunch of register shifting, so store
   // values internally and preserve external values.
   reg [6:0] address_r;
   reg 	     rw_r;
   reg [7:0] register_id_r;
   reg [7:0] register_value_in_r;
   reg [7:0] register_value_out_r;
   
   wire   int_clk_w;
   
   reg 	  sda_r = 1'bz;
   assign sda_io = sda_r;
   
   i2c_clock i2c_clk (
		      .clk_i(clk_i),
		      .rst_ni(rst_ni),
		     .clock_ro(int_clk_w)
		      
		      );

   // Internal states, clock doesn't get propogated
   localparam WAITING = 8'd0;
   localparam START = 8'd1;
   localparam STOP = 8'd2;
   
   // External states, we send this clock to targets
   localparam COUNTER = 8'd3; // For testing.
   localparam SEND_ADDRESS = 8'd4;
   localparam SEND_RW = 8'd5;
   localparam SEND_REGISTER_ID = 8'd6;
   localparam SEND_REGISTER_VALUE = 8'd7;
   localparam RECV_REGISTER_VALUE = 8'd8;
   localparam GET_ACK = 8'd9;
   localparam NACK = 8'd10;
   
   
   reg [7:0] state = WAITING;
   reg [7:0] post_ack_state = WAITING;
   
   assign scl_o = (state <= STOP) ? 1'bz : int_clk_w;
   assign busy_o = state != WAITING;
    
   reg [7:0] counter_r = 8'd0;

   reg              last_int_clk_r;

   wire      int_clk_edge;
   assign int_clk_edge = (last_int_clk_r ^ int_clk_w) ;

   always @(posedge clk_i) begin
      // Update last states to catch edges
      last_int_clk_r <= int_clk_w;
   end
   
   // And with that out of the way on to the real FSM
   
   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin // reset
      end else if (int_clk_edge) begin
         if (~int_clk_w) begin // Negative edge, prep for data send
	    case (state)
	      WAITING: counter_r <= counter_r + 1'b1;
	      
	      START: begin
	         address_r <= address_i;
	         rw_r <= rw_i;
	         register_id_r <= register_id_i;
	         register_value_in_r <= register_value_i;
	         register_value_out_r <= 8'b00000000;
	         
	         counter_r <= counter_r + 1'b1;
	         sda_r <= 1'b0; // Pull low BEFORE clock is enabled
	      end
	      
	      COUNTER: counter_r <= counter_r + 1'b1;

	      SEND_ADDRESS: begin
	         counter_r <= counter_r + 1'b1;

	         sda_r <= address_r[6] ? 1'bz : 1'b0;
	         address_r <= {address_r[5:0], 1'b0};
	      end

	      SEND_RW: sda_r <= rw_r ? 1'bz : 1'b0;

	      SEND_REGISTER_ID: begin
	         counter_r <= counter_r + 1'b1;
	         sda_r <= register_id_r[7] ? 1'bz : 1'b0;
	         register_id_r <= {register_id_r[6:0], 1'b0};
	      end

	      SEND_REGISTER_VALUE: begin
	         counter_r <= counter_r + 1'b1;
	         sda_r <= register_value_in_r[7] ? 1'bz : 1'b0;
	         register_value_in_r <= {register_value_in_r[6:0], 1'b0};
	      end

	      RECV_REGISTER_VALUE: begin
	         sda_r <= 1'bz; // Release SDA
	         counter_r <= counter_r + 1'b1;
	      end
	      
	      
	      GET_ACK: sda_r <= 1'bz; // Release SDA to Target
	      
	      STOP: begin
	         sda_r <= 1'bz;
	         state <= WAITING;

	      end
	    endcase // case (state)
	    
         end else begin  
	    // Positive edge, deal with counters here so we don't
	    // need to think about off by one errors before
	    // registers lock in new values.
	    case (state)
	      WAITING: begin
	         if (execute_i) begin
		    state <= START;
		    counter_r <= 8'b0;
	         end
	      end

	      START: begin
	         if (counter_r >= 2) begin
		    state <= SEND_ADDRESS;
		    counter_r <= 8'b0;
	         end
	      end

	      COUNTER: begin
	         if (counter_r == 8) state <= STOP;
	      end

	      SEND_ADDRESS: begin
	         if (counter_r == 7) begin
		    state <= SEND_RW;
		    counter_r <= 8'b0;
	         end
	         
	      end

	      SEND_RW: begin
	         counter_r <= 8'b0;
	         state <= GET_ACK;
                 if (~rw_r) post_ack_state <= SEND_REGISTER_ID;
                 else post_ack_state <= RECV_REGISTER_VALUE;
	      end

	      SEND_REGISTER_ID: begin
	         if (counter_r == 8) begin
		    state <= GET_ACK;
		    // LOW RW == WRITE
		    post_ack_state <= SEND_REGISTER_VALUE;
	         end
	      end

	      SEND_REGISTER_VALUE: begin
	         if (counter_r == 8) begin
		    state <= GET_ACK;
		    post_ack_state <= STOP;
	         end
	      end

	      RECV_REGISTER_VALUE: begin
	         register_value_out_r <= {register_value_out_r[6:0], sda_io};

	         if (counter_r == 8) begin
		    state <= GET_ACK;
		    post_ack_state <= STOP;
		    
	         end
	      end

	      GET_ACK: begin
	         // For now, assume we're good.
	         counter_r <= 8'b0;

	         
	         if (post_ack_state == STOP) begin
		    sda_r <= 1'b0; // Pull this down so we can release it after stopping clock.
		    // Send out register value
		    if (rw_r) register_value_ro <= register_value_out_r;
	         end
	         

	         
	         state <= post_ack_state;
	      end // case: GET_ACK
              
	      
	      
	    endcase // case (state)
            
         end // else: !if(~scl_io)
         
         
         
         
      end // if (start_stop_edge)
   end // always @ (posedge clk_i or negedge rst_ni)
   
   
endmodule // i2c_controller
