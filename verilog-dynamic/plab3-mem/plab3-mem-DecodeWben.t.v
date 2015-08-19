//========================================================================
// plab3-mem Decoder for Write Byte Enable Unit Tests
//========================================================================

`include "plab3-mem-DecodeWben.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab3-mem-DecodeWben" )

  //----------------------------------------------------------------------
  // Test plab3-mem-DecodeWben
  //----------------------------------------------------------------------

  reg  [1:0] t1_in;
  wire [15:0] t1_out;

  plab3_mem_DecoderWben#(2) t1_DecoderWben
  (
    .in    (t1_in),
    .out   (t1_out)
  );

  // Helper task

  task t1
  (
    input [1:0]    in,
    input [15:0]    out
  );
  begin
    t1_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( t1_in );
    `VC_TEST_NET( t1_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "plab3-mem-DecodeWben" )
  begin

    #1;

    t1( 2'd0,  16'b0000000000001111 );
    t1( 2'd1,  16'b0000000011110000 );
    t1( 2'd2,  16'b0000111100000000 );
    t1( 2'd3,  16'b1111000000000000 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

