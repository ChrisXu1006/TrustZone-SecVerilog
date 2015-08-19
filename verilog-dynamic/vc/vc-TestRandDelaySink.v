//========================================================================
// Verilog Components: Test Sink with Random Delays
//========================================================================

`ifndef VC_TEST_RAND_DELAY_SINK_V
`define VC_TEST_RAND_DELAY_SINK_V

`include "vc-TestSink.v"
`include "vc-TestRandDelay.v"

module vc_TestRandDelaySink
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024
)(
  input                   clk,
  input                   reset,

  // Max delay input

  input [31:0]            max_delay,

  // Sink message interface

  input                   val,
  output                  rdy,
  input [p_msg_nbits-1:0] msg,

  // Keeps track of how many messages failed

  output [31:0]           num_failed,

  // Goes high once all sink data has been received

  output                  done
);

  //----------------------------------------------------------------------
  // Test random delay
  //----------------------------------------------------------------------

  wire                   sink_val;
  wire                   sink_rdy;
  wire [p_msg_nbits-1:0] sink_msg;

  vc_TestRandDelay#(p_msg_nbits) rand_delay
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (max_delay),

    .in_val    (val),
    .in_rdy    (rdy),
    .in_msg    (msg),

    .out_val   (sink_val),
    .out_rdy   (sink_rdy),
    .out_msg   (sink_msg)
  );

  //----------------------------------------------------------------------
  // Test sink
  //----------------------------------------------------------------------

  vc_TestSink#(p_msg_nbits,p_num_msgs) sink
  (
    .clk        (clk),
    .reset      (reset),

    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),

    .num_failed (num_failed),
    .done       (done)
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

`endif /* VC_TEST_RAND_DELAY_SINK */

