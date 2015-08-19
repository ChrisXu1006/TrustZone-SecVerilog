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
  input      [p_nbits-1:0] 	in0, 
  input		 [p_nbits-1:0] 	in1, 
  input      [p_nbits-1:0] 	in2,
  input      [0:0]		   					in0_domain,
  input		 [0:0]		   					in1_domain,
  input		 [0:0]		   					in2_domain,
  input      [1:0] 		   					sel,
  output reg [p_nbits-1:0] 	out,
  output	 [0:0]		   					out_domain
);

  reg [0:0]		out_domain;

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

