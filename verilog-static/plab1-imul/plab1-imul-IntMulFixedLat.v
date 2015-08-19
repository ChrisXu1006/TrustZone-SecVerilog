//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef PLAB1_IMUL_INT_MUL_FIXED_LAT_V
`define PLAB1_IMUL_INT_MUL_FIXED_LAT_V

`include "plab1-imul-msgs.v"
`include "vc-Counter.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-arithmetic.v"
`include "vc-assert.v"

// Define datapath and control unit here

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//========================================================================
// Integer Multiplier Fixed-Latency Datapath
//========================================================================

module plab1_imul_IntMulFixedLatDpath
(
  input                clk,
  input                reset,

  // Data signals

  input  [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0] in_msg_a,
  input  [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0] in_msg_b,
  output [31:0]                                   out_msg,

  // Control signals (ctrl->dpath)

  input  a_mux_sel,
  input  b_mux_sel,
  input  result_mux_sel,
  input  result_reg_en,
  input  add_mux_sel,

  // Status signals (dpath->ctrl)

  output b_lsb
);

  // B mux

  wire [31:0] rshifter_out;
  wire [31:0] b_mux_out;

  vc_Mux2#(32) b_mux
  (
    .sel   (b_mux_sel),
    .in0   (rshifter_out),
    .in1   (in_msg_b),
    .out   (b_mux_out)
  );

  // B register

  wire [31:0] b_reg_out;

  vc_Reg#(32) b_reg
  (
    .clk   (clk),
    .d     (b_mux_out),
    .q     (b_reg_out)
  );

  // Right shifter

  vc_RightLogicalShifter#(32,1) rshifter
  (
    .in    (b_reg_out),
    .shamt (1),
    .out   (rshifter_out)
  );

  // A mux

  wire [31:0] lshifter_out;
  wire [31:0] a_mux_out;

  vc_Mux2#(32) a_mux
  (
    .sel   (a_mux_sel),
    .in0   (lshifter_out),
    .in1   (in_msg_a),
    .out   (a_mux_out)
  );

  // A register

  wire [31:0] a_reg_out;

  vc_Reg#(32) a_reg
  (
    .clk   (clk),
    .d     (a_mux_out),
    .q     (a_reg_out)
  );

  // Left shifter

  vc_LeftLogicalShifter#(32,1) lshifter
  (
    .in    (a_reg_out),
    .shamt (1),
    .out   (lshifter_out)
  );

  // Result mux

  wire [31:0] add_mux_out;
  wire [31:0] result_mux_out;

  vc_Mux2#(32) result_mux
  (
    .sel   (result_mux_sel),
    .in0   (add_mux_out),
    .in1   (32'b0),
    .out   (result_mux_out)
  );

  // Result register

  wire [31:0] result_reg_out;

  vc_EnReg#(32) result_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (result_reg_en),
    .d     (result_mux_out),
    .q     (result_reg_out)
  );

  // Add

  wire [31:0] add_out;

  vc_SimpleAdder#(32) add
  (
    .in0   (a_reg_out),
    .in1   (result_reg_out),
    .out   (add_out)
  );

  // Result mux

  vc_Mux2#(32) add_mux
  (
    .sel   (add_mux_sel),
    .in0   (add_out),
    .in1   (result_reg_out),
    .out   (add_mux_out)
  );

  // Status signals

  assign b_lsb = b_reg_out[0];

  // Connect to output port

  assign out_msg = result_reg_out;

endmodule

//========================================================================
// Integer Multiplier Fixed-Latency Control Unit
//========================================================================

