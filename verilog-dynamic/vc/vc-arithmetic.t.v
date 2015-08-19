//========================================================================
// vc-arithmetic Unit Tests
//========================================================================

`include "vc-arithmetic.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-arithmetic" )

  //----------------------------------------------------------------------
  // Test vc_Adder
  //----------------------------------------------------------------------

  reg  [7:0] t1_in0;
  reg  [7:0] t1_in1;
  reg        t1_cin;
  wire [7:0] t1_out;
  wire       t1_cout;

  vc_Adder#(8) t1_adder_w8
  (
    .in0  (t1_in0),
    .in1  (t1_in1),
    .cin  (t1_cin),
    .out  (t1_out),
    .cout (t1_cout)
  );

  task t1
  (
    input      [7:0] in0,
    input      [7:0] in1,
    input            cin,
    input      [7:0] out,
    input            cout
  );
  begin
    t1_in0 = in0;
    t1_in1 = in1;
    t1_cin = cin;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in0, in1, cin );
    `VC_TEST_NET( t1_out,  out  );
    `VC_TEST_NET( t1_cout, cout );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "vc_Adder_w8" )
  begin
    //  in0    in1    cin   out    cout
    t1( 8'h01, 8'h01, 1'b0, 8'h02, 1'b0 );
    t1( 8'h01, 8'h00, 1'b0, 8'h01, 1'b0 );
    t1( 8'h02, 8'h03, 1'b0, 8'h05, 1'b0 );
    t1( 8'h02, 8'h03, 1'b1, 8'h06, 1'b0 );
    t1( 8'hfe, 8'h01, 1'b0, 8'hff, 1'b0 );
    t1( 8'hff, 8'h01, 1'b0, 8'h00, 1'b1 );
    t1( 8'hff, 8'h01, 1'b1, 8'h01, 1'b1 );
    t1( 8'hff, 8'hff, 1'b0, 8'hfe, 1'b1 );
    t1( 8'hff, 8'hff, 1'b1, 8'hff, 1'b1 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_SimpleAdder
  //----------------------------------------------------------------------

  reg  [7:0] t2_in0;
  reg  [7:0] t2_in1;
  wire [7:0] t2_out;

  vc_SimpleAdder#(8) t2_simple_adder_w8
  (
    .in0 (t2_in0),
    .in1 (t2_in1),
    .out (t2_out)
  );

  task t2
  (
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] out
  );
  begin
    t2_in0 = in0;
    t2_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t2_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "vc_SimpleAdder_w8" )
  begin
    t2( 8'h01, 8'h01, 8'h02 );
    t2( 8'h01, 8'h00, 8'h01 );
    t2( 8'h02, 8'h03, 8'h05 );
    t2( 8'hfe, 8'h01, 8'hff );
    t2( 8'hff, 8'h01, 8'h00 );
    t2( 8'hff, 8'hff, 8'hfe );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Subtractor
  //----------------------------------------------------------------------

  reg  [7:0] t3_in0;
  reg  [7:0] t3_in1;
  wire [7:0] t3_out;

  vc_Subtractor#(8) t3_subtractor_w8
  (
    .in0 (t3_in0),
    .in1 (t3_in1),
    .out (t3_out)
  );

  task t3
  (
    input [7:0] in0,
    input [7:0] in1,
    input [7:0] out
  );
  begin
    t3_in0 = in0;
    t3_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t3_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 3, "vc_Subtractor_w8" )
  begin
    t3( 8'h02, 8'h01, 8'h01 );
    t3( 8'h01, 8'h00, 8'h01 );
    t3( 8'h05, 8'h03, 8'h02 );
    t3( 8'hff, 8'h01, 8'hfe );
    t3( 8'h00, 8'h01, 8'hff );
    t3( 8'hfe, 8'hff, 8'hff );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Incrementer (increment = 1)
  //----------------------------------------------------------------------

  reg  [7:0] t4_in;
  wire [7:0] t4_out;

  vc_Incrementer#(8) t4_incrementer_w8_inc1
  (
    .in  (t4_in),
    .out (t4_out)
  );

  task t4
  (
    input [7:0] in,
    input [7:0] out
  );
  begin
    t4_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t4_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 4, "vc_Incrementer_w8_inc1" )
  begin
    t4( 8'h02, 8'h03 );
    t4( 8'h00, 8'h01 );
    t4( 8'h01, 8'h02 );
    t4( 8'h05, 8'h06 );
    t4( 8'hff, 8'h00 );
    t4( 8'hfe, 8'hff );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Incrementer (increment = 2)
  //----------------------------------------------------------------------

  reg  [7:0] t5_in;
  wire [7:0] t5_out;

  vc_Incrementer#(8,2) t5_incrementer_w8_inc2
  (
    .in  (t5_in),
    .out (t5_out)
  );

  task t5
  (
    input [7:0] in,
    input [7:0] out
  );
  begin
    t5_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t5_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 5, "vc_Incrementer_w8_inc2" )
  begin
    t5( 8'h02, 8'h04 );
    t5( 8'h00, 8'h02 );
    t5( 8'h01, 8'h03 );
    t5( 8'h05, 8'h07 );
    t5( 8'hff, 8'h01 );
    t5( 8'hfe, 8'h00 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_ZeroExtender
  //----------------------------------------------------------------------

  reg  [1:0] t6_in;
  wire [7:0] t6_out;

  vc_ZeroExtender#(2,8) t6_zero_extender_2to8
  (
    .in  (t6_in),
    .out (t6_out)
  );

  task t6
  (
    input [1:0] in,
    input [7:0] out
  );
  begin
    t6_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t6_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 6, "vc_ZeroExtender_2to8" )
  begin
    t6( 2'b00, 8'h00 );
    t6( 2'b01, 8'h01 );
    t6( 2'b10, 8'h02 );
    t6( 2'b11, 8'h03 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_SignExtender
  //----------------------------------------------------------------------

  reg  [1:0] t7_in;
  wire [7:0] t7_out;

  vc_SignExtender#(2,8) t7_sign_extender_2to8
  (
    .in  (t7_in),
    .out (t7_out)
  );

  task t7
  (
    input [1:0] in,
    input [7:0] out
  );
  begin
    t7_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t7_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 7, "vc_SignExtender_2to8" )
  begin
    t7( 2'b00, 8'h00 );
    t7( 2'b01, 8'h01 );
    t7( 2'b10, 8'hfe );
    t7( 2'b11, 8'hff );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_ZeroComparator
  //----------------------------------------------------------------------

  reg  [7:0] t8_in;
  wire       t8_out;

  vc_ZeroComparator#(8) t8_zero_comparator_w8
  (
    .in  (t8_in),
    .out (t8_out)
  );

  task t8
  (
    input [7:0] in,
    input       out
  );
  begin
    t8_in = in;
    #1;
    `VC_TEST_NOTE_INPUTS_1( in );
    `VC_TEST_NET( t8_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 8, "vc_ZeroComparator_w8" )
  begin
    t8( 8'h00, 1'b1 );
    t8( 8'h01, 1'b0 );
    t8( 8'hfe, 1'b0 );
    t8( 8'hff, 1'b0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_EqComparator
  //----------------------------------------------------------------------

  reg  [7:0] t9_in0;
  reg  [7:0] t9_in1;
  wire       t9_out;

  vc_EqComparator#(8) t9_eq_comparator_w8
  (
    .in0 (t9_in0),
    .in1 (t9_in1),
    .out (t9_out)
  );

  task t9
  (
    input [7:0] in0,
    input [7:0] in1,
    input       out
  );
  begin
    t9_in0 = in0;
    t9_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t9_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 9, "vc_EqComparator_w8" )
  begin
    t9( 8'h01, 8'h01, 1'b1 );
    t9( 8'h00, 8'h00, 1'b1 );
    t9( 8'h01, 8'h00, 1'b0 );
    t9( 8'h00, 8'h01, 1'b0 );
    t9( 8'hfe, 8'hfe, 1'b1 );
    t9( 8'hff, 8'hff, 1'b1 );
    t9( 8'hfe, 8'hff, 1'b0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_LtComparator
  //----------------------------------------------------------------------

  reg  [7:0] t10_in0;
  reg  [7:0] t10_in1;
  wire       t10_out;

  vc_LtComparator#(8) t10_lt_comparator_w8
  (
    .in0 (t10_in0),
    .in1 (t10_in1),
    .out (t10_out)
  );

  task t10
  (
    input [7:0] in0,
    input [7:0] in1,
    input       out
  );
  begin
    t10_in0 = in0;
    t10_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t10_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 10, "vc_LtComparator_w8" )
  begin
    t10( 8'h01, 8'h01, 1'b0 );
    t10( 8'h00, 8'h00, 1'b0 );
    t10( 8'h01, 8'h00, 1'b0 );
    t10( 8'h00, 8'h01, 1'b1 );
    t10( 8'h03, 8'h03, 1'b0 );
    t10( 8'h01, 8'h01, 1'b0 );
    t10( 8'h03, 8'h01, 1'b0 );
    t10( 8'h01, 8'h03, 1'b1 );
    t10( 8'hfe, 8'hfe, 1'b0 );
    t10( 8'hfe, 8'hff, 1'b1 );
    t10( 8'hff, 8'hfe, 1'b0 );
    t10( 8'hff, 8'hff, 1'b0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_GtComparator
  //----------------------------------------------------------------------

  reg  [7:0] t11_in0;
  reg  [7:0] t11_in1;
  wire       t11_out;

  vc_GtComparator#(8) t11_gt_comparator_w8
  (
    .in0 (t11_in0),
    .in1 (t11_in1),
    .out (t11_out)
  );

  task t11
  (
    input [7:0] in0,
    input [7:0] in1,
    input       out
  );
  begin
    t11_in0 = in0;
    t11_in1 = in1;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in0, in1 );
    `VC_TEST_NET( t11_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 11, "vc_GtComparator_w8" )
  begin
    t11( 8'h01, 8'h01, 1'b0 );
    t11( 8'h00, 8'h00, 1'b0 );
    t11( 8'h01, 8'h00, 1'b1 );
    t11( 8'h00, 8'h01, 1'b0 );
    t11( 8'h03, 8'h03, 1'b0 );
    t11( 8'h01, 8'h01, 1'b0 );
    t11( 8'h03, 8'h01, 1'b1 );
    t11( 8'h01, 8'h03, 1'b0 );
    t11( 8'hfe, 8'hfe, 1'b0 );
    t11( 8'hfe, 8'hff, 1'b0 );
    t11( 8'hff, 8'hfe, 1'b1 );
    t11( 8'hff, 8'hff, 1'b0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_LeftLogicalShifter
  //----------------------------------------------------------------------

  reg  [7:0] t12_in;
  reg  [4:0] t12_shamt;
  wire [7:0] t12_out;

  vc_LeftLogicalShifter#(8,5) t12_left_logical_shifter_w8
  (
    .in    (t12_in),
    .shamt (t12_shamt),
    .out   (t12_out)
  );

  task t12
  (
    input [7:0] in,
    input [4:0] shamt,
    input [7:0] out
  );
  begin
    t12_in    = in;
    t12_shamt = shamt;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in, shamt );
    `VC_TEST_NET( t12_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 12, "vc_LeftLogicalShifter_w8" )
  begin
    t12( 8'b0000_0001, 5'd1, 8'b0000_0010 );
    t12( 8'b0000_0001, 5'd0, 8'b0000_0001 );
    t12( 8'b0000_0001, 5'd2, 8'b0000_0100 );
    t12( 8'b0000_0001, 5'd3, 8'b0000_1000 );
    t12( 8'b0000_0001, 5'd4, 8'b0001_0000 );
    t12( 8'b0000_0001, 5'd5, 8'b0010_0000 );
    t12( 8'b0000_0001, 5'd6, 8'b0100_0000 );
    t12( 8'b0000_0001, 5'd7, 8'b1000_0000 );
    t12( 8'b0000_0001, 5'd8, 8'b0000_0000 );
    t12( 8'b1011_0111, 5'd3, 8'b1011_1000 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_RightLogicalShifter
  //----------------------------------------------------------------------

  reg  [7:0] t13_in;
  reg  [4:0] t13_shamt;
  wire [7:0] t13_out;

  vc_RightLogicalShifter#(8,5) t13_right_logical_shifter_w8
  (
    .in    (t13_in),
    .shamt (t13_shamt),
    .out   (t13_out)
  );

  task t13
  (
    input [7:0] in,
    input [4:0] shamt,
    input [7:0] out
  );
  begin
    t13_in    = in;
    t13_shamt = shamt;
    #1;
    `VC_TEST_NOTE_INPUTS_2( in, shamt );
    `VC_TEST_NET( t13_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 13, "vc_RightLogicalShifter_w8" )
  begin
    t13( 8'b1000_0000, 5'd1, 8'b0100_0000 );
    t13( 8'b1000_0000, 5'd0, 8'b1000_0000 );
    t13( 8'b1000_0000, 5'd2, 8'b0010_0000 );
    t13( 8'b1000_0000, 5'd3, 8'b0001_0000 );
    t13( 8'b1000_0000, 5'd4, 8'b0000_1000 );
    t13( 8'b1000_0000, 5'd5, 8'b0000_0100 );
    t13( 8'b1000_0000, 5'd6, 8'b0000_0010 );
    t13( 8'b1000_0000, 5'd7, 8'b0000_0001 );
    t13( 8'b1000_0000, 5'd8, 8'b0000_0000 );
    t13( 8'b1011_0111, 5'd3, 8'b0001_0110 );
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

