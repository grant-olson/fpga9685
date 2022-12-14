/* I2C uses open drain for SDA so that any server or client can pull
 the clock low. The code we're writing compiles, but we want to make sure
 that it actually implements open drain logic.
 
 In addition to that our IDE configures the Open Drain logic outside
 of verilog itself as a .cst file. So even if the code is written correctly
 we need to make sure the GPIO pins are configured correctly as well.
 
 We'll make two pins that are inout pins and excercise them a bit. Since
 we need to test the HARDWARE configuration we can't run this as a testbench.
 We need to deploy the bitstream and physically wire pins together.
 
 We should be able to have one pin pull the line low, and the other
 get the message, and vice versa.
 
 Test 1: Pin 0 pulls down five times, if pin one reads this it lights
    an LED and moves to the next state.
 
 Test 2: Same with pins reversed. Different LED.
 
 Test 3: A button press causes Pin 0 to pull down the wire. Pin 1 lights
     a third LED.
  */

module open_drain_pin
  #(
    parameter tick_interval = 32'd27000000
    )
  (
   input      clk_i,
   input      rst_ni,

   input      listen_first_i,

   output led_recv_o,
   output reg led_done_o = 1'b1,
   
   inout      pin_io
   );

   localparam INIT = 3'd0;
   localparam LISTEN = 3'd1;
   localparam TALK = 3'd2;
   localparam IDLE = 3'd3;
   localparam WAIT = 3'd4;
   
   
   reg [2:0]  state = INIT;

   
   reg [2:0] listen_counter = 3'b000;
   
   reg [32:0] tick_counter = 32'd0;
   reg [2:0]  talk_counter = 3'b000;

   reg 	      pin_r = 1'bz;

   reg 	      last_pin_io = 1'b1;
	      
   
   initial begin
      state <= INIT;
      listen_counter <= 3'd0;
      tick_counter <= 32'd0;
      talk_counter <= 3'd0;
      pin_r <= 1'bz;
      last_pin_io <= 1'b0;
      
   end
   
   assign pin_io = pin_r;
   assign led_recv_o = pin_io;
   
   always @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
	 state <= INIT;
	 tick_counter <= 32'd0;
	 listen_counter <= 3'd0;
	 talk_counter <= 3'd0;
	 pin_r <= 1'bz;
	 last_pin_io <= 1'b0;
	 
      end else begin
	last_pin_io <= pin_io;
	case(state)
	  INIT: begin
	     led_done_o <= 1'b1;
	     tick_counter <= 32'b0;
	     talk_counter <= 3'd0;
	     listen_counter <= 3'd0;
	     
	     pin_r <= 1'bz;
	     state <= WAIT;
	     
	  end
	  WAIT: begin 
	     tick_counter <= tick_counter + 1'b1;

	     if (tick_counter >= tick_interval) begin
		state <= (listen_first_i) ? LISTEN : TALK;
		tick_counter <= 32'd0;
	     end		
	  end
	  
	  LISTEN: begin
	     if (listen_counter >= 3'd5) begin
		state <= (listen_first_i) ? TALK : IDLE;
		led_done_o <= 1'b0;
	     end
	     else if ((pin_io == 1'b1) && (last_pin_io == 1'b0)) begin
		listen_counter <= listen_counter + 1'b1;
	     end
	  end

	  IDLE: begin
	  end
	  TALK: begin
	     if (talk_counter >= 3'd5) begin
		pin_r <= 1'bz;
		state <= (listen_first_i) ? IDLE : LISTEN;
		tick_counter <= 32'd0;
		
	     end else begin
		if (tick_counter < tick_interval / 2'd2) begin
		   pin_r <= 1'bz;
		   tick_counter <= tick_counter + 1'b1;
		end else if (tick_counter < tick_interval) begin
		   pin_r <= 1'b0;
		   tick_counter <= tick_counter + 1'b1;
		end else begin
		   pin_r <= 1'bz;
		   talk_counter <= talk_counter + 1'b1;
		   tick_counter <= 32'd0;
		end
	     end
	  end	    
	  
	endcase // case (state)
      end // else: !if(~rst_ni)
      
   
   end

endmodule // open_drain_pin

module test_open_drain
  #(
    parameter tick_interval = 32'd27000000
    )
(
 input clk_i,
 input rst_ni,

 inout pin1_io,
 inout pin2_io,

 output led_recv_1_o,
 output led_done_1_o,

 output led_recv_2_o,
 output led_done_2_o
 
);

   open_drain_pin #(
		    .tick_interval(tick_interval)
		    ) p1 (
			  .clk_i(clk_i),
			  .rst_ni(rst_ni),
			  .listen_first_i(1'b1),
			  .pin_io(pin1_io),
			  .led_recv_o(led_recv_1_o),
			  .led_done_o(led_done_1_o)
			  );
   
   
   open_drain_pin#(
		    .tick_interval(tick_interval)
		    ) p2 (
			  .clk_i(clk_i),
			  .rst_ni(rst_ni),
			  .listen_first_i(1'b0),
			  .pin_io(pin2_io),
			  .led_recv_o(led_recv_2_o),
			  .led_done_o(led_done_2_o)
			  );
   
   
endmodule // open_drain_test
