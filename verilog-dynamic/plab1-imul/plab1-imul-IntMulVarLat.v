//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef PLAB1_IMUL_INT_MUL_VAR_LAT_V
`define PLAB1_IMUL_INT_MUL_VAR_LAT_V

`include "plab1-imul-msgs.v"
`include "plab1-imul-CountZeros.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-arithmetic.v"
`include "vc-assert.v"

// Define datapath and control unit here

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//========================================================================
// Integer Multiplier Variable-Latency Datapath
//========================================================================

module plab1_imul_IntMulVarLatDpath
(
  input                                          clk,
  input                                          reset,

  // Data signals

  input [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0] in_msg_a,
  input [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0] in_msg_b,
  output [31:0]                                  out_msg,

  // Control signals (ctrl->dpath)

  input                                          a_mux_sel,
  input                                          b_mux_sel,
  input                                          add_mux_sel,
  input                                          result_mux_sel,
  input                                          result_en,

  // Control signals (dpath->ctrl)

  output                                         b_gt_zero,
  output                                         b_lsb
);

  // B mux

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]  right_shift_1_out;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]  b_mux_out;

  vc_Mux2#(`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS) b_mux
  (
   .sel (b_mux_sel),
   .in0 (right_shift_1_out),
   .in1 (in_msg_b),
   .out (b_mux_out)
  );

  // B register

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]  b_reg_out;

  vc_Reg#(`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS) b_reg
  (
   .clk (clk),
   .d   (b_mux_out),
   .q   (b_reg_out)
  );

  // > 0 Comparator

  vc_GtComparator#(32) b_gt_zero_comparator
  (
   .in0 (right_shift_1_out),
   .in1 (0),
   .out (b_gt_zero)
  );

  // CountZeros

  wire [3:0] count_zeros_out;

  plab1_imul_CountZeros count_zeros
  (
   .to_be_counted (b_reg_out[7:0]),
   .count (count_zeros_out)
  );

  // Variable right shift

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]  right_shift_out;

  vc_RightLogicalShifter#(`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS,4) right_shift
  (
   .in    (b_reg_out),
   .shamt (count_zeros_out),
   .out   (right_shift_out)
  );

  assign b_lsb = right_shift_out[0];

  // Right shift 1

  vc_RightLogicalShifter#(`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS,1) right_shift_1
  (
   .in    (right_shift_out),
   .shamt (1),
   .out   (right_shift_1_out)
  );

  // A mux

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  left_shift_1_out;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  a_mux_out;

  vc_Mux2#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS) a_mux
  (
   .sel (a_mux_sel),
   .in0 (left_shift_1_out),
   .in1 (in_msg_a),
   .out (a_mux_out)
  );

  // A register

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  a_reg_out;

  vc_Reg#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS) a_reg
  (
   .clk (clk),
   .d   (a_mux_out),
   .q   (a_reg_out)
  );

  // Variable left shift

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]  left_shift_out;

  vc_LeftLogicalShifter#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS,4) left_shift
  (
   .in    (a_reg_out),
   .shamt (count_zeros_out),
   .out   (left_shift_out)
  );

  // Left shift 1

  vc_LeftLogicalShifter#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS,1) left_shift_1
  (
   .in    (left_shift_out),
   .shamt (1),
   .out   (left_shift_1_out)
  );

  // Result mux

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  add_mux_out;
  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  result_mux_out;

  vc_Mux2#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS) result_mux
  (
   .sel (result_mux_sel),
   .in0 (add_mux_out),
   .in1 (0),
   .out (result_mux_out)
  );

  // Result register

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  result_reg_out;

  vc_EnReg#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS) result_reg
  (
   .clk   (clk),
   .d     (result_mux_out),
   .q     (result_reg_out),
   .reset (reset),
   .en    (result_en)
  );

  // Adder

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]  adder_out;

  vc_SimpleAdder#(`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS) adder
  (
   .in0 (left_shift_out),
   .in1 (result_reg_out),
   .out (adder_out)
  );

  // Add mux

  vc_Mux2#(`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS) add_mux
  (
   .sel (add_mux_sel),
   .in0 (adder_out),
   .in1 (result_reg_out),
   .out (add_mux_out)
  );

  // out_msg

  assign out_msg = result_reg_out;

endmodule

//========================================================================
// Integer Multiplier Variable-Latency Control
//========================================================================

