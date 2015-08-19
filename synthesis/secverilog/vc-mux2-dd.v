//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX2_DIFFDOMAIN_V
`define VC_MUX2_DIFFDOMAIN_V

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2_dd
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] 	in0, 
  input		 [p_nbits-1:0] 	in1,
  input		 [1:0]		   					in0_domain,
  input		 [1:0]		   					in1_domain,
  input                    					sel,
  output reg [p_nbits-1:0] 			out
  //output	 [1:0]		   					out_domain
);

  reg [1:0] 	out_domain;
  always @(*)
  begin
    case ( sel )
	  1'd0 : begin
			   out_domain = in0_domain;
			   out = in0;
		     end

	  1'd1 : begin
			   out_domain = in1_domain;
			   out = in1;
			 end

      default : out = {p_nbits{1'bx}};
    endcase
  end

endmodule

`endif /* VC_MUX2_DIFFDOMAIN_V */

