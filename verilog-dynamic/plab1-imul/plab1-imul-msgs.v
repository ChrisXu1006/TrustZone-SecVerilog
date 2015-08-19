//========================================================================
// plab1-imul-msgs : Integer Multiplier/Divider Request Message
//========================================================================
// A multiplier/divider request message contains input data and the
// desired operation and is sent to a multipler/divider unit. The unit
// will respond with a multiplier/divider response message.
//
// Message Format:
//
//   66  64 63       32 31        0
//  +------+-----------+-----------+
//  | func | operand b | operand a |
//  +------+-----------+-----------+
//

`ifndef PLAB1_IMUL_MSGS_V
`define PLAB1_IMUL_MSGS_V

//------------------------------------------------------------------------
// Message defines
//------------------------------------------------------------------------

// Size of message

`define PLAB1_IMUL_MULDIV_REQ_MSG_NBITS         67

// Size and enums for each field

`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS     3
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL    3'd0
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIV    3'd1
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIVU   3'd2
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REM    3'd3
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REMU   3'd4
`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_X      3'dx

`define PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS      32
`define PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS      32

// Location of each field

`define PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_FIELD  66:64
`define PLAB1_IMUL_MULDIV_REQ_MSG_A_FIELD     63:32
`define PLAB1_IMUL_MULDIV_REQ_MSG_B_FIELD     31:0

//------------------------------------------------------------------------
// Pack message
//------------------------------------------------------------------------

module plab1_imul_MulDivReqMsgPack
(
  // Unpacked message

  input [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] func,
  input [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    a,
  input [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    b,

  // Packed message

  output [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0]     msg
);

  assign msg[`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_FIELD] = func;
  assign msg[`PLAB1_IMUL_MULDIV_REQ_MSG_A_FIELD]    = a;
  assign msg[`PLAB1_IMUL_MULDIV_REQ_MSG_B_FIELD]    = b;

endmodule

//------------------------------------------------------------------------
// Unpack message
//------------------------------------------------------------------------

module plab1_imul_MulDivReqMsgUnpack
(
  // Packed message

  input  [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0]      msg,

  // Unpacked message

  output [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] func,
  output [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0]    a,
  output [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0]    b
);

  assign a    = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_A_FIELD];
  assign b    = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_B_FIELD];
  assign func = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_FIELD];

endmodule

//------------------------------------------------------------------------
// Convert message to string
//------------------------------------------------------------------------

module plab1_imul_MulDivReqMsgTrace
(
  input                                        clk,
  input                                        reset,
  input                                        val,
  input                                        rdy,
  input [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] msg
);

  // Local constants

  localparam c_mul  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL;
  localparam c_div  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIV;
  localparam c_divu = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_DIVU;
  localparam c_rem  = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REM;
  localparam c_remu = `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_REMU;

  // Extract fields

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS-1:0] func
    = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_FIELD];

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_A_NBITS-1:0] a
    = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_A_FIELD];

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_B_NBITS-1:0] b
    = msg[`PLAB1_IMUL_MULDIV_REQ_MSG_B_FIELD];

  // Line tracing

  `include "vc-trace-tasks.v"

  reg [8*4-1:0] func_str;
  reg [(4+`VC_TRACE_NBITS_TO_NCHARS(32)*2+2)*8-1:0] str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    if ( func === `PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_NBITS'bx )
      func_str = "xxxx";
    else begin
      case ( func )
        c_mul   : func_str = "mul_";
        c_div   : func_str = "div_";
        c_divu  : func_str = "divu";
        c_rem   : func_str = "rem_";
        c_remu  : func_str = "remu";
        default : func_str = "????";
      endcase
    end

    $sformat( str, "%s:%x:%x", func_str, a, b );
    vc_trace_str_val_rdy( trace, val, rdy, str );

  end
  endtask

endmodule

`endif /* PLAB1_IMUL_MULDIV_MSGS_V */

