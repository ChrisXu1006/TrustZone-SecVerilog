//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX3_V
`define VC_MUX3_V

//------------------------------------------------------------------------
// 3 Input Mux
//------------------------------------------------------------------------

module vc_Mux31
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] {Domain in0_domain}	in0, 
  input		 [p_nbits-1:0] {Domain in1_domain}	in1, 
  input      [p_nbits-1:0] {Domain in2_domain}	in2,
  input      [0:0]		   {L}					in0_domain,
  input		 [0:0]		   {L}					in1_domain,
  input		 [0:0]		   {L}					in2_domain,
  input      [1:0] 		   {L}					sel,
  output reg [p_nbits-1:0] {Domain out_domain}	out,
  output	 [0:0]		   {L}					out_domain
);

  reg [0:0]	{L}	out_domain;

  always @(*)
  begin
    case ( sel )
	  2'd0 : begin
			   out_domain = in0_domain;
			   out = in0;
			 end

	  2'd1 : begin
			   out_domain = in1_domain;
			   out = in1;
			 end

	  2'd2 : begin
			   out_domain = in2_domain;
			   out = in2;
			 end

      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUX3_SAMEDOMAIN_V */

