//========================================================================
// vc-Counter Unit Tests
//========================================================================

`include "vc-Counter.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-Counter" )

  //----------------------------------------------------------------------
  // Test vc_Counter
  //----------------------------------------------------------------------

  localparam t1_p_count_nbits       = 4;
  localparam t1_p_count_reset_value = 3;
  localparam t1_p_count_max_value   = 5;

  reg                         t1_reset;
  reg                         t1_increment;
  reg                         t1_decrement;
  wire [t1_p_count_nbits-1:0] t1_count;
  wire                        t1_count_is_zero;
  wire                        t1_count_is_max;

  vc_Counter
  #(
    .p_count_nbits       (t1_p_count_nbits),
    .p_count_reset_value (t1_p_count_reset_value),
    .p_count_max_value   (t1_p_count_max_value)
  )
  t1_counter
  (
    .clk           (clk),
    .reset         (t1_reset),
    .increment     (t1_increment),
    .decrement     (t1_decrement),
    .count         (t1_count),
    .count_is_zero (t1_count_is_zero),
    .count_is_max  (t1_count_is_max)
  );

  // Helper task

  task t1
  (
    input                        increment,
    input                        decrement,
    input [t1_p_count_nbits-1:0] count,
    input                        count_is_zero,
    input                        count_is_max
  );
  begin
    t1_increment = increment;
    t1_decrement = decrement;
    #1;
    `VC_TEST_NOTE_INPUTS_2( increment, decrement );
    `VC_TEST_NET( t1_count,         count         );
    `VC_TEST_NET( t1_count_is_zero, count_is_zero );
    `VC_TEST_NET( t1_count_is_max,  count_is_max  );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_Counter" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  i  d  count z? m?

    t1( 0, 0, 4'h3, 0, 0 );

    // Count up to 5

    t1( 1, 0, 4'h3, 0, 0 );
    t1( 1, 0, 4'h4, 0, 0 );
    t1( 1, 0, 4'h5, 0, 1 );
    t1( 1, 0, 4'h5, 0, 1 );
    t1( 1, 0, 4'h5, 0, 1 );

    // Count down to zero

    t1( 0, 1, 4'h5, 0, 1 );
    t1( 0, 1, 4'h4, 0, 0 );
    t1( 0, 1, 4'h3, 0, 0 );
    t1( 0, 1, 4'h2, 0, 0 );
    t1( 0, 1, 4'h1, 0, 0 );
    t1( 0, 1, 4'h0, 1, 0 );
    t1( 0, 1, 4'h0, 1, 0 );
    t1( 0, 1, 4'h0, 1, 0 );

    // Count back up to 3

    t1( 1, 0, 4'h0, 1, 0 );
    t1( 1, 0, 4'h1, 0, 0 );
    t1( 1, 0, 4'h2, 0, 0 );
    t1( 0, 0, 4'h3, 0, 0 );
    t1( 0, 0, 4'h3, 0, 0 );
    t1( 0, 0, 4'h3, 0, 0 );

    // Setting increment and decrement keeps counter the same

    t1( 1, 1, 4'h3, 0, 0 );
    t1( 1, 1, 4'h3, 0, 0 );
    t1( 1, 1, 4'h3, 0, 0 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

