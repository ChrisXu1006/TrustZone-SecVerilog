//========================================================================
// vc-queues Unit Tests
//========================================================================

`include "vc-queues.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-queues" )

  //----------------------------------------------------------------------
  // Test Case: simple queue w/ 1 entry
  //----------------------------------------------------------------------

  reg        t1_reset = 1;
  reg        t1_enq_val;
  wire       t1_enq_rdy;
  reg  [7:0] t1_enq_msg;
  wire       t1_deq_val;
  reg        t1_deq_rdy;
  wire [7:0] t1_deq_msg;

  vc_Queue#(`VC_QUEUE_NORMAL,8,1) t1_queue
  (
    .clk     (clk),
    .reset   (t1_reset),
    .enq_val (t1_enq_val),
    .enq_rdy (t1_enq_rdy),
    .enq_msg (t1_enq_msg),
    .deq_val (t1_deq_val),
    .deq_rdy (t1_deq_rdy),
    .deq_msg (t1_deq_msg)
  );

  // Helper task

  task t1
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t1_enq_val = enq_val;
    t1_deq_rdy = deq_rdy;
    t1_enq_msg = enq_msg;
    #1;
    t1_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t1_enq_rdy, enq_rdy );
    `VC_TEST_NET( t1_deq_msg, deq_msg );
    `VC_TEST_NET( t1_deq_val, deq_val );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple queue w/ 1 entry" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    // Enque one element and then dequeue it

    t1( 8'h01, 1, 1,  8'h??, 0, 1 );
    t1( 8'hxx, 0, 0,  8'h01, 1, 1 );
    t1( 8'hxx, 0, 1,  8'h??, 0, 0 );

    // Fill queue and then do enq/deq at same time

    t1( 8'h02, 1, 1,  8'h??, 0, 0 );
    t1( 8'h03, 1, 0,  8'h02, 1, 0 );
    t1( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t1( 8'h03, 1, 0,  8'h02, 1, 1 );
    t1( 8'h03, 1, 1,  8'h??, 0, 1 );
    t1( 8'h04, 1, 0,  8'h03, 1, 1 );
    t1( 8'h04, 1, 1,  8'h??, 0, 1 );
    t1( 8'hxx, 0, 0,  8'h04, 1, 1 );
    t1( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: pipe queue w/ 1 entry
  //----------------------------------------------------------------------

  reg        t2_reset = 1;
  reg  [7:0] t2_enq_msg;
  reg        t2_enq_val;
  wire       t2_enq_rdy;
  wire [7:0] t2_deq_msg;
  wire       t2_deq_val;
  reg        t2_deq_rdy;

  vc_Queue#(`VC_QUEUE_PIPE,8,1) t2_queue
  (
    .clk     (clk),
    .reset   (t2_reset),
    .enq_val (t2_enq_val),
    .enq_rdy (t2_enq_rdy),
    .enq_msg (t2_enq_msg),
    .deq_val (t2_deq_val),
    .deq_rdy (t2_deq_rdy),
    .deq_msg (t2_deq_msg)
  );

  // Helper task

  task t2
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t2_enq_msg = enq_msg;
    t2_enq_val = enq_val;
    t2_deq_rdy = deq_rdy;
    #1;
    t2_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t2_enq_rdy,  enq_rdy  );
    `VC_TEST_NET( t2_deq_msg, deq_msg );
    `VC_TEST_NET( t2_deq_val,  deq_val  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "pipe queue w/ 1 entry" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    // Enque one element and then dequeue it

    t2( 8'h01, 1, 1,  8'h??, 0, 1 );
    t2( 8'hxx, 0, 1,  8'h01, 1, 1 );
    t2( 8'hxx, 0, 1,  8'h??, 0, 0 );

    // Fill queue and then do enq/deq at same time

    t2( 8'h02, 1, 1,  8'h??, 0, 0 );
    t2( 8'h03, 1, 0,  8'h02, 1, 0 );
    t2( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t2( 8'h03, 1, 1,  8'h02, 1, 1 );
    t2( 8'h04, 1, 1,  8'h03, 1, 1 );
    t2( 8'hxx, 0, 1,  8'h04, 1, 1 );
    t2( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: bypass queue w/ 1 entry
  //----------------------------------------------------------------------

  reg        t3_reset = 1;
  reg  [7:0] t3_enq_msg;
  reg        t3_enq_val;
  wire       t3_enq_rdy;
  wire [7:0] t3_deq_msg;
  wire       t3_deq_val;
  reg        t3_deq_rdy;

  vc_Queue#(`VC_QUEUE_BYPASS,8,1) t3_queue
  (
    .clk     (clk),
    .reset   (t3_reset),
    .enq_val (t3_enq_val),
    .enq_rdy (t3_enq_rdy),
    .enq_msg (t3_enq_msg),
    .deq_val (t3_deq_val),
    .deq_rdy (t3_deq_rdy),
    .deq_msg (t3_deq_msg)
  );

  // Helper task

  task t3
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t3_enq_msg = enq_msg;
    t3_enq_val = enq_val;
    t3_deq_rdy = deq_rdy;
    #1;
    t3_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t3_enq_rdy,  enq_rdy  );
    `VC_TEST_NET( t3_deq_msg, deq_msg );
    `VC_TEST_NET( t3_deq_val,  deq_val  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "bypass queue w/ 1 entry" )
  begin

    #1;  t3_reset = 1'b1;
    #20; t3_reset = 1'b0;

    // Enque one element and then dequeue it

    t3( 8'h01, 1, 1,  8'h01, 1, 1 );
    t3( 8'hxx, 0, 1,  8'hxx, 0, 0 );

    // Fill queue and then do enq/deq at same time

    t3( 8'h02, 1, 1,  8'h02, 1, 0 );
    t3( 8'h03, 1, 0,  8'h02, 1, 0 );
    t3( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t3( 8'h03, 1, 0,  8'h02, 1, 1 );
    t3( 8'h03, 1, 1,  8'h03, 1, 1 );
    t3( 8'h04, 1, 1,  8'h04, 1, 1 );
    t3( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: simple queue w/ 3 entries
  //----------------------------------------------------------------------

  reg        t4_reset = 1;
  reg  [7:0] t4_enq_msg;
  reg        t4_enq_val;
  wire       t4_enq_rdy;
  wire [7:0] t4_deq_msg;
  wire       t4_deq_val;
  reg        t4_deq_rdy;

  vc_Queue#(`VC_QUEUE_NORMAL,8,3) t4_queue
  (
    .clk     (clk),
    .reset   (t4_reset),
    .enq_val (t4_enq_val),
    .enq_rdy (t4_enq_rdy),
    .enq_msg (t4_enq_msg),
    .deq_val (t4_deq_val),
    .deq_rdy (t4_deq_rdy),
    .deq_msg (t4_deq_msg)
  );

  // Helper task

  task t4
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t4_enq_msg = enq_msg;
    t4_enq_val = enq_val;
    t4_deq_rdy = deq_rdy;
    #1;
    t4_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t4_enq_rdy,  enq_rdy  );
    `VC_TEST_NET( t4_deq_msg, deq_msg );
    `VC_TEST_NET( t4_deq_val,  deq_val  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 4, "simple queue w/ 3 entries" )
  begin

    #1;  t4_reset = 1'b1;
    #20; t4_reset = 1'b0;

    // Enque one element and then dequeue it

    t4( 8'h01, 1, 1,  8'h??, 0, 1 );
    t4( 8'hxx, 0, 1,  8'h01, 1, 1 );
    t4( 8'hxx, 0, 1,  8'h??, 0, 0 );

    // Fill queue and then do enq/deq at same time

    t4( 8'h02, 1, 1,  8'h??, 0, 0 );
    t4( 8'h03, 1, 1,  8'h02, 1, 0 );
    t4( 8'h04, 1, 1,  8'h02, 1, 0 );
    t4( 8'h05, 1, 0,  8'h02, 1, 0 );
    t4( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t4( 8'h05, 1, 0,  8'h02, 1, 1 );
    t4( 8'h05, 1, 1,  8'h03, 1, 1 );
    t4( 8'h06, 1, 1,  8'h04, 1, 1 );
    t4( 8'h07, 1, 1,  8'h05, 1, 1 );
    t4( 8'hxx, 0, 1,  8'h06, 1, 1 );
    t4( 8'hxx, 0, 1,  8'h07, 1, 1 );
    t4( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: pipe queue w/ 3 entries
  //----------------------------------------------------------------------

  reg        t5_reset = 1;
  reg  [7:0] t5_enq_msg;
  reg        t5_enq_val;
  wire       t5_enq_rdy;
  wire [7:0] t5_deq_msg;
  wire       t5_deq_val;
  reg        t5_deq_rdy;

  vc_Queue#(`VC_QUEUE_PIPE,8,3) t5_queue
  (
    .clk     (clk),
    .reset   (t5_reset),
    .enq_val (t5_enq_val),
    .enq_rdy (t5_enq_rdy),
    .enq_msg (t5_enq_msg),
    .deq_val (t5_deq_val),
    .deq_rdy (t5_deq_rdy),
    .deq_msg (t5_deq_msg)
  );

  // Helper task

  task t5
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t5_enq_msg = enq_msg;
    t5_enq_val = enq_val;
    t5_deq_rdy = deq_rdy;
    #1;
    t5_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t5_enq_rdy,  enq_rdy  );
    `VC_TEST_NET( t5_deq_msg, deq_msg );
    `VC_TEST_NET( t5_deq_val,  deq_val  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 5, "pipe queue w/ 3 entries" )
  begin

    #1;  t5_reset = 1'b1;
    #20; t5_reset = 1'b0;

    // Enque one element and then dequeue it

    t5( 8'h01, 1, 1,  8'h??, 0, 1 );
    t5( 8'hxx, 0, 1,  8'h01, 1, 1 );
    t5( 8'hxx, 0, 1,  8'h??, 0, 1 );

    // Fill queue and then do enq/deq at same time

    t5( 8'h02, 1, 1,  8'h??, 0, 0 );
    t5( 8'h03, 1, 1,  8'h02, 1, 0 );
    t5( 8'h04, 1, 1,  8'h02, 1, 0 );
    t5( 8'h05, 1, 0,  8'h02, 1, 0 );
    t5( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t5( 8'h05, 1, 1,  8'h02, 1, 1 );
    t5( 8'h06, 1, 1,  8'h03, 1, 1 );
    t5( 8'h07, 1, 1,  8'h04, 1, 1 );
    t5( 8'hxx, 0, 1,  8'h05, 1, 1 );
    t5( 8'hxx, 0, 1,  8'h06, 1, 1 );
    t5( 8'hxx, 0, 1,  8'h07, 1, 1 );
    t5( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: bypass queue w/ 3 entries
  //----------------------------------------------------------------------

  reg        t6_reset = 1;
  reg  [7:0] t6_enq_msg;
  reg        t6_enq_val;
  wire       t6_enq_rdy;
  wire [7:0] t6_deq_msg;
  wire       t6_deq_val;
  reg        t6_deq_rdy;

  vc_Queue#(`VC_QUEUE_BYPASS,8,3) t6_queue
  (
    .clk     (clk),
    .reset   (t6_reset),
    .enq_val (t6_enq_val),
    .enq_rdy (t6_enq_rdy),
    .enq_msg (t6_enq_msg),
    .deq_val (t6_deq_val),
    .deq_rdy (t6_deq_rdy),
    .deq_msg (t6_deq_msg)
  );

  // Helper task

  task t6
  (
    input [7:0] enq_msg, input enq_val, input enq_rdy,
    input [7:0] deq_msg, input deq_val, input deq_rdy
  );
  begin
    t6_enq_msg = enq_msg;
    t6_enq_val = enq_val;
    t6_deq_rdy = deq_rdy;
    #1;
    t6_queue.trace_display();
    `VC_TEST_NOTE_INPUTS_3( enq_val, enq_rdy, enq_msg );
    `VC_TEST_NET( t6_enq_rdy,  enq_rdy  );
    `VC_TEST_NET( t6_deq_msg, deq_msg );
    `VC_TEST_NET( t6_deq_val,  deq_val  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 6, "bypass queue w/ 3 entries" )
  begin

    #1;  t6_reset = 1'b1;
    #20; t6_reset = 1'b0;

    // Enque one element and then dequeue it

    t6( 8'h01, 1, 1,  8'h01, 1, 1 );
    t6( 8'hxx, 0, 1,  8'h??, 0, 1 );

    // Fill queue and then do enq/deq at same time

    t6( 8'h02, 1, 1,  8'h02, 1, 0 );
    t6( 8'h03, 1, 1,  8'h02, 1, 0 );
    t6( 8'h04, 1, 1,  8'h02, 1, 0 );
    t6( 8'h05, 1, 0,  8'h02, 1, 0 );
    t6( 8'hxx, 0, 0,  8'h02, 1, 0 );
    t6( 8'h05, 1, 0,  8'h02, 1, 1 );
    t6( 8'h05, 1, 1,  8'h03, 1, 1 );
    t6( 8'h06, 1, 1,  8'h04, 1, 1 );
    t6( 8'h07, 1, 1,  8'h05, 1, 1 );
    t6( 8'hxx, 0, 1,  8'h06, 1, 1 );
    t6( 8'hxx, 0, 1,  8'h07, 1, 1 );
    t6( 8'hxx, 0, 1,  8'h??, 0, 1 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

