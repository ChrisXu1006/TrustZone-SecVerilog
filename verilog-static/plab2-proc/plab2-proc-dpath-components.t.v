//========================================================================
// Unit Tests for Pipelined Processor Datapath Components
//========================================================================

`include "plab2-proc-dpath-components.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab2-proc-dpath-components" )

  //----------------------------------------------------------------------
  // Test plab2_proc_BrTarget
  //----------------------------------------------------------------------

  reg  [31:0] t1_pc_plus4;
  reg  [31:0] t1_imm_sext;
  wire [31:0] t1_br_target;

  plab2_proc_BrTarget t1_br_targ
  (
    .pc_plus4   (t1_pc_plus4),
    .imm_sext   (t1_imm_sext),
    .br_target  (t1_br_target)
  );

  task t1
  (
    input [31:0] pc_plus4,
    input [31:0] imm_sext,
    input [31:0] br_target
  );
  begin
    t1_pc_plus4 = pc_plus4;
    t1_imm_sext = imm_sext;
    #1;
    `VC_TEST_NOTE_INPUTS_2( pc_plus4, imm_sext );
    `VC_TEST_NET( t1_br_target, br_target );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 1, "plab2_proc_BrTarget" )
  begin
    //  pc_plus4      imm_sext      br_target
    t1( 32'h00000000, 32'h00000000, 32'h00000000 );
    t1( 32'hfee00dd0, 32'h00000000, 32'hfee00dd0 );
    t1( 32'h042309ec, 32'h00000d25, 32'h04233e80 );
    t1( 32'h00399e00, 32'hffffffa3, 32'h00399c8c );
    t1( 32'h00000000, 32'h00201ee2, 32'h00807b88 );
    t1( 32'hffffffff, 32'hffffffff, 32'hfffffffb );
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test plab2_proc_Regfile
  //----------------------------------------------------------------------

  reg         t2_reset;

  reg  [ 4:0] t2_read_addr0;
  wire [31:0] t2_read_data0;

  reg  [ 4:0] t2_read_addr1;
  wire [31:0] t2_read_data1;

  reg         t2_write_en;
  reg  [ 4:0] t2_write_addr;
  reg  [31:0] t2_write_data;

  plab2_proc_Regfile t2_regfile
  (
    .clk          (clk),
    .reset        (t2_reset),

    .read_addr0   (t2_read_addr0),
    .read_data0   (t2_read_data0),

    .read_addr1   (t2_read_addr1),
    .read_data1   (t2_read_data1),

    .write_en     (t2_write_en),
    .write_addr   (t2_write_addr),
    .write_data   (t2_write_data)
  );

  task t2
  (
    input [ 4:0]  read_addr0,
    input [31:0]  read_data0,

    input [ 4:0]  read_addr1,
    input [31:0]  read_data1,

    input         write_en,
    input [ 4:0]  write_addr,
    input [31:0]  write_data
  );
  begin
    t2_read_addr0 = read_addr0;
    t2_read_addr1 = read_addr1;
    t2_write_en   = write_en;
    t2_write_addr = write_addr;
    t2_write_data = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr0, read_data0, read_addr1, read_data1 );
    `VC_TEST_NOTE_INPUTS_3( write_en, write_addr, write_data );
    `VC_TEST_NET( t2_read_data0, read_data0 );
    `VC_TEST_NET( t2_read_data1, read_data1 );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 2, "plab2_proc_Regfile" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;


    //  -- read0 --  -- read1 --  --- write ---
    //  addr data    addr data    wen addr data

    t2( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx );

    // Cold read 0, should be 0

    t2( 'h0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t2( 'hx, 'h??,   'h0, 'h00,   0, 'hx, 'hxx );
    t2( 'h0, 'h00,   'h0, 'h00,   0, 'hx, 'hxx );

    // Write an entry and read it -- we expect it to be 0

    t2( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t2(   0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t2( 'hx, 'h??,     0, 'h00,   0, 'hx, 'hxx );
    t2(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );

    // Fill with entries then read

    t2( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   1, 'hbb );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   2, 'hcc );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   3, 'hdd );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   4, 'hee );

    t2(   0, 'h00,   'hx, 'h??,   0, 'hx, 'hxx );
    t2( 'hx, 'h??,     1, 'hbb,   0, 'hx, 'hxx );
    t2(   2, 'hcc,   'hx, 'h??,   0, 'hx, 'hxx );
    t2( 'hx, 'h??,     3, 'hdd,   0, 'hx, 'hxx );
    t2(   4, 'hee,   'hx, 'h??,   0, 'hx, 'hxx );

    t2(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );
    t2(   1, 'hbb,     1, 'hbb,   0, 'hx, 'hxx );
    t2(   2, 'hcc,     2, 'hcc,   0, 'hx, 'hxx );
    t2(   3, 'hdd,     3, 'hdd,   0, 'hx, 'hxx );
    t2(   4, 'hee,     4, 'hee,   0, 'hx, 'hxx );

    // Overwrite entries and read again

    t2( 'hx, 'h??,   'hx, 'h??,   1,   0, 'h00 );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   1, 'h11 );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   2, 'h22 );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   3, 'h33 );
    t2( 'hx, 'h??,   'hx, 'h??,   1,   4, 'h44 );

    t2(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );
    t2(   1, 'h11,     1, 'h11,   0, 'hx, 'hxx );
    t2(   2, 'h22,     2, 'h22,   0, 'hx, 'hxx );
    t2(   3, 'h33,     3, 'h33,   0, 'hx, 'hxx );
    t2(   4, 'h44,     4, 'h44,   0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t2(   1, 'h11,     2, 'h22,   1,   0, 'h0a );
    t2(   2, 'h22,     3, 'h33,   1,   1, 'h1b );
    t2(   3, 'h33,     4, 'h44,   1,   2, 'h2c );
    t2(   4, 'h44,     0, 'h00,   1,   3, 'h3d );
    t2(   0, 'h00,     1, 'h1b,   1,   4, 'h4e );

    // Concurrent read/writes (to same addr)

    t2(   0, 'h00,     0, 'h00,   1,   0, 'h5a );
    t2(   1, 'h1b,     1, 'h1b,   1,   1, 'h6b );
    t2(   2, 'h2c,     2, 'h2c,   1,   2, 'h7c );
    t2(   3, 'h3d,     3, 'h3d,   1,   3, 'h8d );
    t2(   4, 'h4e,     4, 'h4e,   1,   4, 'h9e );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test plab2_proc_Alu
  //----------------------------------------------------------------------

  reg  [31:0] t3_in0;
  reg  [31:0] t3_in1;
  reg  [ 3:0] t3_fn;

  wire [31:0] t3_out;

  plab2_proc_Alu t3_alu
  (
    .in0  (t3_in0),
    .in1  (t3_in1),
    .fn   (t3_fn),
    .out  (t3_out)
  );

  task t3
  (
    input [31:0] in0,
    input [31:0] in1,
    input [ 3:0] fn,

    input [31:0] out
  );
  begin
    t3_in0 = in0;
    t3_in1 = in1;
    t3_fn  = fn;
    #1;
    `VC_TEST_NOTE_INPUTS_3( in0, in1, fn );
    `VC_TEST_NET( t3_out, out );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 3, "plab2_proc_Alu" )
  begin

    //  in0           in1           fn     out
    // add
    t3( 32'h00000000, 32'h00000000, 4'd0,  32'h00000000 );
    t3( 32'h0ffaa660, 32'h00012304, 4'd0,  32'h0ffbc964 );
    // pos-neg
    t3( 32'h00132050, 32'hd6620040, 4'd0,  32'hd6752090 );
    t3( 32'hfff0a440, 32'h00004450, 4'd0,  32'hfff0e890 );
    // neg-neg
    t3( 32'hfeeeeaa3, 32'hf4650000, 4'd0,  32'hf353eaa3 );
    // sub
    t3( 32'h00000000, 32'h00000000, 4'd1,  32'h00000000 );
    t3( 32'h0ffaa660, 32'h00012304, 4'd1,  32'h0ff9835c );
    // pos-neg
    t3( 32'h00132050, 32'hd6620040, 4'd1,  32'h29b12010 );
    t3( 32'hfff0a440, 32'h00004450, 4'd1,  32'hfff05ff0 );
    // neg-neg
    t3( 32'hfeeeeaa3, 32'hf4650000, 4'd1,  32'h0a89eaa3 );
    // sll
    t3( 32'h00000000, 32'h0fff3390, 4'd2,  32'h0fff3390 );
    t3( 32'h00000005, 32'h0fff3390, 4'd2,  32'hffe67200 );
    // or
    t3( 32'ha5501120, 32'h0fdfd008, 4'd3,  32'hafdfd128 );
    // slt
    t3( 32'h00000000, 32'h00000000, 4'd4,  32'h00000000 );
    t3( 32'h0ffaa660, 32'h00012304, 4'd4,  32'h00000000 );
    t3( 32'h00eaa660, 32'h01012304, 4'd4,  32'h00000001 );
    // pos-neg
    t3( 32'h00132050, 32'hd6620040, 4'd4,  32'h00000000 );
    t3( 32'hfff0a440, 32'h00004450, 4'd4,  32'h00000001 );
    // neg-neg
    t3( 32'hfeeeeaa3, 32'hf4650000, 4'd4,  32'h00000000 );
    t3( 32'hfeeeeaa3, 32'hfff50000, 4'd4,  32'h00000001 );
    // sltu
    t3( 32'h00000000, 32'h00000000, 4'd5,  32'h00000000 );
    t3( 32'h0ffaa660, 32'h00012304, 4'd5,  32'h00000000 );
    t3( 32'h00eaa660, 32'h01012304, 4'd5,  32'h00000001 );
    // pos-neg
    t3( 32'h00132050, 32'hd6620040, 4'd5,  32'h00000001 );
    t3( 32'hfff0a440, 32'h00004450, 4'd5,  32'h00000000 );
    // neg-neg
    t3( 32'hfeeeeaa3, 32'hf4650000, 4'd5,  32'h00000000 );
    t3( 32'hfeeeeaa3, 32'hfff50000, 4'd5,  32'h00000001 );
    // and
    t3( 32'ha5501120, 32'h0fdfd008, 4'd6,  32'h05501000 );
    // xor
    t3( 32'ha5501120, 32'h0fdfd008, 4'd7,  32'haa8fc128 );
    // nor
    t3( 32'ha5501120, 32'h0fdfd008, 4'd8,  32'h50202ed7 );
    // srl
    t3( 32'h00000000, 32'h0fff3390, 4'd9,  32'h0fff3390 );
    t3( 32'h00000005, 32'h0fff3390, 4'd9,  32'h007ff99c );
    t3( 32'h00000007, 32'h8fff3390, 4'd9,  32'h011ffe67 );
    // sra
    t3( 32'h00000000, 32'h0fff3390, 4'd10, 32'h0fff3390 );
    t3( 32'h00000005, 32'h0fff3390, 4'd10, 32'h007ff99c );
    t3( 32'h00000007, 32'h8fff3390, 4'd10, 32'hff1ffe67 );
    // cp op0
    t3( 32'hf00baa00, 32'h0cafe000, 4'd11, 32'hf00baa00 );
    // cp op1
    t3( 32'hf00baa00, 32'h0cafe000, 4'd12, 32'h0cafe000 );

  end
  `VC_TEST_CASE_END

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Test plab2_proc_JTarget
  //----------------------------------------------------------------------

  reg  [31:0] t4_pc_plus4;
  reg  [25:0] t4_imm_target;
  wire [31:0] t4_j_target;

  plab2_proc_JTarget t4_j_targ
  (
    .pc_plus4   (t4_pc_plus4),
    .imm_target (t4_imm_target),
    .j_target   (t4_j_target)
  );

  task t4
  (
    input [31:0] pc_plus4,
    input [25:0] imm_target,
    input [31:0] j_target
  );
  begin
    t4_pc_plus4 = pc_plus4;
    t4_imm_target = imm_target;
    #1;
    `VC_TEST_NOTE_INPUTS_2( pc_plus4, imm_target );
    `VC_TEST_NET( t4_j_target, j_target );
    #9;
  end
  endtask

  `VC_TEST_CASE_BEGIN( 4, "plab2_proc_JTarget" )
  begin
    //  pc_plus4      imm_target   j_target
    t4( 32'h00000000, 26'h0000000, 32'h00000000 );
    t4( 32'hfee00dd0, 26'h0000000, 32'hfc000000 );
    t4( 32'h042309ec, 26'h0000d25, 32'h04003494 );
    t4( 32'h00399e00, 26'h3ffffa3, 32'h03fffe8c );
    t4( 32'h00000000, 26'h0201ee2, 32'h00807b88 );
    t4( 32'hffffffff, 26'h3ffffff, 32'hfffffffc );
  end
  `VC_TEST_CASE_END

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  `VC_TEST_SUITE_END
endmodule

