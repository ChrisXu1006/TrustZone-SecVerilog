//========================================================================
// plab1-imul-msgs Unit Tests
//========================================================================

`include "plab1-imul-msgs.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab1-imul-msgs" )

  //----------------------------------------------------------------------
  // Test MulDivReqMsg
  //----------------------------------------------------------------------

  reg  [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] t1_pack_func;
  reg  [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    t1_pack_a;
  reg  [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    t1_pack_b;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0]      t1_pack_msg;

  plab1_imul_MulDivReqMsgPack t1_pack
  (
    .func (t1_pack_func),
    .a    (t1_pack_a),
    .b    (t1_pack_b),
    .msg  (t1_pack_msg)
  );

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] t1_unpack_func;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    t1_unpack_a;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    t1_unpack_b;

  plab1_imul_MulDivReqMsgUnpack t1_unpack
  (
    .msg  (t1_pack_msg),
    .func (t1_unpack_func),
    .a    (t1_unpack_a),
    .b    (t1_unpack_b)
  );

  reg t1_reset = 1;
  reg t1_val;

  plab1_imul_MulDivReqMsgTrace t1_trace
  (
    .clk    (clk),
    .reset  (t1_reset),
    .val    (t1_val),
    .rdy    (1),
    .msg    (t1_pack_msg)
  );

  // Helper task

  task t1
  (
    input                                             val,
    input [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] func,
    input [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    a,
    input [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    b
  );
  begin
    t1_val       = val;
    t1_pack_func = func;
    t1_pack_a    = a;
    t1_pack_b    = b;
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_func, func );
    `VC_TEST_NET( t1_unpack_a,    a );
    `VC_TEST_NET( t1_unpack_b,    b );
    #9;
  end
  endtask

  // Helper localparams

  localparam t1_mul  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL;
  localparam t1_div  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIV;
  localparam t1_divu = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIVU;
  localparam t1_rem  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REM;
  localparam t1_remu = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REMU;
  localparam t1_x    = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_X;

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "simple" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    // Test mul messages

    t1( 0, t1_x,    32'hxx, 32'hxx );
    t1( 1, t1_mul,  32'h00, 32'h01 );
    t1( 1, t1_mul,  32'h42, 32'h01 );
    t1( 1, t1_mul,  32'h18, 32'h68 );

    // Test div messages

    t1( 0, t1_x,    32'hxx, 32'hxx );
    t1( 1, t1_div,  32'h00, 32'h01 );
    t1( 1, t1_div,  32'h42, 32'h01 );
    t1( 1, t1_div,  32'h18, 32'h68 );

    // Test divu messages

    t1( 0, t1_x,    32'hxx, 32'hxx );
    t1( 1, t1_divu, 32'h00, 32'h01 );
    t1( 1, t1_divu, 32'h42, 32'h01 );
    t1( 1, t1_divu, 32'h18, 32'h68 );

    // Test rem messages

    t1( 0, t1_x,    32'hxx, 32'hxx );
    t1( 1, t1_rem,  32'h00, 32'h01 );
    t1( 1, t1_rem,  32'h42, 32'h01 );
    t1( 1, t1_rem,  32'h18, 32'h68 );

    // Test remu messages

    t1( 0, t1_x,    32'hxx, 32'hxx );
    t1( 1, t1_remu, 32'h00, 32'h01 );
    t1( 1, t1_remu, 32'h42, 32'h01 );
    t1( 1, t1_remu, 32'h18, 32'h68 );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

