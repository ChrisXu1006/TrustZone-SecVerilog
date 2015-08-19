//========================================================================
// vc-regfiles Unit Tests
//========================================================================

`include "vc-regfiles.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-regfiles" )

  //----------------------------------------------------------------------
  // Test vc_Regfile_1r1w
  //----------------------------------------------------------------------

  localparam t1_p_data_nbits  = 8;
  localparam t1_p_num_entries = 5;
  localparam t1_c_addr_nbits  = $clog2(t1_p_num_entries);

  reg                        t1_reset;
  reg  [t1_c_addr_nbits-1:0] t1_read_addr;
  wire [t1_p_data_nbits-1:0] t1_read_data;
  reg                        t1_write_en;
  reg  [t1_c_addr_nbits-1:0] t1_write_addr;
  reg  [t1_p_data_nbits-1:0] t1_write_data;

  vc_Regfile_1r1w
  #(
    .p_data_nbits  (t1_p_data_nbits),
    .p_num_entries (t1_p_num_entries)
  )
  t1_regfile_1r1w
  (
    .clk        (clk),
    .reset      (t1_reset),
    .read_addr  (t1_read_addr),
    .read_data  (t1_read_data),
    .write_en   (t1_write_en),
    .write_addr (t1_write_addr),
    .write_data (t1_write_data)
  );

  // Helper task

  task t1
  (
    input [t1_c_addr_nbits-1:0] read_addr,
    input [t1_p_data_nbits-1:0] read_data,
    input                       write_en,
    input [t1_c_addr_nbits-1:0] write_addr,
    input [t1_p_data_nbits-1:0] write_data
  );
  begin
    t1_read_addr  = read_addr;
    t1_write_en   = write_en;
    t1_write_addr = write_addr;
    t1_write_data = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr, write_en, write_addr, write_data );
    `VC_TEST_NET( t1_read_data, read_data );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_Regfile_1r1w" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  -- read --  --- write ---
    //  addr data   wen addr data

    t1( 'hx, 'h??,   0, 'hx, 'hxx );

    // Write an entry and read it

    t1( 'hx, 'h??,   1,  0,  'haa );
    t1(   0, 'haa,   0, 'hx, 'hxx );

    // Fill with entries then read

    t1( 'hx, 'h??,   1,  0,  'haa );
    t1( 'hx, 'h??,   1,  1,  'hbb );
    t1( 'hx, 'h??,   1,  2,  'hcc );
    t1( 'hx, 'h??,   1,  3,  'hdd );
    t1( 'hx, 'h??,   1,  4,  'hee );

    t1(   0, 'haa,   0, 'hx, 'hxx );
    t1(   1, 'hbb,   0, 'hx, 'hxx );
    t1(   2, 'hcc,   0, 'hx, 'hxx );
    t1(   3, 'hdd,   0, 'hx, 'hxx );
    t1(   4, 'hee,   0, 'hx, 'hxx );

    // Overwrite entries and read again

    t1( 'hx, 'h??,   1,  0,  'h00 );
    t1( 'hx, 'h??,   1,  1,  'h11 );
    t1( 'hx, 'h??,   1,  2,  'h22 );
    t1( 'hx, 'h??,   1,  3,  'h33 );
    t1( 'hx, 'h??,   1,  4,  'h44 );

    t1(   0, 'h00,   0, 'hx, 'hxx );
    t1(   1, 'h11,   0, 'hx, 'hxx );
    t1(   2, 'h22,   0, 'hx, 'hxx );
    t1(   3, 'h33,   0, 'hx, 'hxx );
    t1(   4, 'h44,   0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t1(   1, 'h11,   1,  0,  'h0a );
    t1(   2, 'h22,   1,  1,  'h1b );
    t1(   3, 'h33,   1,  2,  'h2c );
    t1(   4, 'h44,   1,  3,  'h3d );
    t1(   0, 'h0a,   1,  4,  'h4e );

    // Concurrent read/writes (to same addr)

    t1(   0, 'h0a,   1,  0,  'h5a );
    t1(   1, 'h1b,   1,  1,  'h6b );
    t1(   2, 'h2c,   1,  2,  'h7c );
    t1(   3, 'h3d,   1,  3,  'h8d );
    t1(   4, 'h4e,   1,  4,  'h9e );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_ResetRegfile_1r1w
  //----------------------------------------------------------------------

  localparam t2_p_data_nbits  = 8;
  localparam t2_p_num_entries = 5;
  localparam t2_c_addr_nbits  = $clog2(t2_p_num_entries);

  reg                        t2_reset;
  reg  [t2_c_addr_nbits-1:0] t2_read_addr;
  wire [t2_p_data_nbits-1:0] t2_read_data;
  reg                        t2_write_en;
  reg  [t2_c_addr_nbits-1:0] t2_write_addr;
  reg  [t2_p_data_nbits-1:0] t2_write_data;

  vc_ResetRegfile_1r1w
  #(
    .p_data_nbits  (t2_p_data_nbits),
    .p_num_entries (t2_p_num_entries),
    .p_reset_value ('h42)
  )
  t2_regfile_1r1w
  (
    .clk        (clk),
    .reset      (t2_reset),
    .read_addr  (t2_read_addr),
    .read_data  (t2_read_data),
    .write_en   (t2_write_en),
    .write_addr (t2_write_addr),
    .write_data (t2_write_data)
  );

  // Helper task

  task t2
  (
    input [t2_c_addr_nbits-1:0] read_addr,
    input [t2_p_data_nbits-1:0] read_data,
    input                       write_en,
    input [t2_c_addr_nbits-1:0] write_addr,
    input [t2_p_data_nbits-1:0] write_data
  );
  begin
    t2_read_addr  = read_addr;
    t2_write_en   = write_en;
    t2_write_addr = write_addr;
    t2_write_data = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr, write_en, write_addr, write_data );
    `VC_TEST_NET( t2_read_data, read_data );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "vc_ResetRegfile_1r1w" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    //  -- read --  --- write ---
    //  addr data   wen addr data

    t2( 'hx, 'h??,   0, 'hx, 'hxx );

    // Verify register file was reset correctly

    t2(   0, 'h42,   0, 'hx, 'hxx );
    t2(   1, 'h42,   0, 'hx, 'hxx );
    t2(   2, 'h42,   0, 'hx, 'hxx );
    t2(   3, 'h42,   0, 'hx, 'hxx );
    t2(   4, 'h42,   0, 'hx, 'hxx );

    // Write an entry and read it

    t2( 'hx, 'h??,   1,  0,  'haa );
    t2(   0, 'haa,   0, 'hx, 'hxx );

    // Fill with entries then read

    t2( 'hx, 'h??,   1,  0,  'haa );
    t2( 'hx, 'h??,   1,  1,  'hbb );
    t2( 'hx, 'h??,   1,  2,  'hcc );
    t2( 'hx, 'h??,   1,  3,  'hdd );
    t2( 'hx, 'h??,   1,  4,  'hee );

    t2(   0, 'haa,   0, 'hx, 'hxx );
    t2(   1, 'hbb,   0, 'hx, 'hxx );
    t2(   2, 'hcc,   0, 'hx, 'hxx );
    t2(   3, 'hdd,   0, 'hx, 'hxx );
    t2(   4, 'hee,   0, 'hx, 'hxx );

    // Overwrite entries and read again

    t2( 'hx, 'h??,   1,  0,  'h00 );
    t2( 'hx, 'h??,   1,  1,  'h11 );
    t2( 'hx, 'h??,   1,  2,  'h22 );
    t2( 'hx, 'h??,   1,  3,  'h33 );
    t2( 'hx, 'h??,   1,  4,  'h44 );

    t2(   0, 'h00,   0, 'hx, 'hxx );
    t2(   1, 'h11,   0, 'hx, 'hxx );
    t2(   2, 'h22,   0, 'hx, 'hxx );
    t2(   3, 'h33,   0, 'hx, 'hxx );
    t2(   4, 'h44,   0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t2(   1, 'h11,   1,  0,  'h0a );
    t2(   2, 'h22,   1,  1,  'h1b );
    t2(   3, 'h33,   1,  2,  'h2c );
    t2(   4, 'h44,   1,  3,  'h3d );
    t2(   0, 'h0a,   1,  4,  'h4e );

    // Concurrent read/writes (to same addr)

    t2(   0, 'h0a,   1,  0,  'h5a );
    t2(   1, 'h1b,   1,  1,  'h6b );
    t2(   2, 'h2c,   1,  2,  'h7c );
    t2(   3, 'h3d,   1,  3,  'h8d );
    t2(   4, 'h4e,   1,  4,  'h9e );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Regfile_2r1w
  //----------------------------------------------------------------------

  localparam t3_p_data_nbits  = 8;
  localparam t3_p_num_entries = 5;
  localparam t3_c_addr_nbits  = $clog2(t3_p_num_entries);

  reg                        t3_reset;
  reg  [t3_c_addr_nbits-1:0] t3_read_addr0;
  wire [t3_p_data_nbits-1:0] t3_read_data0;
  reg  [t3_c_addr_nbits-1:0] t3_read_addr1;
  wire [t3_p_data_nbits-1:0] t3_read_data1;
  reg                        t3_write_en;
  reg  [t3_c_addr_nbits-1:0] t3_write_addr;
  reg  [t3_p_data_nbits-1:0] t3_write_data;

  vc_Regfile_2r1w
  #(
    .p_data_nbits  (t3_p_data_nbits),
    .p_num_entries (t3_p_num_entries)
  )
  t3_regfile_2r1w
  (
    .clk         (clk),
    .reset       (t3_reset),
    .read_addr0  (t3_read_addr0),
    .read_data0  (t3_read_data0),
    .read_addr1  (t3_read_addr1),
    .read_data1  (t3_read_data1),
    .write_en    (t3_write_en),
    .write_addr  (t3_write_addr),
    .write_data  (t3_write_data)
  );

  // Helper task

  task t3
  (
    input [t3_c_addr_nbits-1:0] read_addr0,
    input [t3_p_data_nbits-1:0] read_data0,
    input [t3_c_addr_nbits-1:0] read_addr1,
    input [t3_p_data_nbits-1:0] read_data1,
    input                       write_en,
    input [t3_c_addr_nbits-1:0] write_addr,
    input [t3_p_data_nbits-1:0] write_data
  );
  begin
    t3_read_addr0 = read_addr0;
    t3_read_addr1 = read_addr1;
    t3_write_en   = write_en;
    t3_write_addr = write_addr;
    t3_write_data = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr0, read_data0, read_addr1, read_data1 );
    `VC_TEST_NOTE_INPUTS_3( write_en, write_addr, write_data );
    `VC_TEST_NET( t3_read_data0, read_data0 );
    `VC_TEST_NET( t3_read_data1, read_data1 );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 3, "vc_Regfile_2r1w" )
  begin

    #1;  t3_reset = 1'b1;
    #20; t3_reset = 1'b0;


    //  -- read0 --  -- read1 --  --- write ---
    //  addr data    addr data    wen addr data

    t3( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx );

    // Write an entry and read it

    t3( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t3(   0, 'haa,   'hx, 'h??,   0, 'hx, 'hxx );
    t3( 'hx, 'h??,     0, 'haa,   0, 'hx, 'hxx );
    t3(   0, 'haa,     0, 'haa,   0, 'hx, 'hxx );

    // Fill with entries then read

    t3( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   1, 'hbb );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   2, 'hcc );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   3, 'hdd );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   4, 'hee );

    t3(   0, 'haa,   'hx, 'h??,   0, 'hx, 'hxx );
    t3( 'hx, 'h??,     1, 'hbb,   0, 'hx, 'hxx );
    t3(   2, 'hcc,   'hx, 'h??,   0, 'hx, 'hxx );
    t3( 'hx, 'h??,     3, 'hdd,   0, 'hx, 'hxx );
    t3(   4, 'hee,   'hx, 'h??,   0, 'hx, 'hxx );

    t3(   0, 'haa,     0, 'haa,   0, 'hx, 'hxx );
    t3(   1, 'hbb,     1, 'hbb,   0, 'hx, 'hxx );
    t3(   2, 'hcc,     2, 'hcc,   0, 'hx, 'hxx );
    t3(   3, 'hdd,     3, 'hdd,   0, 'hx, 'hxx );
    t3(   4, 'hee,     4, 'hee,   0, 'hx, 'hxx );

    // Overwrite entries and read again

    t3( 'hx, 'h??,   'hx, 'h??,   1,   0, 'h00 );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   1, 'h11 );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   2, 'h22 );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   3, 'h33 );
    t3( 'hx, 'h??,   'hx, 'h??,   1,   4, 'h44 );

    t3(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx );
    t3(   1, 'h11,     1, 'h11,   0, 'hx, 'hxx );
    t3(   2, 'h22,     2, 'h22,   0, 'hx, 'hxx );
    t3(   3, 'h33,     3, 'h33,   0, 'hx, 'hxx );
    t3(   4, 'h44,     4, 'h44,   0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t3(   1, 'h11,     2, 'h22,   1,   0, 'h0a );
    t3(   2, 'h22,     3, 'h33,   1,   1, 'h1b );
    t3(   3, 'h33,     4, 'h44,   1,   2, 'h2c );
    t3(   4, 'h44,     0, 'h0a,   1,   3, 'h3d );
    t3(   0, 'h0a,     1, 'h1b,   1,   4, 'h4e );

    // Concurrent read/writes (to same addr)

    t3(   0, 'h0a,     0, 'h0a,   1,   0, 'h5a );
    t3(   1, 'h1b,     1, 'h1b,   1,   1, 'h6b );
    t3(   2, 'h2c,     2, 'h2c,   1,   2, 'h7c );
    t3(   3, 'h3d,     3, 'h3d,   1,   3, 'h8d );
    t3(   4, 'h4e,     4, 'h4e,   1,   4, 'h9e );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_Regfile_2r2w
  //----------------------------------------------------------------------

  localparam t4_p_data_nbits  = 8;
  localparam t4_p_num_entries = 5;
  localparam t4_c_addr_nbits  = $clog2(t4_p_num_entries);

  reg                        t4_reset;
  reg  [t4_c_addr_nbits-1:0] t4_read_addr0;
  wire [t4_p_data_nbits-1:0] t4_read_data0;
  reg  [t4_c_addr_nbits-1:0] t4_read_addr1;
  wire [t4_p_data_nbits-1:0] t4_read_data1;
  reg                        t4_write_en0;
  reg  [t4_c_addr_nbits-1:0] t4_write_addr0;
  reg  [t4_p_data_nbits-1:0] t4_write_data0;
  reg                        t4_write_en1;
  reg  [t4_c_addr_nbits-1:0] t4_write_addr1;
  reg  [t4_p_data_nbits-1:0] t4_write_data1;

  vc_Regfile_2r2w
  #(
    .p_data_nbits  (t4_p_data_nbits),
    .p_num_entries (t4_p_num_entries)
  )
  t4_regfile_2r2w
  (
    .clk         (clk),
    .reset       (t4_reset),
    .read_addr0  (t4_read_addr0),
    .read_data0  (t4_read_data0),
    .read_addr1  (t4_read_addr1),
    .read_data1  (t4_read_data1),
    .write_en0   (t4_write_en0),
    .write_addr0 (t4_write_addr0),
    .write_data0 (t4_write_data0),
    .write_en1   (t4_write_en1),
    .write_addr1 (t4_write_addr1),
    .write_data1 (t4_write_data1)
  );

  // Helper task

  task t4
  (
    input [t4_c_addr_nbits-1:0] read_addr0,
    input [t4_p_data_nbits-1:0] read_data0,
    input [t4_c_addr_nbits-1:0] read_addr1,
    input [t4_p_data_nbits-1:0] read_data1,
    input                       write_en0,
    input [t4_c_addr_nbits-1:0] write_addr0,
    input [t4_p_data_nbits-1:0] write_data0,
    input                       write_en1,
    input [t4_c_addr_nbits-1:0] write_addr1,
    input [t4_p_data_nbits-1:0] write_data1
  );
  begin
    t4_read_addr0  = read_addr0;
    t4_read_addr1  = read_addr1;
    t4_write_en0   = write_en0;
    t4_write_addr0 = write_addr0;
    t4_write_data0 = write_data0;
    t4_write_en1   = write_en1;
    t4_write_addr1 = write_addr1;
    t4_write_data1 = write_data1;
    #1;
    `VC_TEST_NOTE_INPUTS_4( read_addr0, read_data0, read_addr1, read_data1 );
    `VC_TEST_NOTE_INPUTS_3( write_en0, write_addr0, write_data0 );
    `VC_TEST_NOTE_INPUTS_3( write_en1, write_addr1, write_data1 );
    `VC_TEST_NET( t4_read_data0, read_data0 );
    `VC_TEST_NET( t4_read_data1, read_data1 );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 4, "vc_Regfile_2r2w" )
  begin

    #1;  t4_reset = 1'b1;
    #20; t4_reset = 1'b0;


    //  -- read0 --  -- read1 --  --- write0 --  --- write1 --
    //  addr data    addr data    wen addr data  wen addr data

    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    // Write an entry using write port 0 and read it

    t4( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa,  0, 'hx, 'hxx );
    t4(   0, 'haa,   'hx, 'h??,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,     0, 'haa,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   0, 'haa,     0, 'haa,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    // Write an entry using write port 1 and read it

    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   0, 'haa );
    t4(   0, 'haa,     0, 'haa,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    // Fill with entries then read

    t4( 'hx, 'h??,   'hx, 'h??,   1,   0, 'haa,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   1, 'hbb );
    t4( 'hx, 'h??,   'hx, 'h??,   1,   2, 'hcc,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   3, 'hdd );
    t4( 'hx, 'h??,   'hx, 'h??,   1,   4, 'hee,  0, 'hx, 'hxx );

    t4(   0, 'haa,   'hx, 'h??,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,     1, 'hbb,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   2, 'hcc,   'hx, 'h??,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,     3, 'hdd,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   4, 'hee,   'hx, 'h??,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    t4(   0, 'haa,     0, 'haa,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   1, 'hbb,     1, 'hbb,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   2, 'hcc,     2, 'hcc,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   3, 'hdd,     3, 'hdd,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   4, 'hee,     4, 'hee,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    // Overwrite entries and read again

    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   0, 'h00 );
    t4( 'hx, 'h??,   'hx, 'h??,   1,   1, 'h11,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   2, 'h22 );
    t4( 'hx, 'h??,   'hx, 'h??,   1,   3, 'h33,  0, 'hx, 'hxx );
    t4( 'hx, 'h??,   'hx, 'h??,   0, 'hx, 'hxx,  1,   4, 'h44 );

    t4(   0, 'h00,     0, 'h00,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   1, 'h11,     1, 'h11,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   2, 'h22,     2, 'h22,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   3, 'h33,     3, 'h33,   0, 'hx, 'hxx,  0, 'hx, 'hxx );
    t4(   4, 'h44,     4, 'h44,   0, 'hx, 'hxx,  0, 'hx, 'hxx );

    // Concurrent read/writes (to different addr)

    t4(   2, 'h22,     3, 'h33,   1,   0, 'h0a,  1,   1, 'h5a );
    t4(   3, 'h33,     4, 'h44,   1,   1, 'h1b,  1,   2, 'h6b );
    t4(   4, 'h44,     0, 'h0a,   1,   2, 'h2c,  1,   3, 'h7c );
    t4(   0, 'h0a,     1, 'h1b,   1,   3, 'h3d,  1,   4, 'h8d );
    t4(   1, 'h1b,     2, 'h2c,   1,   4, 'h4e,  1,   0, 'h9e );

    // Concurrent read/writes with write port 0 (to same addr)

    t4(   0, 'h9e,     0, 'h9e,   1,   0, 'h50,  0, 'hx, 'hxx );
    t4(   1, 'h1b,     1, 'h1b,   1,   1, 'h60,  0, 'hx, 'hxx );
    t4(   2, 'h2c,     2, 'h2c,   1,   2, 'h70,  0, 'hx, 'hxx );
    t4(   3, 'h3d,     3, 'h3d,   1,   3, 'h80,  0, 'hx, 'hxx );
    t4(   4, 'h4e,     4, 'h4e,   1,   4, 'h90,  0, 'hx, 'hxx );

    // Concurrent read/writes with write port 1 (to same addr)

    t4(   0, 'h50,     0, 'h50,   0, 'hx, 'hxx,  1,   0, 'haa );
    t4(   1, 'h60,     1, 'h60,   0, 'hx, 'hxx,  1,   1, 'hbb );
    t4(   2, 'h70,     2, 'h70,   0, 'hx, 'hxx,  1,   2, 'hcc );
    t4(   3, 'h80,     3, 'h80,   0, 'hx, 'hxx,  1,   3, 'hdd );
    t4(   4, 'h90,     4, 'h90,   0, 'hx, 'hxx,  1,   4, 'hee );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

