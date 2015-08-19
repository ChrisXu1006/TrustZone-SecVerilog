//========================================================================
// Verilog Components: Register Files
//========================================================================

`ifndef VC_REGFILES_V
`define VC_REGFILES_V

//------------------------------------------------------------------------
// 1r1w register file
//------------------------------------------------------------------------

module vc_Regfile_1r1w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input                     clk,
  input                     reset,

  // Read port (combinational read)

  input  [c_addr_nbits-1:0] read_addr,
  output [p_data_nbits-1:0] read_data,

  // Write port (sampled on the rising clock edge)

  input                     write_en,
  input  [c_addr_nbits-1:0] write_addr,
  input  [p_data_nbits-1:0] write_data
);

  reg [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data = rfile[read_addr];

  // Write on positive clock edge

  always @( posedge clk )
    if ( write_en )
      rfile[write_addr] <= write_data;

endmodule

//------------------------------------------------------------------------
// 1r1w register file with reset
//------------------------------------------------------------------------

module vc_ResetRegfile_1r1w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,
  parameter p_reset_value = 0,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input                     clk,
  input                     reset,

  // Read port (combinational read)

  input  [c_addr_nbits-1:0] read_addr,
  output [p_data_nbits-1:0] read_data,

  // Write port (sampled on the rising clock edge)

  input                     write_en,
  input [c_addr_nbits-1:0]  write_addr,
  input [p_data_nbits-1:0]  write_data
);

  reg [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data = rfile[read_addr];

  // Write on positive clock edge. We have to use a generate statement to
  // allow us to include the reset logic for each individual register.

  genvar i;
  generate
    for ( i = 0; i < p_num_entries; i = i+1 )
    begin : wport
      always @( posedge clk )
        if ( reset )
          rfile[i] <= p_reset_value;
        else if ( write_en && (i == write_addr) )
          rfile[i] <= write_data;
    end
  endgenerate

endmodule

//------------------------------------------------------------------------
// 2r1w register file
//------------------------------------------------------------------------

module vc_Regfile_2r1w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input                     clk,
  input                     reset,

  // Read port 0 (combinational read)

  input  [c_addr_nbits-1:0] read_addr0,
  output [p_data_nbits-1:0] read_data0,

  // Read port 1 (combinational read)

  input  [c_addr_nbits-1:0] read_addr1,
  output [p_data_nbits-1:0] read_data1,

  // Write port (sampled on the rising clock edge)

  input                     write_en,
  input [c_addr_nbits-1:0]  write_addr,
  input [p_data_nbits-1:0]  write_data
);

  reg [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data0 = rfile[read_addr0];
  assign read_data1 = rfile[read_addr1];

  // Write on positive clock edge

  always @( posedge clk )
    if ( write_en )
      rfile[write_addr] <= write_data;

endmodule

//------------------------------------------------------------------------
// 2r2w register file
//------------------------------------------------------------------------

module vc_Regfile_2r2w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input                     clk,
  input                     reset,

  // Read port 0 (combinational read)

  input  [c_addr_nbits-1:0] read_addr0,
  output [p_data_nbits-1:0] read_data0,

  // Read port 1 (combinational read)

  input  [c_addr_nbits-1:0] read_addr1,
  output [p_data_nbits-1:0] read_data1,

  // Write port (sampled on the rising clock edge)

  input                     write_en0,
  input [c_addr_nbits-1:0]  write_addr0,
  input [p_data_nbits-1:0]  write_data0,

  // Write port (sampled on the rising clock edge)

  input                     write_en1,
  input [c_addr_nbits-1:0]  write_addr1,
  input [p_data_nbits-1:0]  write_data1
);

  reg [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data0 = rfile[read_addr0];
  assign read_data1 = rfile[read_addr1];

  // Write on positive clock edge

  always @( posedge clk ) begin

    if ( write_en0 )
      rfile[write_addr0] <= write_data0;

    if ( write_en1 )
      rfile[write_addr1] <= write_data1;

  end

endmodule

`endif /* VC_REGFILES_V */

