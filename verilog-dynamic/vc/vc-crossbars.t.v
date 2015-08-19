//========================================================================
// vc-crossbars Unit Tests
//========================================================================

`include "vc-crossbars.v"
`include "vc-test.v"

module top;

  `VC_TEST_SUITE_BEGIN( "vc-crossbars" )

  //----------------------------------------------------------------------
  // Test vc_Crossbar2_w32
  //----------------------------------------------------------------------

  reg  [31:0] t1_in0 = 32'hdeadbeef;
  reg  [31:0] t1_in1 = 32'hbeeff00d;

  reg         t1_sel0;
  reg         t1_sel1;

  wire [31:0] t1_out0;
  wire [31:0] t1_out1;

  vc_Crossbar2#(32) t1_xbar2_w32
  (
    .in0  (t1_in0),
    .in1  (t1_in1),

    .sel0 (t1_sel0),
    .sel1 (t1_sel1),

    .out0 (t1_out0),
    .out1 (t1_out1)
  );

  // Helper task

  task t1
  (
    input        sel0,
    input        sel1,

    input [31:0] out0,
    input [31:0] out1
  );
  begin
    t1_sel0 = sel0;
    t1_sel1 = sel1;
    #1;
    `VC_TEST_NET( t1_out0, out0 );
    `VC_TEST_NET( t1_out1, out1 );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN(1, "vc_Crossbar2_w32")
  begin
    t1( 1'd0,         1'd1,
        32'hdeadbeef, 32'hbeeff00d);
    t1( 1'd1,         1'd0,
        32'hbeeff00d, 32'hdeadbeef);
    t1( 1'd0,         1'd1,
        32'hdeadbeef, 32'hbeeff00d);
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Crossbar3_w32
  //----------------------------------------------------------------------

  reg  [31:0] t2_in0 = 32'hdeadbeef;
  reg  [31:0] t2_in1 = 32'hbeeff00d;
  reg  [31:0] t2_in2 = 32'hcafebabe;

  reg  [1:0]  t2_sel0;
  reg  [1:0]  t2_sel1;
  reg  [1:0]  t2_sel2;

  wire [31:0] t2_out0;
  wire [31:0] t2_out1;
  wire [31:0] t2_out2;

  vc_Crossbar3#(32) t2_xbar3_w32
  (
    .in0  (t2_in0),
    .in1  (t2_in1),
    .in2  (t2_in2),

    .sel0 (t2_sel0),
    .sel1 (t2_sel1),
    .sel2 (t2_sel2),

    .out0 (t2_out0),
    .out1 (t2_out1),
    .out2 (t2_out2)
  );

  // Helper task

  task t2
  (
    input [1:0]  sel0,
    input [1:0]  sel1,
    input [1:0]  sel2,

    input [31:0] out0,
    input [31:0] out1,
    input [31:0] out2
  );
  begin
    t2_sel0 = sel0;
    t2_sel1 = sel1;
    t2_sel2 = sel2;
    #1;
    `VC_TEST_NET( t2_out0, out0 );
    `VC_TEST_NET( t2_out1, out1 );
    `VC_TEST_NET( t2_out2, out2 );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN(2, "vc_Crossbar3_w32")
  begin
    t2( 2'd0,         2'd1,         2'd2,
        32'hdeadbeef, 32'hbeeff00d, 32'hcafebabe);
    t2( 2'd0,         2'd2,         2'd1,
        32'hdeadbeef, 32'hcafebabe, 32'hbeeff00d);
    t2( 2'd1,         2'd2,         2'd0,
        32'hbeeff00d, 32'hcafebabe, 32'hdeadbeef);
    t2( 2'd1,         2'd0,         2'd2,
        32'hbeeff00d, 32'hdeadbeef, 32'hcafebabe);
    t2( 2'd2,         2'd1,         2'd0,
        32'hcafebabe, 32'hbeeff00d, 32'hdeadbeef);
    t2( 2'd2,         2'd0,         2'd1,
        32'hcafebabe, 32'hdeadbeef, 32'hbeeff00d);
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Crossbar4_w32
  //----------------------------------------------------------------------

  reg  [31:0] t3_in0 = 32'hdeadbeef;
  reg  [31:0] t3_in1 = 32'hbeeff00d;
  reg  [31:0] t3_in2 = 32'hcafebabe;
  reg  [31:0] t3_in3 = 32'hff00ff00;

  reg  [1:0]  t3_sel0;
  reg  [1:0]  t3_sel1;
  reg  [1:0]  t3_sel2;
  reg  [1:0]  t3_sel3;

  wire [31:0] t3_out0;
  wire [31:0] t3_out1;
  wire [31:0] t3_out2;
  wire [31:0] t3_out3;

  vc_Crossbar4#(32) t3_xbar4_w32
  (
    .in0  (t3_in0),
    .in1  (t3_in1),
    .in2  (t3_in2),
    .in3  (t3_in3),

    .sel0 (t3_sel0),
    .sel1 (t3_sel1),
    .sel2 (t3_sel2),
    .sel3 (t3_sel3),

    .out0 (t3_out0),
    .out1 (t3_out1),
    .out2 (t3_out2),
    .out3 (t3_out3)
  );

  // Helper task

  task t3
  (
    input [1:0]  sel0,
    input [1:0]  sel1,
    input [1:0]  sel2,
    input [1:0]  sel3,

    input [31:0] out0,
    input [31:0] out1,
    input [31:0] out2,
    input [31:0] out3
  );
  begin
    t3_sel0 = sel0;
    t3_sel1 = sel1;
    t3_sel2 = sel2;
    t3_sel3 = sel3;
    #1;
    `VC_TEST_NET( t3_out0, out0 );
    `VC_TEST_NET( t3_out1, out1 );
    `VC_TEST_NET( t3_out2, out2 );
    `VC_TEST_NET( t3_out3, out3 );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN(3, "vc_Crossbar4_w32")
  begin
    t3( 2'd0,         2'd1,         2'd2,         2'd3,
        32'hdeadbeef, 32'hbeeff00d, 32'hcafebabe, 32'hff00ff00);
    t3( 2'd0,         2'd2,         2'd1,         2'd3,
        32'hdeadbeef, 32'hcafebabe, 32'hbeeff00d, 32'hff00ff00);
    t3( 2'd1,         2'd3,         2'd0,         2'd2,
        32'hbeeff00d, 32'hff00ff00, 32'hdeadbeef, 32'hcafebabe);
    t3( 2'd3,         2'd0,         2'd2,         2'd1,
        32'hff00ff00, 32'hdeadbeef, 32'hcafebabe, 32'hbeeff00d);
    t3( 2'd2,         2'd1,         2'd3,         2'd0,
        32'hcafebabe, 32'hbeeff00d, 32'hff00ff00, 32'hdeadbeef);
    t3( 2'd3,         2'd0,         2'd1,         2'd2,
        32'hff00ff00, 32'hdeadbeef, 32'hbeeff00d, 32'hcafebabe);
    t3( 2'd1,         2'd0,         2'd2,         2'd3,
        32'hbeeff00d, 32'hdeadbeef, 32'hcafebabe, 32'hff00ff00);
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

