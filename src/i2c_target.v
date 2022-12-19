module i2c_target
  (
   input clk_i,
   input rst_ni,
   
   input address5_i,
   input address4_i,
   input address3_i,
   input address2_i,
   input address1_i,
   input address0_i,

   input scl_i,
   inout sda_io
   
   );

   localparam IDLE = 4'd0;
   localparam START = 4'd1;
   localparam RECV_BYTE = 4'd2;
   localparam ACK = 4'd3;
   localparam FINALIZE_B1 = 4'd4;
   localparam FINALIZE_B2 = 4'd5;
   localparam FINALIZE_B3 = 4'd6;
   localparam SEND_BYTE = 4'd7;
   
   reg [3:0] state = IDLE;
   reg [7:0] bit_counter = 0;
   reg [3:0] byte_counter = 0;
   
   reg [7:0] buffer_r;

   reg [6:0] address_r;
   reg 	     rw_r;
   reg [7:0] register_r;
   reg [7:0] value_r;
   
   reg 	     sda_r = 1'bz;
   assign sda_io = sda_r;
   
   
   // The scl clock doesn't always run so we need to infer some of the
   // edges and states, rather than catching them in an always block.
   reg 	     last_scl;
   reg 	     last_sda;

   wire      start, stop;

   // controller moves SDA while SCL is HIGH to start and stop.
   // Actual data transitions for SDA will happen when clock is LOW.
   assign i2c_start = last_scl & scl_i & last_sda & ~sda_io;
   assign i2c_stop = last_scl & scl_i & ~last_sda & sda_io;

   wire      scl_posedge, scl_negedge;

   assign scl_posedge = ~last_scl & scl_i;
   assign scl_negedge = last_scl & ~scl_i;
   
   
   always @(posedge clk_i or negedge rst_ni) begin
      last_scl <= scl_i;
      last_sda <= sda_io;
      
      if (~rst_ni) begin
	 state <= IDLE;
	 buffer_r <= 8'd0;
      end else if (i2c_stop) state <= IDLE;
      else if (i2c_start) state <= START;
      else begin
	
	case (state)
	  START: begin
	     byte_counter <= 4'd0;
	     bit_counter <= 8'd0;
	     
	     state <= RECV_BYTE;
	   
	  end
	  
	  SEND_BYTE: begin
	     if (scl_posedge) bit_counter <= bit_counter + 1'b1;
	     else if (scl_negedge && bit_counter > 7) begin
		byte_counter <= byte_counter + 1'b1;
		bit_counter <= 1'b0;
		state <= ACK;
	     end
	     
	  end
	  
	  RECV_BYTE: begin
	     if (scl_posedge) begin
		buffer_r <= {buffer_r[7:0], sda_io};
		bit_counter <= bit_counter + 1'b1;
	     end else if (scl_negedge && bit_counter > 7) begin
		byte_counter <= byte_counter + 1'b1;
		bit_counter <= 8'b0;

		if (byte_counter == 0) begin
		   state <= FINALIZE_B1;
		end else if (byte_counter == 1) begin
		   state <= FINALIZE_B2;
		end else begin
		   state <= FINALIZE_B3;
		end
	     end
	     
	  end

	  FINALIZE_B1: begin
	     address_r <= buffer_r[7:1];
	     rw_r <= buffer_r[0];
	     state <= ACK;
	     
	  end

	  FINALIZE_B2: begin
	     register_r <= buffer_r;
	     state <= ACK;
	  end

	  FINALIZE_B3: begin
	     value_r <= buffer_r;
	     state <= ACK;
	  end
	  
	  ACK: begin
	     if(scl_posedge) begin
		sda_r <= 1'bz;
		if(byte_counter > 2) state <= IDLE;
		else if (byte_counter > 1 && ~rw_r) begin
		   state <= SEND_BYTE;
		   value_r <= 8'b10100101;
		end else state <= RECV_BYTE;
		
	     end else sda_r <= 1'b0;
	  end
	  
	  IDLE: begin
	     state <= IDLE;
	  end
	  
	
	
	endcase // case (state)
      end // else: !if(i2c_start)
   end // always @ (posedge clk_i or negedge rst_ni)
   

endmodule // i2c