module plab1_imul_IntMulVarLatCtrl
(
  input      clk,
  input      reset,

   // Dataflow signals

  input      in_val,
  output reg in_rdy,
  output reg out_val,
  input      out_rdy,

 // Control signals (ctrl->dpath)

  output reg a_mux_sel,
  output reg b_mux_sel,
  output reg add_mux_sel,
  output reg result_mux_sel,
  output reg result_en,

   // Control signals (dpath->ctrl)

  input      b_gt_zero,
  input      b_lsb
);

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  localparam STATE_IDLE = 2'd0;
  localparam STATE_CALC = 2'd1;
  localparam STATE_DONE = 2'd2;

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= STATE_IDLE;
    end
    else begin
      state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  wire in_go        = in_val  && in_rdy;
  wire out_go       = out_val && out_rdy;
  wire is_calc_done = !b_gt_zero;

  reg [1:0] state_reg;
  reg [1:0] state_next;

  always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE: if ( in_go        ) state_next = STATE_CALC;
      STATE_CALC: if ( is_calc_done ) state_next = STATE_DONE;
      STATE_DONE: if ( out_go       ) state_next = STATE_IDLE;

    endcase

  end

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------

  localparam a_x     = 1'dx;
  localparam a_lsh   = 1'd0;
  localparam a_ld    = 1'd1;

  localparam b_x     = 1'dx;
  localparam b_rsh   = 1'd0;
  localparam b_ld    = 1'd1;

  localparam res_x   = 1'dx;
  localparam res_add = 1'd0;
  localparam res_0   = 1'd1;

  localparam add_x   = 1'dx;
  localparam add_add = 1'd0;
  localparam add_res = 1'd1;

  task cs
  (
    input cs_in_rdy,
    input cs_out_val,
    input cs_a_mux_sel,
    input cs_b_mux_sel,
    input cs_add_mux_sel,
    input cs_result_mux_sel,
    input cs_result_en
  );
  begin
    in_rdy         = cs_in_rdy;
    out_val        = cs_out_val;
    a_mux_sel      = cs_a_mux_sel;
    b_mux_sel      = cs_b_mux_sel;
    add_mux_sel    = cs_add_mux_sel;
    result_mux_sel = cs_result_mux_sel;
    result_en      = cs_result_en;
  end
  endtask

  wire do_add_shift = b_lsb;
  wire do_shift     = !b_lsb;

  // Set outputs using a control signal "table"

  always @(*) begin

    cs( 0, 0, a_x, b_x, add_x, res_x, 0 );
    case ( state_reg )
      //                                  in  out a mux  b mux  add mux  res mux  res
      //                                  rdy val sel    sel    sel      sel      en
      STATE_IDLE:                     cs( 1,  0,  a_ld,  b_ld,  add_x,   res_0,   1 );
      STATE_CALC: if ( do_shift     ) cs( 0,  0,  a_lsh, b_rsh, add_res, res_add, 1 );
             else if ( do_add_shift ) cs( 0,  0,  a_lsh, b_rsh, add_add, res_add, 1 );
      STATE_DONE:                     cs( 0,  1,  a_x,   b_x,   add_x,   res_x,   0 );

    endcase

  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( in_val    );
      `VC_ASSERT_NOT_X( in_rdy    );
      `VC_ASSERT_NOT_X( out_val   );
      `VC_ASSERT_NOT_X( out_rdy   );
      `VC_ASSERT_NOT_X( result_en );
    end
  end

endmodule

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

module plab1_imul_IntMulVarLat
(
  input                                         clk,
  input                                         reset,

  input                                         in_val,
  output                                        in_rdy,
  input  [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] in_msg,

  output                                        out_val,
  input                                         out_rdy,
  output [31:0]                                 out_msg
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

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
  //
  // // Instantiate datapath and control models here and then connect them
  // // together. As a place holder, for now we simply pass input operand
  // // A through to the output, which obviously is not / correct.
  //
  // assign in_rdy  = out_rdy;
  // assign out_val = in_val;
  // assign out_msg = in_msg_a;
  //
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  wire a_mux_sel;
  wire b_mux_sel;
  wire add_mux_sel;
  wire result_mux_sel;
  wire result_en;
  wire b_gt_zero;
  wire b_lsb;

  plab1_imul_IntMulVarLatDpath dpath
  (
   .clk            (clk),
   .reset          (reset),
   .in_msg_a       (in_msg_a),
   .in_msg_b       (in_msg_b),
   .out_msg        (out_msg),
   .a_mux_sel      (a_mux_sel),
   .b_mux_sel      (b_mux_sel),
   .add_mux_sel    (add_mux_sel),
   .result_mux_sel (result_mux_sel),
   .result_en      (result_en),
   .b_gt_zero      (b_gt_zero),
   .b_lsb          (b_lsb)
  );

  plab1_imul_IntMulVarLatCtrl ctrl
  (
   .clk            (clk),
   .reset          (reset),
   .in_val         (in_val),
   .in_rdy         (in_rdy),
   .out_val        (out_val),
   .out_rdy        (out_rdy),
   .a_mux_sel      (a_mux_sel),
   .b_mux_sel      (b_mux_sel),
   .add_mux_sel    (add_mux_sel),
   .result_mux_sel (result_mux_sel),
   .result_en      (result_en),
   .b_gt_zero      (b_gt_zero),
   .b_lsb          (b_lsb)
  );

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  plab1_imul_MulDivReqMsgTrace#(p_nbits) in_msg_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (in_val),
    .rdy   (in_rdy),
    .msg   (in_msg)
  );

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0]       str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    in_msg_trace.trace_module( trace );

    vc_trace_str( trace, "(" );

    // Add extra line tracing for internal state here

    //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++

    $sformat( str, "%x", dpath.a_reg_out);
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    $sformat( str, "%x", dpath.b_reg_out);
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    $sformat( str, "%x", dpath.result_reg_out);
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    case ( ctrl.state_reg )
      ctrl.STATE_IDLE: vc_trace_str( trace, "I " );

      ctrl.STATE_CALC: begin
        if ( ctrl.do_add_shift )
          vc_trace_str( trace, "C+" );
        else if ( ctrl.do_shift )
          vc_trace_str( trace, "C " );
        else
          vc_trace_str( trace, "C?" );
      end

      ctrl.STATE_DONE: vc_trace_str( trace, "D " );
      default        : vc_trace_str( trace, "? " );
    endcase

    vc_trace_str( trace, ")" );

    //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++

    $sformat( str, "%x", out_msg );
    vc_trace_str_val_rdy( trace, out_val, out_rdy, str );

  end
  endtask

endmodule

`endif /* PLAB1_IMUL_INT_MUL_VAR_LAT_V */

