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
  input      [p_nbits-1:0] {Data in0_domain}	in0, 
  input		 [p_nbits-1:0] {Data in1_domain}	in1,
  input		 [1:0]		   {L}					in0_domain,
  input		 [1:0]		   {L}					in1_domain,
  input                    {L}					sel,
  output reg [p_nbits-1:0] {Data out_domain}	out
  output	 [1:0]		   {L}					out_domain
);

  reg [1:0] {L}	out_domain;
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

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module vc_Mux2_dd_Ctrl
#(
  parameter p_nbits = 1
)(
  input      [p_nbits-1:0] {Ctrl in0_domain}	in0, 
  input		 [p_nbits-1:0] {Ctrl in1_domain}	in1,
  input		 [1:0]		   {L}					in0_domain,
  input		 [1:0]		   {L}					in1_domain,
  input                    {L}					sel,
  output reg [p_nbits-1:0] {Ctrl out_domain}	out
  output	 [1:0]		   {L}					out_domain
);

  reg [1:0] {L}	out_domain;
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

