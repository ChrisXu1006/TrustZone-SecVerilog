//========================================================================
// vc-arbiters Unit Tests
//========================================================================

`include "vc-arbiters.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-arbiters" )

  //----------------------------------------------------------------------
  // Test vc_FixedArbChain
  //----------------------------------------------------------------------

  reg        t1_kin;
  reg  [3:0] t1_reqs;
  wire [3:0] t1_grants;
  wire       t1_kout;

  vc_FixedArbChain#(4) t1_fixed_arb_chain
  (
    .kin    (t1_kin),
    .reqs   (t1_reqs),
    .grants (t1_grants),
    .kout   (t1_kout)
  );

  // Helper task

  task t1
  (
    input       kin,
    input [3:0] reqs,
    input [3:0] grants,
    input       kout
  );
  begin
    t1_kin  = kin;
    t1_reqs = reqs;
    #1;
    `VC_TEST_NOTE_INPUTS_2( kin, reqs );
    `VC_TEST_NET( t1_grants, grants );
    `VC_TEST_NET( t1_kout,   kout   );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_FixedArbChain" )
  begin

    t1( 1, 4'b0000, 4'b0000, 1 );
    t1( 1, 4'b1111, 4'b0000, 1 );

    t1( 0, 4'b0000, 4'b0000, 0 );

    t1( 0, 4'b1000, 4'b1000, 1 );
    t1( 0, 4'b0100, 4'b0100, 1 );
    t1( 0, 4'b0010, 4'b0010, 1 );
    t1( 0, 4'b0001, 4'b0001, 1 );

    t1( 0, 4'b1100, 4'b0100, 1 );
    t1( 0, 4'b1010, 4'b0010, 1 );
    t1( 0, 4'b1001, 4'b0001, 1 );
    t1( 0, 4'b0110, 4'b0010, 1 );
    t1( 0, 4'b0101, 4'b0001, 1 );
    t1( 0, 4'b0011, 4'b0001, 1 );

    t1( 0, 4'b1110, 4'b0010, 1 );
    t1( 0, 4'b1101, 4'b0001, 1 );
    t1( 0, 4'b1011, 4'b0001, 1 );
    t1( 0, 4'b0111, 4'b0001, 1 );

    t1( 0, 4'b1111, 4'b0001, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_VariableArbChain
  //----------------------------------------------------------------------

  reg        t2_kin;
  reg  [3:0] t2_priority;
  reg  [3:0] t2_reqs;
  wire [3:0] t2_grants;
  wire       t2_kout;

  vc_VariableArbChain#(4) t2_arb
  (
    .kin      (t2_kin),
    .priority (t2_priority),
    .reqs     (t2_reqs),
    .grants   (t2_grants),
    .kout     (t2_kout)
  );

  // Helper task

  task t2
  (
    input       kin,
    input [3:0] priority,
    input [3:0] reqs,
    input [3:0] grants,
    input       kout
  );
  begin
    t2_kin      = kin;
    t2_priority = priority;
    t2_reqs     = reqs;
    #1;
    `VC_TEST_NOTE_INPUTS_3( kin, priority, reqs );
    `VC_TEST_NET( t2_grants, grants );
    `VC_TEST_NET( t2_kout,   kout   );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "vc_VariableArbChain" )
  begin

    // Test kin = 1

    t2( 1, 4'b0001, 4'b0000, 4'b0000, 1 );
    t2( 1, 4'b0001, 4'b1111, 4'b0000, 1 );
    t2( 1, 4'b0010, 4'b0000, 4'b0000, 1 );
    t2( 1, 4'b0010, 4'b1111, 4'b0000, 1 );
    t2( 1, 4'b0100, 4'b0000, 4'b0000, 1 );
    t2( 1, 4'b0100, 4'b1111, 4'b0000, 1 );
    t2( 1, 4'b1000, 4'b0000, 4'b0000, 1 );
    t2( 1, 4'b1000, 4'b1111, 4'b0000, 1 );

    // Test when requester 0 has highest priority

    t2( 0, 4'b0001, 4'b0000, 4'b0000, 0 );

    t2( 0, 4'b0001, 4'b1000, 4'b1000, 1 );
    t2( 0, 4'b0001, 4'b0100, 4'b0100, 1 );
    t2( 0, 4'b0001, 4'b0010, 4'b0010, 1 );
    t2( 0, 4'b0001, 4'b0001, 4'b0001, 1 );

    t2( 0, 4'b0001, 4'b1100, 4'b0100, 1 );
    t2( 0, 4'b0001, 4'b1010, 4'b0010, 1 );
    t2( 0, 4'b0001, 4'b1001, 4'b0001, 1 );
    t2( 0, 4'b0001, 4'b0110, 4'b0010, 1 );
    t2( 0, 4'b0001, 4'b0101, 4'b0001, 1 );
    t2( 0, 4'b0001, 4'b0011, 4'b0001, 1 );

    t2( 0, 4'b0001, 4'b1110, 4'b0010, 1 );
    t2( 0, 4'b0001, 4'b1101, 4'b0001, 1 );
    t2( 0, 4'b0001, 4'b1011, 4'b0001, 1 );
    t2( 0, 4'b0001, 4'b0111, 4'b0001, 1 );

    t2( 0, 4'b0001, 4'b1111, 4'b0001, 1 );

    // Test when requester 1 has highest priority

    t2( 0, 4'b0010, 4'b0000, 4'b0000, 0 );

    t2( 0, 4'b0010, 4'b1000, 4'b1000, 1 );
    t2( 0, 4'b0010, 4'b0100, 4'b0100, 1 );
    t2( 0, 4'b0010, 4'b0010, 4'b0010, 1 );
    t2( 0, 4'b0010, 4'b0001, 4'b0001, 1 );

    t2( 0, 4'b0010, 4'b1100, 4'b0100, 1 );
    t2( 0, 4'b0010, 4'b1010, 4'b0010, 1 );
    t2( 0, 4'b0010, 4'b1001, 4'b1000, 1 );
    t2( 0, 4'b0010, 4'b0110, 4'b0010, 1 );
    t2( 0, 4'b0010, 4'b0101, 4'b0100, 1 );
    t2( 0, 4'b0010, 4'b0011, 4'b0010, 1 );

    t2( 0, 4'b0010, 4'b1110, 4'b0010, 1 );
    t2( 0, 4'b0010, 4'b1101, 4'b0100, 1 );
    t2( 0, 4'b0010, 4'b1011, 4'b0010, 1 );
    t2( 0, 4'b0010, 4'b0111, 4'b0010, 1 );

    t2( 0, 4'b0010, 4'b1111, 4'b0010, 1 );

    // Test when requester 2 has highest priority

    t2( 0, 4'b0100, 4'b0000, 4'b0000, 0 );

    t2( 0, 4'b0100, 4'b1000, 4'b1000, 1 );
    t2( 0, 4'b0100, 4'b0100, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b0010, 4'b0010, 1 );
    t2( 0, 4'b0100, 4'b0001, 4'b0001, 1 );

    t2( 0, 4'b0100, 4'b1100, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b1010, 4'b1000, 1 );
    t2( 0, 4'b0100, 4'b1001, 4'b1000, 1 );
    t2( 0, 4'b0100, 4'b0110, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b0101, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b0011, 4'b0001, 1 );

    t2( 0, 4'b0100, 4'b1110, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b1101, 4'b0100, 1 );
    t2( 0, 4'b0100, 4'b1011, 4'b1000, 1 );
    t2( 0, 4'b0100, 4'b0111, 4'b0100, 1 );

    t2( 0, 4'b0100, 4'b1111, 4'b0100, 1 );

    // Test when requester 3 has highest priority

    t2( 0, 4'b1000, 4'b0000, 4'b0000, 0 );

    t2( 0, 4'b1000, 4'b1000, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b0100, 4'b0100, 1 );
    t2( 0, 4'b1000, 4'b0010, 4'b0010, 1 );
    t2( 0, 4'b1000, 4'b0001, 4'b0001, 1 );

    t2( 0, 4'b1000, 4'b1100, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b1010, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b1001, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b0110, 4'b0010, 1 );
    t2( 0, 4'b1000, 4'b0101, 4'b0001, 1 );
    t2( 0, 4'b1000, 4'b0011, 4'b0001, 1 );

    t2( 0, 4'b1000, 4'b1110, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b1101, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b1011, 4'b1000, 1 );
    t2( 0, 4'b1000, 4'b0111, 4'b0001, 1 );

    t2( 0, 4'b1000, 4'b1111, 4'b1000, 1 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_RoundRobinArbChain
  //----------------------------------------------------------------------

  reg        t3_reset = 1;
  reg        t3_kin;
  reg  [3:0] t3_reqs;
  wire [3:0] t3_grants;
  wire       t3_kout;

  vc_RoundRobinArbChain#(4) t3_arb
  (
    .clk    (clk),
    .reset  (t3_reset),
    .kin    (t3_kin),
    .reqs   (t3_reqs),
    .grants (t3_grants),
    .kout   (t3_kout)
  );

  // Helper task

  task t3
  (
    input       kin,
    input [3:0] reqs,
    input [3:0] grants,
    input       kout
  );
  begin
    t3_kin  = kin;
    t3_reqs = reqs;
    #1;
    `VC_TEST_NOTE_INPUTS_2( kin, reqs );
    `VC_TEST_NET( t3_grants, grants );
    `VC_TEST_NET( t3_kout,   kout   );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "vc_RoundRobinArbChain" )
  begin

    #1;  t3_reset = 1'b1;
    #20; t3_reset = 1'b0;

    t3( 1, 4'b0000, 4'b0000, 1 );
    t3( 1, 4'b1111, 4'b0000, 1 );

    t3( 0, 4'b0000, 4'b0000, 0 );

    t3( 0, 4'b0001, 4'b0001, 1 );
    t3( 0, 4'b0010, 4'b0010, 1 );
    t3( 0, 4'b0100, 4'b0100, 1 );
    t3( 0, 4'b1000, 4'b1000, 1 );

    t3( 0, 4'b1111, 4'b0001, 1 );
    t3( 0, 4'b1111, 4'b0010, 1 );
    t3( 0, 4'b1111, 4'b0100, 1 );
    t3( 0, 4'b1111, 4'b1000, 1 );
    t3( 0, 4'b1111, 4'b0001, 1 );

    t3( 0, 4'b1100, 4'b0100, 1 );
    t3( 0, 4'b1010, 4'b1000, 1 );
    t3( 0, 4'b1001, 4'b0001, 1 );
    t3( 0, 4'b0110, 4'b0010, 1 );
    t3( 0, 4'b0101, 4'b0100, 1 );
    t3( 0, 4'b0011, 4'b0001, 1 );

    t3( 0, 4'b1110, 4'b0010, 1 );
    t3( 0, 4'b1101, 4'b0100, 1 );
    t3( 0, 4'b1011, 4'b1000, 1 );
    t3( 0, 4'b0111, 4'b0001, 1 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

