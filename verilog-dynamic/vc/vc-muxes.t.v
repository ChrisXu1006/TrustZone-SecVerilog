//========================================================================
// vc-muxes Unit Tests
//========================================================================

`include "vc-muxes.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-muxes" )

  //----------------------------------------------------------------------
  // Test vc_Mux2_w32
  //----------------------------------------------------------------------

  reg  [31:0] t1_in0 = 32'h0a0a0a0a;
  reg  [31:0] t1_in1 = 32'hb0b0b0b0;
  reg         t1_sel;
  wire [31:0] t1_out;

  vc_Mux2#(32) t1_mux2_w32
  (
    .in0 (t1_in0),
    .in1 (t1_in1),
    .sel (t1_sel),
    .out (t1_out)
  );

  // Helper task

  task t1
  (
    input           sel,
    input [31:0]    out
  );
  begin
    t1_sel = sel;
    #1;
    `VC_TEST_NET( t1_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_Mux2_w32" )
  begin
    t1( 1'd0, 32'h0a0a0a0a );
    t1( 1'd1, 32'hb0b0b0b0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux3_w32
  //----------------------------------------------------------------------

  reg  [31:0] t2_in0 = 32'h0a0a0a0a;
  reg  [31:0] t2_in1 = 32'hb0b0b0b0;
  reg  [31:0] t2_in2 = 32'h0c0c0c0c;
  reg  [ 1:0] t2_sel;
  wire [31:0] t2_out;

  vc_Mux3#(32) t2_mux3_w32
  (
    .in0 (t2_in0),
    .in1 (t2_in1),
    .in2 (t2_in2),
    .sel (t2_sel),
    .out (t2_out)
  );

  // Helper task

  task t2
  (
    input [1:0]     sel,
    input [31:0]    out
  );
  begin
    t2_sel = sel;
    #1;
    `VC_TEST_NET( t2_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "vc_Mux3_w32" )
  begin
    t2( 2'd0, 32'h0a0a0a0a );
    t2( 2'd1, 32'hb0b0b0b0 );
    t2( 2'd2, 32'h0c0c0c0c );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux4_w32
  //----------------------------------------------------------------------

  reg  [31:0] t3_in0 = 32'h0a0a0a0a;
  reg  [31:0] t3_in1 = 32'hb0b0b0b0;
  reg  [31:0] t3_in2 = 32'h0c0c0c0c;
  reg  [31:0] t3_in3 = 32'hd0d0d0d0;
  reg  [ 1:0] t3_sel;
  wire [31:0] t3_out;

  vc_Mux4#(32) t3_mux4_w32
  (
    .in0 (t3_in0),
    .in1 (t3_in1),
    .in2 (t3_in2),
    .in3 (t3_in3),
    .sel (t3_sel),
    .out (t3_out)
  );

  // Helper task

  task t3
  (
    input [1:0]     sel,
    input [31:0]    out
  );
  begin
    t3_sel = sel;
    #1;
    `VC_TEST_NET( t3_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "vc_Mux4_w32" )
  begin
    t3( 2'd0, 32'h0a0a0a0a );
    t3( 2'd1, 32'hb0b0b0b0 );
    t3( 2'd2, 32'h0c0c0c0c );
    t3( 2'd3, 32'hd0d0d0d0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux5_w32
  //----------------------------------------------------------------------

  reg  [31:0] t4_in0 = 32'h0a0a0a0a;
  reg  [31:0] t4_in1 = 32'hb0b0b0b0;
  reg  [31:0] t4_in2 = 32'h0c0c0c0c;
  reg  [31:0] t4_in3 = 32'hd0d0d0d0;
  reg  [31:0] t4_in4 = 32'h0e0e0e0e;
  reg  [ 2:0] t4_sel;
  wire [31:0] t4_out;

  vc_Mux5#(32) t4_mux5_w32
  (
    .in0 (t4_in0),
    .in1 (t4_in1),
    .in2 (t4_in2),
    .in3 (t4_in3),
    .in4 (t4_in4),
    .sel (t4_sel),
    .out (t4_out)
  );

  // Helper task

  task t4
  (
    input [2:0]     sel,
    input [31:0]    out
  );
  begin
    t4_sel = sel;
    #1;
    `VC_TEST_NET( t4_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 4, "vc_Mux5_w32" )
  begin
    t4( 3'd0, 32'h0a0a0a0a );
    t4( 3'd1, 32'hb0b0b0b0 );
    t4( 3'd2, 32'h0c0c0c0c );
    t4( 3'd3, 32'hd0d0d0d0 );
    t4( 3'd4, 32'h0e0e0e0e );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux6_w32
  //----------------------------------------------------------------------

  reg  [31:0] t5_in0 = 32'h0a0a0a0a;
  reg  [31:0] t5_in1 = 32'hb0b0b0b0;
  reg  [31:0] t5_in2 = 32'h0c0c0c0c;
  reg  [31:0] t5_in3 = 32'hd0d0d0d0;
  reg  [31:0] t5_in4 = 32'h0e0e0e0e;
  reg  [31:0] t5_in5 = 32'hf0f0f0f0;
  reg  [ 2:0] t5_sel;
  wire [31:0] t5_out;

  vc_Mux6#(32) t5_mux6_w32
  (
    .in0 (t5_in0),
    .in1 (t5_in1),
    .in2 (t5_in2),
    .in3 (t5_in3),
    .in4 (t5_in4),
    .in5 (t5_in5),
    .sel (t5_sel),
    .out (t5_out)
  );

  // Helper task

  task t5
  (
    input [2:0]     sel,
    input [31:0]    out
  );
  begin
    t5_sel = sel;
    #1;
    `VC_TEST_NET( t5_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 5, "vc_Mux6_w32" )
  begin
    t5( 3'd0, 32'h0a0a0a0a );
    t5( 3'd1, 32'hb0b0b0b0 );
    t5( 3'd2, 32'h0c0c0c0c );
    t5( 3'd3, 32'hd0d0d0d0 );
    t5( 3'd4, 32'h0e0e0e0e );
    t5( 3'd5, 32'hf0f0f0f0 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux7_w32
  //----------------------------------------------------------------------

  reg  [31:0] t6_in0 = 32'h0a0a0a0a;
  reg  [31:0] t6_in1 = 32'hb0b0b0b0;
  reg  [31:0] t6_in2 = 32'h0c0c0c0c;
  reg  [31:0] t6_in3 = 32'hd0d0d0d0;
  reg  [31:0] t6_in4 = 32'h0e0e0e0e;
  reg  [31:0] t6_in5 = 32'hf0f0f0f0;
  reg  [31:0] t6_in6 = 32'h01010101;
  reg  [ 2:0] t6_sel;
  wire [31:0] t6_out;

  vc_Mux7#(32) t6_mux7_w32
  (
    .in0 (t6_in0),
    .in1 (t6_in1),
    .in2 (t6_in2),
    .in3 (t6_in3),
    .in4 (t6_in4),
    .in5 (t6_in5),
    .in6 (t6_in6),
    .sel (t6_sel),
    .out (t6_out)
  );

  // Helper task

  task t6
  (
    input [2:0]     sel,
    input [31:0]    out
  );
  begin
    t6_sel = sel;
    #1;
    `VC_TEST_NET( t6_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 6, "vc_Mux7_w32" )
  begin
    t6( 3'd0, 32'h0a0a0a0a );
    t6( 3'd1, 32'hb0b0b0b0 );
    t6( 3'd2, 32'h0c0c0c0c );
    t6( 3'd3, 32'hd0d0d0d0 );
    t6( 3'd4, 32'h0e0e0e0e );
    t6( 3'd5, 32'hf0f0f0f0 );
    t6( 3'd6, 32'h01010101 );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Mux8_w32
  //----------------------------------------------------------------------

  reg  [31:0] t7_in0 = 32'h0a0a0a0a;
  reg  [31:0] t7_in1 = 32'hb0b0b0b0;
  reg  [31:0] t7_in2 = 32'h0c0c0c0c;
  reg  [31:0] t7_in3 = 32'hd0d0d0d0;
  reg  [31:0] t7_in4 = 32'h0e0e0e0e;
  reg  [31:0] t7_in5 = 32'hf0f0f0f0;
  reg  [31:0] t7_in6 = 32'h01010101;
  reg  [31:0] t7_in7 = 32'h20202020;
  reg  [ 2:0] t7_sel;
  wire [31:0] t7_out;

  vc_Mux8#(32) t7_mux8_w32
  (
    .in0 (t7_in0),
    .in1 (t7_in1),
    .in2 (t7_in2),
    .in3 (t7_in3),
    .in4 (t7_in4),
    .in5 (t7_in5),
    .in6 (t7_in6),
    .in7 (t7_in7),
    .sel (t7_sel),
    .out (t7_out)
  );

  // Helper task

  task t7
  (
    input [2:0]     sel,
    input [31:0]    out
  );
  begin
    t7_sel = sel;
    #1;
    `VC_TEST_NET( t7_out, out );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 7, "vc_Mux8_w32" )
  begin
    t7( 3'd0, 32'h0a0a0a0a );
    t7( 3'd1, 32'hb0b0b0b0 );
    t7( 3'd2, 32'h0c0c0c0c );
    t7( 3'd3, 32'hd0d0d0d0 );
    t7( 3'd4, 32'h0e0e0e0e );
    t7( 3'd5, 32'hf0f0f0f0 );
    t7( 3'd6, 32'h01010101 );
    t7( 3'd7, 32'h20202020 );
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

