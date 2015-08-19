//========================================================================
// Verilog Components: RandomNumGen
//========================================================================

`ifndef VC_RANDOM_NUM_GEN_V
`define VC_RANDOM_NUM_GEN_V

`include "vc-regs.v"

//------------------------------------------------------------------------
// Pseudo Random Number Generator
//------------------------------------------------------------------------

module vc_RandomNumGen
#(
  parameter p_out_nbits = 4,            // Bitwidth of output
  parameter p_seed      = 32'hdeadbeef  // Random seed, should be 32 bits
)(
  input                    clk,
  input                    reset,
  input                    next,   // Generate next value
  output [p_out_nbits-1:0] out     // Current random number
);

  // State

  wire        rand_num_en;
  wire [31:0] rand_num_next;
  wire [31:0] rand_num;

  vc_EnResetReg#(32,p_seed) rand_num_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (rand_num_en),
    .d     (rand_num_next),
    .q     (rand_num)
  );

  // Logic for a simple random numbers using the Tausworthe algorithm

  wire [31:0] temp = ((rand_num >> 17) ^ rand_num);
  assign rand_num_next = ((temp << 15) ^ temp);
  assign rand_num_en = next;

  // We XOR higher order bits to create smaller output numbers

  reg out;

  integer i;
  always @(*)
  begin
    out = rand_num[p_out_nbits-1:0];
    for ( i = (2*p_out_nbits-1); i < 31; i = i + p_out_nbits )
      out = out ^ rand_num[i-:p_out_nbits];
  end

endmodule

`endif /* VC_RANDOM_NUM_GEN_V */

