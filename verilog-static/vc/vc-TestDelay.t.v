//========================================================================
// vc-TestDelay Unit Tests
//========================================================================

`include "vc-TestSource.v"
`include "vc-TestSink.v"
`include "vc-TestDelay.v"
`include "vc-test.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_msg_nbits = 8
)(
  input         clk,
  input         reset,
  input  [31:0] delay_amt,
  output [31:0] num_failed,
  output        done
);

  wire                   src_val;
  wire                   src_rdy;
  wire [p_msg_nbits-1:0] src_msg;
  wire                   src_done;

  vc_TestSource#(p_msg_nbits) src
  (
    .clk          (clk),
    .reset        (reset),
    .val          (src_val),
    .rdy          (src_rdy),
    .msg          (src_msg),
    .done         (src_done)
  );

  wire                   sink_val;
  wire                   sink_rdy;
  wire [p_msg_nbits-1:0] sink_msg;

  vc_TestDelay#(p_msg_nbits) delay
  (
    .clk          (clk),
    .reset        (reset),
    .delay_amt    (delay_amt),
    .in_val       (src_val),
    .in_rdy       (src_rdy),
    .in_msg       (src_msg),
    .out_val      (sink_val),
    .out_rdy      (sink_rdy),
    .out_msg      (sink_msg)
  );

  wire sink_done;

  vc_TestSink#(p_msg_nbits) sink
  (
    .clk        (clk),
    .reset      (reset),
    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),
    .num_failed (num_failed),
    .done       (sink_done)
  );

  assign done = src_done && sink_done;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src.trace_module( trace );
    vc_trace_str( trace, " > " );
    delay.trace_module( trace );
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-TestDelay" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  reg         th_reset = 1;
  reg  [31:0] th_delay_amt;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness th
  (
    .clk        (clk),
    .reset      (th_reset),
    .delay_amt  (th_delay_amt),
    .num_failed (th_num_failed),
    .done       (th_done)
  );

  // Load source/sinks

  initial begin
    `define SRC_MEM  th.src.m
    `define SINK_MEM th.sink.m
    `include "vc-test-src-sink-input-gen_ordered.py.v"
  end

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 5000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // Test Case: delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "delay = 0" )
  begin
    th_delay_amt = 0;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: delay = 1
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "delay = 1" )
  begin
    th_delay_amt = 1;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: delay = 2
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "delay = 2" )
  begin
    th_delay_amt = 2;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "delay = 10" )
  begin
    th_delay_amt = 10;
    run_test();
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