module plab1_imul_IntMulFixedLatCtrl
(
  input            clk,
  input            reset,

  // Dataflow signals

  input            in_val,
  output reg       in_rdy,
  output reg       out_val,
  input            out_rdy,

  // Control signals (ctrl->dpath)

  output reg       a_mux_sel,
  output reg       b_mux_sel,
  output reg       result_mux_sel,
  output reg       result_reg_en,
  output reg       add_mux_sel,

  // Status signals (dpath->ctrl)

  input            b_lsb
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
  // Counter
  //----------------------------------------------------------------------

  reg        counter_reset;
  reg        counter_increment;
  wire [5:0] counter_count;
  wire       counter_count_is_zero;
  wire       counter_count_is_max;

  vc_Counter#(6,0,32) counter
  (
    .clk           (clk),
    .reset         (counter_reset),
    .increment     (counter_increment),
    .decrement     (0),
    .count         (counter_count),
    .count_is_zero (counter_count_is_zero),
    .count_is_max  (counter_count_is_max)
  );

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  wire in_go        = in_val  && in_rdy;
  wire out_go       = out_val && out_rdy;
  wire is_calc_done = counter_count_is_max;

  reg  [1:0] state_reg;
  reg  [1:0] state_next;

  always @(*) begin

    state_next = state_reg;

    case ( state_reg )

      STATE_IDLE: if ( in_go    )     state_next = STATE_CALC;
      STATE_CALC: if ( is_calc_done ) state_next = STATE_DONE;
      STATE_DONE: if ( out_go   )     state_next = STATE_IDLE;

    endcase

  end

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------

  localparam a_x     = 1'dx;
  localparam a_rsh   = 1'd0;
  localparam a_ld    = 1'd1;

  localparam b_x     = 1'dx;
  localparam b_lsh   = 1'd0;
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
    input cs_result_mux_sel,
    input cs_result_reg_en,
    input cs_add_mux_sel,
    input cs_counter_reset,
    input cs_counter_increment
  );
  begin
    in_rdy            = cs_in_rdy;
    out_val           = cs_out_val;
    a_mux_sel         = cs_a_mux_sel;
    b_mux_sel         = cs_b_mux_sel;
    result_mux_sel    = cs_result_mux_sel;
    result_reg_en     = cs_result_reg_en;
    add_mux_sel       = cs_add_mux_sel;
    counter_reset     = cs_counter_reset;
    counter_increment = cs_counter_increment;
  end
  endtask

  // Labels for Mealy transistions

  wire do_sh_add = (b_lsb == 1); // do shift and add
  wire do_sh     = (b_lsb == 0); // do shift but no add

  // Set outputs using a control signal "table"

  always @(*) begin

    cs( 0, 0, a_x, b_x, res_x, 0, add_x, 0, 0 );
    case ( state_reg )

 //                             req resp a mux  b mux  res mux  res add mux  cntr cntr
 //                             rdy val  sel    sel    sel      en  sel      rst  inc
 STATE_IDLE:                cs( 1,  0,   a_ld,  b_ld,  res_0,   1,  add_x,   1,   0 );
 STATE_CALC: if (do_sh_add) cs( 0,  0,   a_rsh, b_lsh, res_add, 1,  add_add, 0,   1 );
        else if (do_sh    ) cs( 0,  0,   a_rsh, b_lsh, res_add, 1,  add_res, 0,   1 );
 STATE_DONE:                cs( 0,  1,   a_x,   b_x,   res_x,   0,  add_x,   1,   0 );

    endcase

  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( in_val        );
      `VC_ASSERT_NOT_X( in_rdy        );
      `VC_ASSERT_NOT_X( out_val       );
      `VC_ASSERT_NOT_X( out_rdy       );
      `VC_ASSERT_NOT_X( result_reg_en );
    end
  end

endmodule

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module plab1_imul_IntMulFixedLat
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

  //----------------------------------------------------------------------
  // Control Unit
  //----------------------------------------------------------------------

  wire a_mux_sel;
  wire b_mux_sel;
  wire result_mux_sel;
  wire result_reg_en;
  wire add_mux_sel;
  wire b_lsb;

  plab1_imul_IntMulFixedLatCtrl ctrl
  (
    .clk            (clk),
    .reset          (reset),

    .in_val         (in_val),
    .in_rdy         (in_rdy),
    .out_val        (out_val),
    .out_rdy        (out_rdy),

    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_reg_en  (result_reg_en),
    .add_mux_sel    (add_mux_sel),
    .b_lsb          (b_lsb)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  plab1_imul_IntMulFixedLatDpath dpath
  (
    .clk            (clk),
    .reset          (reset),

    .in_msg_a       (in_msg_a),
    .in_msg_b       (in_msg_b),
    .out_msg        (out_msg),

    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .result_mux_sel (result_mux_sel),
    .result_reg_en  (result_reg_en),
    .add_mux_sel    (add_mux_sel),
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

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    in_msg_trace.trace_module( trace );

    vc_trace_str( trace, "(" );

    // Add extra line tracing for internal state here

    //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++

    $sformat( str, "%x", dpath.a_reg_out );
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    $sformat( str, "%x", dpath.b_reg_out );
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    $sformat( str, "%x", dpath.result_reg_out );
    vc_trace_str( trace, str );
    vc_trace_str( trace, " " );

    case ( ctrl.state_reg )
      ctrl.STATE_IDLE: vc_trace_str( trace, "I " );

      ctrl.STATE_CALC: begin
        if ( ctrl.do_sh_add )
          vc_trace_str( trace, "C+" );
        else if ( ctrl.do_sh )
          vc_trace_str( trace, "C " );
        else
          vc_trace_str( trace, "C?" );
      end

      ctrl.STATE_DONE: vc_trace_str( trace, "D " );
      default        : vc_trace_str( trace, "? " );
    endcase

    //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++

    vc_trace_str( trace, ")" );

    $sformat( str, "%x", out_msg );
    vc_trace_str_val_rdy( trace, out_val, out_rdy, str );

  end
  endtask

endmodule

`endif /* PLAB1_IMUL_INT_MUL_FIXED_LAT_V */

