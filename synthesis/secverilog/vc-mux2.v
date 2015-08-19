//========================================================================
// Verilog Components: Muxes
//========================================================================

`ifndef VC_MUX2_V
`define VC_MUX2_V

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux21
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] 	in0, 
  input		 [p_nbits-1:0] 	in1,
  input		 		   		L0,
  input		 		   		L1,
  input                    			sel,
  output reg [p_nbits-1:0]		out
);

  //reg [1:0] 	out_domain;
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

