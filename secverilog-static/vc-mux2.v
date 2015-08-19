//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX2_V
`define VC_MUX2_V

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] {Domain L0}	in0, 
  input		 [p_nbits-1:0] {Domain L1}	in1,
  input		 [1:0]		   {L}			L0,
  input		 [1:0]		   {L}			L1,
  input                    {L}			sel,
  output reg [p_nbits-1:0] {SEL sel }	out
);

  //reg [1:0] {L}	out_domain;
  always @(*)
  begin
    case ( sel )
	  1'd0 : out = in0;
	  1'd1 : out = in1;
      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUX2_V */

