`timescale 1ns/1ns

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

/* module both_edge_test
  (
   input clk_i,
   input rst_ni
   );

   localparam NEG = 1'b0;
   localparam POS = 1'b1;

   reg 	 state = NEG;
   
   always @(posedge clk_i or negedge clk_i or rst_ni) begin
      if (~rst_ni) state <= ~NEG;
      
      else if (~clk_i)
	state <= NEG;
      else
	state <= POS;

   end
   
endmodule // both_edge_test
*/


// Initial dummy test
// 1. Keep clock disabled, so its high.
// 2. Load data? Or hardcode for now.
// 3. Trigger start of data transmission.
// 4. Take SDA LOW while SCL is HIGH.
// 5. Enable Clock.
// 6. Process eight clock cycles, sending out data.
// 7. Disable clock after last transmission, in a way that's synced up, and HIGH.
// 8. Release SDA taking it HIGH 
module i2c_controller
  (
   input  clk_i,
   input  rst_ni,

   input [6:0] 	    address_i,
   input 	    rw_i,
   input [7:0] 	    register_id_i,
   input [7:0] 	    register_value_i,
   output reg [7:0] register_value_o,

   input 	    execute_i,
   
   output scl_o,
   inout  sda_io
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
   localparam RECV_REGSITER_VALUE = 8'd8;
   localparam GET_ACK = 8'd9;
   localparam NACK = 8'd10;
   
   
   reg [7:0] state = WAITING;
   reg [7:0] post_ack_state = WAITING;
   
   assign scl_o = (state <= STOP) ? 1'bz : int_clk_w;
   
   reg [7:0] counter_r = 8'd0;

   always @(posedge int_clk_w or negedge int_clk_w) begin
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
	      if (counter_r >= 2) begin
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
	      post_ack_state <= SEND_REGISTER_ID;
	   end

	   SEND_REGISTER_ID: begin
	      if (counter_r == 8) begin
		 state <= GET_ACK;
		 post_ack_state <= SEND_REGISTER_VALUE;
	      end
	   end

	   SEND_REGISTER_VALUE: begin
	      if (counter_r == 8) begin
		 state <= GET_ACK;
		 post_ack_state <= STOP;
	      end
	   end

	   GET_ACK: begin
	      // For now, assume we're good.
	      counter_r <= 8'b0;
	      state <= post_ack_state;
	   end
	       
	   
	 endcase // case (state)
      
      end
      
      
      
   end
   
   
endmodule // i2c_controller


module top
  (
   );

   reg clk_r = 1'b0;
   reg rst_nr = 1'b1;

   wire i2c_scl, i2c_sda;
   pullup(i2c_scl);
   pullup(i2c_sda);
   
   
   always #1 clk_r = ~clk_r;

   i2c_controller i2c_c1 (
			  .clk_i(clk_r),
			  .rst_ni(rst_nr),

			  .address_i(7'b1110000),
			  .rw_i(1'b1),
			  .register_id_i(8'hDE),
			  .register_value_i(8'h4D),
			  
			  .scl_o(i2c_scl),
			  .sda_io(i2c_sda)
			  );


   
   initial begin
      $display("Starting Testbench...");
      #20 rst_nr <= 1;
      #5 rst_nr <= 0;
      #20 rst_nr <= 1;

      #2000;
      
      
      
      $finish();
   end

   initial begin
      $dumpfile("output/i2c_test_dump.vcd");
      $dumpvars(3);
   end
   

   
endmodule // top
