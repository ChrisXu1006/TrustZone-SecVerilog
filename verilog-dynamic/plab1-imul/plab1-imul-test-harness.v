//=========================================================================
// IntMul Unit Test Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define PLAB1_IMUL_IMPL     plab1_imul_Impl
//  `define PLAB1_IMUL_IMPL_STR "plab1-imul-Impl"
//
//  `include "plab1-imul-Impl.v"
//  `include "plab1-imul-test-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input         clk,
  input         reset,
  input  [31:0] src_max_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] src_msg;
  wire                                        src_val;
  wire                                        src_rdy;
  wire                                        src_done;

  wire [31:0]                                 sink_msg;
  wire                                        sink_val;
  wire                                        sink_rdy;
  wire                                        sink_done;

  vc_TestRandDelaySource#(`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS) src
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (src_max_delay),

    .val        (src_val),
    .rdy        (src_rdy),
    .msg        (src_msg),

    .done       (src_done)
  );

  `PLAB1_IMUL_IMPL imul
  (
    .clk        (clk),
    .reset      (reset),

    .in_msg     (src_msg),
    .in_val     (src_val),
    .in_rdy     (src_rdy),

    .out_msg    (sink_msg),
    .out_val    (sink_val),
    .out_rdy    (sink_rdy)
  );

  vc_TestRandDelaySink#(32) sink
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (sink_max_delay),

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
    imul.trace_module( trace );
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `PLAB1_IMUL_IMPL_STR )

  // Not really used, but the python-generated verilog will set this

  integer num_inputs;

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

  // Helper task to initialize sorce sink

  task init
  (
    input [ 9:0] i,
    input [31:0] a,
    input [31:0] b,
    input [31:0] result
  );
  begin
    th.src.src.m[i]   = { `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL, a, b };
    th.sink.sink.m[i] = result;
  end
  endtask

  // Helper task to initialize source/sink

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

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
  // Test Case: small positive * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "small positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, 32'd03, 32'd6   );
    init( 1, 32'd04, 32'd05, 32'd20  );
    init( 2, 32'd03, 32'd04, 32'd12  );
    init( 3, 32'd10, 32'd13, 32'd130 );
    init( 4, 32'd08, 32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: small negative * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "small negative * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'd02, 32'd03, -32'd6   );
    init( 1, -32'd04, 32'd05, -32'd20  );
    init( 2, -32'd03, 32'd04, -32'd12  );
    init( 3, -32'd10, 32'd13, -32'd130 );
    init( 4, -32'd08, 32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: small positive * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "small positive * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, -32'd03, -32'd6   );
    init( 1, 32'd04, -32'd05, -32'd20  );
    init( 2, 32'd03, -32'd04, -32'd12  );
    init( 3, 32'd10, -32'd13, -32'd130 );
    init( 4, 32'd08, -32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: small negative * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "small negative * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, -32'd02, -32'd03, 32'd6   );
    init( 1, -32'd04, -32'd05, 32'd20  );
    init( 2, -32'd03, -32'd04, 32'd12  );
    init( 3, -32'd10, -32'd13, 32'd130 );
    init( 4, -32'd08, -32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: large positive * positive
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "large positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'h0bcd0000, 32'h0000abcd, 32'h62290000 );
    init( 1, 32'h0fff0000, 32'h0000ffff, 32'hf0010000 );
    init( 2, 32'h0fff0000, 32'h0fff0000, 32'h00000000 );
    init( 3, 32'h04e5f14d, 32'h7839d4fc, 32'h10524bcc );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: large negative * negative
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "large negative * negative" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'h80000001, 32'h80000001, 32'h00000001);
    init( 1, 32'h8000abcd, 32'h8000ef00, 32'h20646300);
    init( 2, 32'h80340580, 32'h8aadefc0, 32'h6fa6a000);
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random small
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "random small" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "random large" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random lomask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "random lomask" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_lomask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random himask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "random himask" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_himask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random lohimask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "random lohimask" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_lohimask.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random himask
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 12, "random sparse" )
  begin
    init_rand_delays( 0, 0 );
    `include "plab1-imul-input-gen_sparse.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random small w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 13, "random small w/ random delays" )
  begin
    init_rand_delays( 3, 14 );
    `include "plab1-imul-input-gen_small.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: random large w/ random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 14, "random large w/ random delays" )
  begin
    init_rand_delays( 3, 14 );
    `include "plab1-imul-input-gen_large.py.v"
    run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

