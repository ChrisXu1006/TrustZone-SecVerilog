//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX2_SAMEDOMAIN_V
`define VC_MUX2_SAMEDOMAIN_V

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2_sd
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] {Domain domain}		in0, 
  input		 [p_nbits-1:0] {Domain domain}		in1,
  input					   {L}					domain,
  input                    {L}					sel,
  output reg [p_nbits-1:0] {Domain domain}		out
);

  always @(*)
  begin
    case ( sel )
	  1'd0 : begin
			   out = in0;
		     end

	  1'd1 : begin
			   out = in1;
			 end

      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUX2_SAMEDOMAIN_V */

