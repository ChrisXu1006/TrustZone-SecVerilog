//========================================================================
// vc-regs Unit Tests
//========================================================================

`include "vc-regs.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-regs" )

  //----------------------------------------------------------------------
  // Test vc_Reg
  //----------------------------------------------------------------------

  reg         t1_reset = 1;
  reg  [31:0] t1_d;
  wire [31:0] t1_q;

  vc_Reg#(32) t1_reg_w32
  (
    .clk  (clk),
    .d    (t1_d),
    .q    (t1_q)
  );

  // Helper task

  task t1
  (
    input [31:0]    d,
    input [31:0]    q
  );
  begin
    t1_d = d;
    #1;
    `VC_TEST_NET( t1_q, q );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_Reg_w32" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1( 32'h0a0a0a0a, 32'h???????? );
    t1( 32'h0b0b0b0b, 32'h0a0a0a0a );
    t1( 32'h0c0c0c0c, 32'h0b0b0b0b );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_ResetReg
  //----------------------------------------------------------------------

  reg         t2_reset = 1;
  reg  [31:0] t2_d;
  wire [31:0] t2_q;

  vc_ResetReg#(32,32'hdeadbeef) t2_reset_reg
  (
    .clk   (clk),
    .reset (t2_reset),
    .d     (t2_d),
    .q     (t2_q)
  );

  // Helper task

  task t2
  (
    input [31:0]    d,
    input [31:0]    q
  );
  begin
    t2_d = d;
    #1;
    `VC_TEST_NET( t2_q, q );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "vc_ResetReg_w32" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2( 32'h0a0a0a0a, 32'hdeadbeef );
    t2( 32'h0b0b0b0b, 32'h0a0a0a0a );
    t2( 32'h0c0c0c0c, 32'h0b0b0b0b );

  end
  `VC_TEST_CASE_END

  //--------------------------------------------------------------------
  // Test vc_EnReg
  //--------------------------------------------------------------------

  reg         t3_reset = 1;
  reg  [31:0] t3_d;
  reg         t3_en;
  wire [31:0] t3_q;

  vc_EnReg#(32) t3_en_reg
  (
    .clk   (clk),
    .reset (t3_reset),
    .d     (t3_d),
    .en    (t3_en),
    .q     (t3_q)
  );

  // Helper task

  task t3
  (
    input [31:0]    d,
    input           en,
    input [31:0]    q
  );
  begin
    t3_d  = d;
    t3_en = en;
    #1;
    `VC_TEST_NET( t3_q, q );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "vc_EnReg_w32" )
  begin

    #1;  t3_reset = 1'b1;
    #20; t3_reset = 1'b0;

    t3( 32'h0a0a0a0a, 1'b1, 32'h???????? );
    t3( 32'h0b0b0b0b, 1'b1, 32'h0a0a0a0a );
    t3( 32'h0c0c0c0c, 1'b1, 32'h0b0b0b0b );
    t3( 32'h0d0d0d0d, 1'b0, 32'h0c0c0c0c );
    t3( 32'h0e0e0e0e, 1'b0, 32'h0c0c0c0c );
    t3( 32'h0f0f0f0f, 1'b0, 32'h0c0c0c0c );
    t3( 32'h1a1a1a1a, 1'b1, 32'h0c0c0c0c );
    t3( 32'h1b1b1b1b, 1'b1, 32'h1a1a1a1a );
    t3( 32'h1c1c1c1c, 1'b1, 32'h1b1b1b1b );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_ERReg
  //----------------------------------------------------------------------

  reg         t4_reset = 1;
  reg  [31:0] t4_d;
  reg         t4_en;
  wire [31:0] t4_q;

  vc_EnResetReg#(32,32'hdeadbeef) t4_en_reset_reg_w32
  (
    .clk   (clk),
    .reset (t4_reset),
    .d     (t4_d),
    .en    (t4_en),
    .q     (t4_q)
  );

  // Helper task

  task t4
  (
    input [31:0]    d,
    input           en,
    input [31:0]    q
  );
  begin
    t4_d  = d;
    t4_en = en;
    #1;
    `VC_TEST_NET( t4_q, q );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 4, "vc_EnResetReg_w32" )
  begin

    #1;  t4_reset = 1'b1;
    #20; t4_reset = 1'b0;

    t4( 32'h0a0a0a0a, 1'b1, 32'hdeadbeef );
    t4( 32'h0b0b0b0b, 1'b1, 32'h0a0a0a0a );
    t4( 32'h0c0c0c0c, 1'b1, 32'h0b0b0b0b );
    t4( 32'h0d0d0d0d, 1'b0, 32'h0c0c0c0c );
    t4( 32'h0e0e0e0e, 1'b0, 32'h0c0c0c0c );
    t4( 32'h0f0f0f0f, 1'b0, 32'h0c0c0c0c );
    t4( 32'h1a1a1a1a, 1'b1, 32'h0c0c0c0c );
    t4( 32'h1b1b1b1b, 1'b1, 32'h1a1a1a1a );
    t4( 32'h1c1c1c1c, 1'b1, 32'h1b1b1b1b );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

