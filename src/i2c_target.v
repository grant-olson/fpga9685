module i2c_target
  (
   input        clk_i,
   input        rst_ni,
   
   input [6:0]  assigned_address_i, // This is the address we respond to.

   input        scl_i,
   inout        sda_io,

   // To track state with a hardware logic analyzer
   // for debugging. Not needed when not debugging
   output       dbg_start_o,
   output [3:0] dbg_state_o
   
   );


   reg          sda_r = 1'bz;
   assign sda_io = sda_r;


   // We need to catch start/stop conditions, and we need to
   // do work on both SCL positive and negative edges. so lets
   // set up some stuff to track that state here.
   reg              last_scl_r;
   reg              last_sda_r;

   wire      scl_edge;
   assign scl_edge = (last_scl_r ^ scl_i) ;

   wire      sda_edge;
   assign sda_edge = (last_sda_r ^ sda_io);

   wire      start_stop_edge;
   assign start_stop_edge = scl_i & sda_edge;
   assign dbg_start_o = start_stop_edge;
   
   always @(posedge clk_i) begin
      // Update last states to catch edges
      last_sda_r <= sda_io;
      last_scl_r <= scl_i;
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
   localparam GET_ACK = 8'd9;
   
   
   reg [7:0] state = RECV_ADDRESS;
   reg [7:0] post_ack_state;

   assign dbg_state_o = state[3:0];
   
   
   reg [7:0] counter_r = 8'd0;

   // These are the values sent by the controller to respond to
   // not internal values
   reg [6:0] address_r;
   reg              rw_r;
   reg [7:0] register_id_r;
   reg [7:0] register_value_r;

   
   always @(posedge clk_i) begin
      if (scl_edge) begin
         if (~scl_i) begin // Negative edge, get ready for clock
            case (state)
              IGNORE: sda_r <= 1'bz; // Release SDA

              COUNTER: begin
                 counter_r <= counter_r + 1'b1;
                 sda_r <= counter_r[0] ? 1'bz : 1'b0;
              end

              RECV_ADDRESS: begin
                 sda_r <= 1'bz; // Start condtion initialization
                 counter_r <= counter_r + 1'b1;
              end
              
              RECV_REGISTER_ID: begin
                 sda_r <= 1'bz; // Clear out ACK
                 counter_r <= counter_r + 1'b1;
              end
              
              RECV_REGISTER_VALUE: begin
                 sda_r <= 1'bz; // Clear out ACK
                 counter_r <= counter_r + 1'b1;
              end
              SEND_REGISTER_VALUE: begin
                 counter_r <= counter_r + 1'b1;
                 sda_r <= register_value_r[7] ? 1'bz : 1'b0;
                 register_value_r <= {register_value_r[6:0], 1'b0};
              end
              
              ACK: sda_r <= 1'b0; // For now always ACK

              GET_ACK: sda_r <= 1'bz; // CLEAR SDA
              
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

                 // TODO: Read up on this. Needed this to work with
                 // i2cget, and only figured it out by using a logic
                 // analyzer to track states.
                 if (sda_io) post_ack_state <= SEND_REGISTER_VALUE;
                 else post_ack_state <= RECV_REGISTER_ID;

                 // Check that it's talking to us
                 if (address_r == assigned_address_i) state <= ACK;
                 else state <= IGNORE;
                 
                 counter_r <= 8'b0;
              end

              RECV_REGISTER_ID: begin
                 register_id_r <= {register_id_r[6:0], sda_io};
                 if (counter_r == 8) begin
                    counter_r <= 8'd0;

                    // 1 - READ - SEND TO CONTROLLER
                    // 0 - WRITE - READ FROM CONTROLLER
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
                    post_ack_state <= RECV_ADDRESS;
                    state <= ACK; 
                 end
              end

              SEND_REGISTER_VALUE: begin
                 if (counter_r == 8) begin
                    counter_r <= 8'b0;
                    state <= GET_ACK;
                 end
              end

              GET_ACK: begin
                 state <= IGNORE; // We don't want repeated options, just stop
              end
              
              ACK: begin
                 state <= post_ack_state;

                 if(post_ack_state == SEND_REGISTER_VALUE) begin
                    // For now, swap nibbles
                    register_value_r <= {register_id_r[3:0], register_id_r[7:4]};
                 end
              end
              
            endcase // case (state)
            
         end // else: !if(~scl_i)
      end // if (scl_edge)
      else if (start_stop_edge) begin
         counter_r <= 0;
         
         if (sda_io) state <= IGNORE; // Went LOW to HIGH - STOP
         else state <= RECV_ADDRESS; // HIGH to LOW - START
      end
      
   end // always @ (posedge clk_i)
   

endmodule // i2c

module top
  (
   input clk_i,
   input rst_ni,
   input scl_i,
   inout sda_io,

   output dbg_start_o,
   output [3:0] dbg_state_o
   
   );

   i2c_target ic2(
                  .clk_i(clk_i),
                  .rst_ni(rst_ni),
                  .assigned_address_i(7'b1110000),
                  .scl_i(scl_i),
                  .sda_io(sda_io),
                  // To track state with a hardware logic analyzer
                  // for debugging. Not needed when not debugging
                  .dbg_start_o(dbg_start_o),
                  .dbg_state_o(dbg_state_o)
                  );
   
                  
endmodule // top


