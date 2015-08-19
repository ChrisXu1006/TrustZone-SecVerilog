//========================================================================
// Verilog Components: Arithmetic Components
//========================================================================

`ifndef VC_ARITHMETIC_V
`define VC_ARITHMETIC_V

//------------------------------------------------------------------------
// Adders
//------------------------------------------------------------------------

module vc_Adder
#(
  parameter p_nbits = 1
)(
  input  [p_nbits-1:0] in0,
  input  [p_nbits-1:0] in1,
  input                cin,
  output [p_nbits-1:0] out,
  output               cout
);

  assign {cout,out} = in0 + in1 + cin;

endmodule

module vc_SimpleAdder
#(
  parameter p_nbits = 1
)(
  input                {L} domain,
  input  [p_nbits-1:0] {Domain domain} in0,
  input  [p_nbits-1:0] {Domain domain} in1,
  output [p_nbits-1:0] {Domain domain} out
);

  assign out = in0 + in1;

endmodule

//------------------------------------------------------------------------
// Subtractor
//------------------------------------------------------------------------

module vc_Subtractor
#(
  parameter p_nbits = 1
)(
  input  [p_nbits-1:0] in0,
  input  [p_nbits-1:0] in1,
  output [p_nbits-1:0] out
);

  assign out = in0 - in1;

endmodule

//------------------------------------------------------------------------
// Incrementer
//------------------------------------------------------------------------

module vc_Incrementer
#(
  parameter p_nbits     = 1,
  parameter p_inc_value = 1
)(
  input                {L} domain,
  input  [p_nbits-1:0] {Data domain} in,
  output [p_nbits-1:0] {Data domain} out
);

  assign out = in + p_inc_value;

endmodule

//------------------------------------------------------------------------
// Incrementer
//------------------------------------------------------------------------

module vc_Incrementer_Ctrl
#(
  parameter p_nbits     = 1,
  parameter p_inc_value = 1
)(
  input                {L} domain,
  input  [p_nbits-1:0] {Ctrl domain} in,
  output [p_nbits-1:0] {Ctrl domain} out
);

  assign out = in + p_inc_value;

endmodule

//------------------------------------------------------------------------
// ZeroExtender
//------------------------------------------------------------------------

module vc_ZeroExtender
#(
  parameter p_in_nbits  = 1,
  parameter p_out_nbits = 8
)(
  input                    {L} domain,
  input   [p_in_nbits-1:0] {Domain domain} in,
  output [p_out_nbits-1:0] {Domain domain} out
);

  assign out = { {( p_out_nbits - p_in_nbits ){1'b0}}, in };

endmodule

//------------------------------------------------------------------------
// SignExtender
//------------------------------------------------------------------------

module vc_SignExtender
#(
 parameter p_in_nbits = 1,
 parameter p_out_nbits = 8
)
(
  input                    {L} domain,
  input   [p_in_nbits-1:0] {Domain domain} in,
  output [p_out_nbits-1:0] {Domain domain} out
);

  assign out = { {(p_out_nbits-p_in_nbits){in[p_in_nbits-1]}}, in };

endmodule

//------------------------------------------------------------------------
// ZeroComparator
//------------------------------------------------------------------------

module vc_ZeroComparator
#(
  parameter p_nbits = 1
)(
  input                {L} domain,
  input  [p_nbits-1:0] {Domain domain} in,
  output               {L} out
);

  assign out = ( in == {p_nbits{1'b0}} );

endmodule

//------------------------------------------------------------------------
// EqComparator
//------------------------------------------------------------------------

module vc_EqComparator
#(
  parameter p_nbits = 1
)(
  input                {L} domain,
  input  [p_nbits-1:0] {Data domain} in0,
  input  [p_nbits-1:0] {Data domain} in1,
  output               {Ctrl domain} out
);

  assign out = ( in0 == in1 );

endmodule

//------------------------------------------------------------------------
// LtComparator
//------------------------------------------------------------------------

module vc_LtComparator
#(
  parameter p_nbits = 1
)(
  input  [p_nbits-1:0] in0,
  input  [p_nbits-1:0] in1,
  output               out
);

  assign out = ( in0 < in1 );

endmodule

//------------------------------------------------------------------------
// GtComparator
//------------------------------------------------------------------------

module vc_GtComparator
#(
  parameter p_nbits = 1
)(
  input                {L}  domain,
  input  [p_nbits-1:0] {Data domain} in0,
  input  [p_nbits-1:0] {Data domain} in1,
  output               {Ctrl domain} out
);

  assign out = ( in0 > in1 );

endmodule

//------------------------------------------------------------------------
// GEtComparator
//------------------------------------------------------------------------

module vc_GEtComparator
#(
    parameter p_nbits = 1
)(
    input                 {L}             domain,
    input   [p_nbits-1:0] {Domain domain} in0,
    input   [p_nbits-1:0] {Domain domain} in1,
    output                {Domain domain} out
);
    assign out = ( in0 >= in1 );

endmodule 

//------------------------------------------------------------------------
// LeftLogicalShifter
//------------------------------------------------------------------------

module vc_LeftLogicalShifter
#(
  parameter p_nbits       = 1,
  parameter p_shamt_nbits = 1 )
(
  input                      {L} domain,
  input        [p_nbits-1:0] {Domain domain} in,
  input  [p_shamt_nbits-1:0] {Domain domain} shamt,
  output       [p_nbits-1:0] {Domain domain} out
);

  assign out = ( in << shamt );

endmodule

//------------------------------------------------------------------------
// RightLogicalShifter
//------------------------------------------------------------------------

module vc_RightLogicalShifter
#(
  parameter p_nbits       = 1,
  parameter p_shamt_nbits = 1
)(
  input                      {L} domain,
  input        [p_nbits-1:0] {Domain domain} in,
  input  [p_shamt_nbits-1:0] {Domain domain} shamt,
  output       [p_nbits-1:0] {Domain domain} out
);

  assign out = ( in >> shamt );

endmodule

`endif /* VC_ARITHMETIC_V */

