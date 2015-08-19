//========================================================================
// Verilog Components: Test Source
//========================================================================

`ifndef VC_TEST_SOURCE_V
`define VC_TEST_SOURCE_V

`include "vc-regs.v"

module vc_TestSource
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024
)(
  input  clk,
  input  reset,

  // Source message interface

  output                   val,
  input                    rdy,
  output [p_msg_nbits-1:0] msg,

  // Goes high once all source msgs has been issued

  output done
);

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  // Size of a physical address for the memory in bits

  localparam c_index_nbits = $clog2(p_num_msgs);

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  // Memory which stores messages to send

  reg [p_msg_nbits-1:0] m[p_num_msgs-1:0];

  // Index register pointing to next message to send

  wire                     index_en;
  wire [c_index_nbits-1:0] index_next;
  wire [c_index_nbits-1:0] index;

  vc_EnResetReg#(c_index_nbits,{c_index_nbits{1'b0}}) index_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (index_en),
    .d     (index_next),
    .q     (index)
  );

  // Register reset

  reg reset_reg;
  always @( posedge clk )
    reset_reg <= reset;

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // We use a behavioral hack to easily detect when we have gone off the
  // end of the valid messages in the memory.

  assign done = !reset_reg && ( m[index] === {p_msg_nbits{1'bx}} );

  // Set the source message appropriately

  assign msg = m[index];

  // Source message interface is valid as long as we are not done

  assign val = !reset_reg && !done;

  // The go signal is high when a message is transferred

  wire go = val && rdy;

  // We bump the index pointer every time we successfully send a message,
  // otherwise the index stays the same.

  assign index_en   = go;
  assign index_next = index + 1'b1;

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( val );
      `VC_ASSERT_NOT_X( rdy );
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] msg_str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    $sformat( msg_str, "%x", msg );
    vc_trace_str_val_rdy( trace, val, rdy, msg_str );
  end
  endtask

endmodule

`endif /* VC_TEST_SOURCE_V */

