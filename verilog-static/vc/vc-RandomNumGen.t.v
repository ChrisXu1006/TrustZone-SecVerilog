//========================================================================
// vc-RandomNumGen Unit Tests
//========================================================================

`include "vc-RandomNumGen.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-RandomNumGen" )

  //----------------------------------------------------------------------
  // Test Case: smoke test to make sure there are no compilation errors
  //----------------------------------------------------------------------

  reg        t1_reset = 1;
  reg        t1_next;
  wire [3:0] t1_out;
  reg  [3:0] t1_prev_out;


  vc_RandomNumGen #(4,32'hdeadbeef) t1_random
  (
    .clk     (clk),
    .reset   (t1_reset),
    .next    (t1_next),
    .out     (t1_out)
  );

  // Helper task

  task t1
  (
    input       next,
    input [3:0] out
  );
  begin
    t1_next = next;
    #1;
    `VC_TEST_NOTE_INPUTS_2( next, t1_prev_out );
    `VC_TEST_NET( t1_out, out );
    t1_prev_out = t1_out;
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "smoke test" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1( 1'b0, 4'hd        );
    t1( 1'b1, 4'hd        );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );

    // test that we don't generate a new result when next is 0
    t1( 1'b0, 4'h?        );
    t1( 1'b0, t1_prev_out );
    t1( 1'b1, t1_prev_out );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );
    t1( 1'b1, 4'h?        );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

