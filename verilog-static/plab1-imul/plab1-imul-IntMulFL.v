//=========================================================================
// Integer Multiplier Functional-Level Implementation
//=========================================================================

`ifndef PLAB1_IMUL_INT_MUL_FL_V
`define PLAB1_IMUL_INT_MUL_FL_V

`include "plab1-imul-msgs.v"
`include "vc-assert.v"

module plab1_imul_IntMulFL
(
  input                                             clk,
  input                                             reset,

  input                                             in_val,
  output                                            in_rdy,
  input      [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] in_msg,

  output reg                                        out_val,
  input                                             out_rdy,
  output reg [31:0]                                 out_msg
);

  //----------------------------------------------------------------------
  // Unpack Request Message
  //----------------------------------------------------------------------

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] in_msg_func;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    in_msg_a;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    in_msg_b;

  plab1_imul_MulDivReqMsgUnpack muldiv_req_msg_unpack
  (
    .msg  (in_msg),
    .func (in_msg_func),
    .a    (in_msg_a),
    .b    (in_msg_b)
  );

  //----------------------------------------------------------------------
  // Implement integer multiplication with * operator
  //----------------------------------------------------------------------

  reg [31:0] A;
  reg [31:0] B;
  reg [31:0] temp;

  reg full, in_go, out_go, done;

  always @( posedge clk ) begin

    // Ensure that we clear the full bit if we are in reset.

    if ( reset )
      full = 0;

    // At the end of the cycle, we AND together the val/rdy bits to
    // determine if the input/output message transactions occured.

    in_go  = in_val  && in_rdy;
    out_go = out_val && out_rdy;

    // If the output transaction occured, then clear the buffer full bit.
    // Note that we do this _first_ before we process the input
    // transaction so we can essentially pipeline this control logic.

    if ( out_go )
      full = 0;

    // If the input transaction occured, then write the input message
    // into our internal buffer and update the buffer full bit.

    if ( in_go ) begin
      A    = in_msg_a;
      B    = in_msg_b;
      full = 1;
    end

    // The output message is always the product of the buffer

    out_msg <= A * B;

    // The output message is valid if the buffer is full

    out_val <= full;

  end

  // Connect output ready signal to input to ensure pipeline behavior

  assign in_rdy = out_rdy;

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( in_val  );
      `VC_ASSERT_NOT_X( in_rdy  );
      `VC_ASSERT_NOT_X( out_val );
      `VC_ASSERT_NOT_X( out_rdy );
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  plab1_imul_MulDivReqMsgTrace in_msg_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (in_val),
    .rdy   (in_rdy),
    .msg   (in_msg)
  );

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    in_msg_trace.trace_module( trace );

    vc_trace_str( trace, "()" );

    $sformat( str, "%x", out_msg );
    vc_trace_str_val_rdy( trace, out_val, out_rdy, str );

  end
  endtask

endmodule

`endif /* PLAB1_IMUL_INT_MUL_FL_V */

