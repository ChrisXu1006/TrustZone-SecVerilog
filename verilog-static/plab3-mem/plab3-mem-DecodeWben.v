//========================================================================
// plab3-mem Decoder for Write Byte Enable
//========================================================================

`ifndef PLAB3_MEM_DECODER_WBEN_V
`define PLAB3_MEM_DECODER_WBEN_V

`include "vc-assert.v"

//------------------------------------------------------------------------
// Decoder for Wben
//------------------------------------------------------------------------

module plab3_mem_DecoderWben
#(
  parameter p_in_nbits = 2,

  // Local constants not meant to be set from outside the module
  parameter c_out_nbits = (1 << (p_in_nbits+2))
)(
  input  [p_in_nbits-1:0]  in,
  output [c_out_nbits-1:0] out
);

  genvar i;
  generate
    for ( i = 0; i < c_out_nbits; i = i + 1 )
    begin : decode
      assign out[i] = (in == i/4);
    end
  endgenerate

endmodule

`endif
