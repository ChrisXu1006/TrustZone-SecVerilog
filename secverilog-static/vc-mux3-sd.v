//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX3_SAMEDOMAIN_V
`define VC_MUX3_SAMEDOMAIN_V

//------------------------------------------------------------------------
// 3 Input Mux
//------------------------------------------------------------------------

module vc_Mux3_sd
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] {Domain domain}	in0, 
  input		 [p_nbits-1:0] {Domain domain}	in1, 
  input      [p_nbits-1:0] {Domain domain}	in2,
  input		 [1:0]		   {L}				domain,
  input      [1:0] 		   {Domain domain}	sel,
  output reg [p_nbits-1:0] {Domain domain}	out
);

  always @(*)
  begin
    case ( sel )
	  2'd0 : begin
			   out = in0;
			 end

	  2'd1 : begin
			   out = in1;
			 end

	  2'd2 : begin
			   out = in2;
			 end

      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUX3_SAMEDOMAIN_V */

