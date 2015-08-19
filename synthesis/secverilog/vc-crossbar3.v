//========================================================================
// Verilog Components: Crossbars
//========================================================================

`ifndef VC_CROSSBAR3_V
`define VC_CROSSBAR3_V

`include "vc-mux3.v"

//------------------------------------------------------------------------
// 3 input, 3 output crossbar
//------------------------------------------------------------------------

module vc_Crossbar3
#(
  parameter p_nbits = 32
)
(
  input  [p_nbits-1:0]   	in0,
  input  [p_nbits-1:0]   	in1,
  input  [p_nbits-1:0]   	in2,

  input	 [0:0]			 					in0_domain,
  input  [0:0]			 					in1_domain,
  input  [0:0]			 					in2_domain,

  input  [1:0]           					sel0,
  input  [1:0]           					sel1,
  input  [1:0]           					sel2,

  output [p_nbits-1:0]   	out0,
  output [p_nbits-1:0]   	out1,
  output [p_nbits-1:0]   	out2,

  output [0:0]			 					out0_domain,
  output [0:0]			 					out1_domain,
  output [0:0]			 					out2_domain
);

  reg 	 [0:0]									out0_domain;
  reg	 [0:0]									out1_domain;
  reg    [0:0]									out2_domain;

  vc_Mux31#(p_nbits) out0_mux
  (
    .in0 		(in0),
    .in1 		(in1),
    .in2 		(in2),
	.in0_domain	(in0_domain),
	.in1_domain (in1_domain),
	.in2_domain	(in2_domain),	
    .sel 		(sel0),
    .out 		(out0),
	.out_domain	(out0_domain)
  );

  vc_Mux31#(p_nbits) out1_mux
  (
    .in0 		(in0),
    .in1 		(in1),
    .in2 		(in2),
	.in0_domain	(in0_domain),
	.in1_domain	(in1_domain),
	.in2_domain (in2_domain),
    .sel 		(sel1),
    .out 		(out1),
	.out_domain	(out1_domain)
  );

  vc_Mux31#(p_nbits) out2_mux
  (
    .in0 		(in0),
    .in1 		(in1),
    .in2 		(in2),
	.in0_domain	(in0_domain),
	.in1_domain	(in1_domain),
	.in2_domain	(in2_domain),
    .sel 		(sel2),
    .out 		(out2),
	.out_domain	(out2_domain)
  );

endmodule

`endif /* VC_CROSSBAR3_V */
