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

   localparam PREP = 3'd0;
   localparam RECV_DEV_ADDR = 3'd1;
   localparam RECV_RW = 3'd2;
   localparam IGNORE = 3'd3;
   
   reg [2:0] state = PREP;
   reg [7:0] counter = 0;
   reg [6:0] address;
   reg 	     rw;

   always @(posedge scl_i or negedge rst_ni) begin
      if (~rst_ni) begin
	 state <= PREP;
	 address <= 6'd0;
      end else
	
	case (state)
	  PREP: begin
	     counter <= 0;
	     state <= RECV_DEV_ADDR;
	   
	  end
	  RECV_DEV_ADDR: begin
	     address <= {address[5:0], sda_io};

	     if (counter >= 5) state <= RECV_RW;
	     else counter <= counter + 1'b1;
	  end

	  RECV_RW: begin
	     rw <= sda_io;
	     state <= IGNORE;
	  end

	  IGNORE: state <= IGNORE;
	
	
	endcase // case (state)
   end

endmodule // i2c
