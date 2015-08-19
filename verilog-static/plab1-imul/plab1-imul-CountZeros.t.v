//========================================================================
// CountZeros Unit Tests
//========================================================================

`include "plab1-imul-CountZeros.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab1-imul-CountZeros" )

  //----------------------------------------------------------------------
  // Test plab1_imul_CountZeros
  //----------------------------------------------------------------------

  reg  [7:0] t1_in;
  wire [3:0] t1_out;

  plab1_imul_CountZeros t1_count_zeros
  (
   .to_be_counted (t1_in),
   .count (t1_out)
  );

  // Helper task

  task t1
  (
    input [7:0] in,
    input [3:0] out
  );
  begin
    t1_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t1_out, out );
    #9;
  end
  endtask //

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple" )
  begin

    #1;

    //  in            out

    t1( 8'b0000_0001, 4'd0);
    t1( 8'b0000_0010, 4'd1);
    t1( 8'b0000_0100, 4'd2);
    t1( 8'b0000_1000, 4'd3);
    t1( 8'b0001_0000, 4'd4);
    t1( 8'b0010_0000, 4'd5);
    t1( 8'b0100_0000, 4'd6);
    t1( 8'b1000_0000, 4'd7);
    t1( 8'b0000_0000, 4'd8);

    // With some other 1s

    t1( 8'b0100_0101, 4'd0);
    t1( 8'b0010_0010, 4'd1);
    t1( 8'b1000_1100, 4'd2);
    t1( 8'b0010_1000, 4'd3);
    t1( 8'b1001_0000, 4'd4);
    t1( 8'b0110_0000, 4'd5);
    t1( 8'b1100_0000, 4'd6);
    t1( 8'b1000_0000, 4'd7);

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

