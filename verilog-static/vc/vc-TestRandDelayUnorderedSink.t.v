//========================================================================
// vc-TestRandDelayUnorderedSink Unit Tests
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelayUnorderedSink.v"
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
  input  [31:0] src_max_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  wire                   val;
  wire                   rdy;
  wire [p_msg_nbits-1:0] msg;

  wire                   src_done;
  wire                   sink_done;

  vc_TestRandDelaySource#(p_msg_nbits) src
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (src_max_delay),
    .val        (val),
    .rdy        (rdy),
    .msg        (msg),
    .done       (src_done)
  );

  vc_TestRandDelayUnorderedSink#(p_msg_nbits) sink
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (val),
    .rdy        (rdy),
    .msg        (msg),
    .num_failed (num_failed),
    .done       (sink_done)
  );

  assign done = src_done && sink_done;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src.trace_module( trace );
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-TestRandDelayUnorderedSink" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  reg         th_reset = 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  // Load source/sinks

  initial begin
    `define SRC_MEM  th.src.src.m
    `define SINK_MEM th.sink.sink.m
    `include "vc-test-src-sink-input-gen_unordered.py.v"
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
  // Test Case: src delay = 0, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "src delay = 0, sink delay = 0" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 0;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: src delay = 1, sink delay = 1
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "src delay = 1, sink delay = 1" )
  begin
    th_src_max_delay  = 1;
    th_sink_max_delay = 1;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: src delay = 2, sink delay = 2
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "src delay = 2, sink delay = 2" )
  begin
    th_src_max_delay  = 2;
    th_sink_max_delay = 2;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: src delay = 10, sink delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "src delay = 10, sink delay = 10" )
  begin
    th_src_max_delay  = 10;
    th_sink_max_delay = 10;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: src delay = 3, sink delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "src delay = 3, sink delay = 10" )
  begin
    th_src_max_delay  = 3;
    th_sink_max_delay = 10;
    run_test();
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: src delay = 10, sink delay = 3
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "src delay = 10, sink delay = 3" )
  begin
    th_src_max_delay  = 10;
    th_sink_max_delay = 3;
    run_test();
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

