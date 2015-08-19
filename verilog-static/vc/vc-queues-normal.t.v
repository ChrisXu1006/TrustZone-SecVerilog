//========================================================================
// vc-queues Unit Tests
//========================================================================

`include "vc-queues-normal.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-queues-normal" )

  //----------------------------------------------------------------------
  // Test Case: simple queue w/ 1 entry
  //----------------------------------------------------------------------

  reg        t1_reset = 1;
  reg        t1_enq_val;
  wire       t1_enq_rdy;
  reg  [7:0] t1_enq_msg;
  reg		 t1_enq_domain;
  wire       t1_deq_val;
  reg        t1_deq_rdy;
  wire [7:0] t1_deq_msg;
  wire		 t1_deq_domain;

  vc_Queue_normal#(8,1) t1_queue
  (
    .clk     (clk),
    .reset   (t1_reset),
    .enq_val (t1_enq_val),
    .enq_rdy (t1_enq_rdy),
    .enq_msg (t1_enq_msg),
	.enq_domain (t1_enq_domain),
    .deq_val (t1_deq_val),
    .deq_rdy (t1_deq_rdy),
    .deq_msg (t1_deq_msg),
	.deq_domain (t1_deq_domain)
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
  // Test Case: simple queue w/ 3 entries
  //----------------------------------------------------------------------

  reg        t4_reset = 1;
  reg  [7:0] t4_enq_msg;
  reg        t4_enq_val;
  reg		 t4_enq_domain;
  wire       t4_enq_rdy;
  wire [7:0] t4_deq_msg;
  wire       t4_deq_val;
  reg        t4_deq_rdy;
  wire		 t4_deq_domain;

  vc_Queue_normal#(8,3) t4_queue
  (
    .clk     (clk),
    .reset   (t4_reset),
    .enq_val (t4_enq_val),
    .enq_rdy (t4_enq_rdy),
    .enq_msg (t4_enq_msg),
	.enq_domain (t4_enq_domain),
    .deq_val (t4_deq_val),
    .deq_rdy (t4_deq_rdy),
    .deq_msg (t4_deq_msg),
	.deq_domain (t4_deq_domain)
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

  `VC_TEST_CASE_BEGIN( 2, "simple queue w/ 3 entries" )
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

  `VC_TEST_SUITE_END
endmodule

