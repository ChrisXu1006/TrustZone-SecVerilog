//========================================================================
// Verilog Components: Test Source with Random Delays
//========================================================================

`ifndef VC_TEST_RAND_DELAY_SOURCE_V
`define VC_TEST_RAND_DELAY_SOURCE_V

`include "vc-TestSource.v"
`include "vc-TestRandDelay.v"

module vc_TestRandDelaySource
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024
)(
  input                    clk,
  input                    reset,

  // Max delay input

  input [31:0]             max_delay,

  // Source message interface

  output                   val,
  input                    rdy,
  output [p_msg_nbits-1:0] msg,

  // Goes high once all source data has been issued

  output                   done
);

  //----------------------------------------------------------------------
  // Test source
  //----------------------------------------------------------------------

  wire                   src_val;
  wire                   src_rdy;
  wire [p_msg_nbits-1:0] src_msg;

  vc_TestSource#(p_msg_nbits,p_num_msgs) src
  (
    .clk       (clk),
    .reset     (reset),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (done)
  );

  //----------------------------------------------------------------------
  // Test random delay
  //----------------------------------------------------------------------

  vc_TestRandDelay#(p_msg_nbits,p_max_delay_nbits) rand_delay
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (max_delay),

    .in_val    (src_val),
    .in_rdy    (src_rdy),
    .in_msg    (src_msg),

    .out_val   (val),
    .out_rdy   (rdy),
    .out_msg   (msg)
  );

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

`endif /* VC_TEST_RAND_DELAY_SOURCE */

