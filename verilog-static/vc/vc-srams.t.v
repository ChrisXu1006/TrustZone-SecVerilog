//========================================================================
// vc-srams Unit Tests
//========================================================================

`include "vc-srams.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "vc-srams" )

  //----------------------------------------------------------------------
  // Test vc_CombinationalSRAM_1rw
  //----------------------------------------------------------------------

  localparam t1_p_data_nbits  = 16;
  localparam t1_p_num_entries = 5;
  localparam t1_c_addr_nbits  = $clog2(t1_p_num_entries);
  localparam t1_c_data_nbytes = (t1_p_data_nbits+7)/8;

  reg                         t1_reset;
  reg                         t1_read_en;
  reg  [t1_c_addr_nbits-1:0]  t1_read_addr;
  wire [t1_p_data_nbits-1:0]  t1_read_data;
  reg                         t1_write_en;
  reg  [t1_c_data_nbytes-1:0] t1_write_byte_en;
  reg  [t1_c_addr_nbits-1:0]  t1_write_addr;
  reg  [t1_p_data_nbits-1:0]  t1_write_data;

  vc_CombinationalSRAM_1rw
  #(
    .p_data_nbits  (t1_p_data_nbits),
    .p_num_entries (t1_p_num_entries)
  )
  t1_combinational_sram_1rw
  (
    .clk           (clk),
    .reset         (t1_reset),
    .read_en       (t1_read_en),
    .read_addr     (t1_read_addr),
    .read_data     (t1_read_data),
    .write_en      (t1_write_en),
    .write_byte_en (t1_write_byte_en),
    .write_addr    (t1_write_addr),
    .write_data    (t1_write_data)
  );

  // Helper task

  task t1
  (
    input                        read_en,
    input  [t1_c_addr_nbits-1:0] read_addr,
    input  [t1_p_data_nbits-1:0] read_data,
    input                        write_en,
    input [t1_c_data_nbytes-1:0] write_byte_en,
    input  [t1_c_addr_nbits-1:0] write_addr,
    input  [t1_p_data_nbits-1:0] write_data
  );
  begin
    t1_read_en       = read_en;
    t1_read_addr     = read_addr;
    t1_write_en      = write_en;
    t1_write_byte_en = write_byte_en;
    t1_write_addr    = write_addr;
    t1_write_data    = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_2( read_en, read_addr );
    `VC_TEST_NOTE_INPUTS_4( write_en, write_byte_en, write_addr, write_data );
    `VC_TEST_NET( t1_read_data, read_data );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "vc_CombinationalSRAM_1rw" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    //  ---- read ----    ------- write ------
    //  en addr data      en wben addr  data

    t1( 0, 'hx, 'h????,   0, 'bxx, 'hx, 'hxxxx );

    // Write an entry and read it

    t1( 0, 'hx, 'h????,   1, 'b11,   0, 'haaaa );
    t1( 1,   0, 'haaaa,   0, 'bxx, 'hx, 'hxxxx );

    // Fill with entries then read

    t1( 0, 'hx, 'h????,   1, 'b11,   0, 'haaaa );
    t1( 0, 'hx, 'h????,   1, 'b11,   1, 'hbbbb );
    t1( 0, 'hx, 'h????,   1, 'b11,   2, 'hcccc );
    t1( 0, 'hx, 'h????,   1, 'b11,   3, 'hdddd );
    t1( 0, 'hx, 'h????,   1, 'b11,   4, 'heeee );

    t1( 1,   0, 'haaaa,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   1, 'hbbbb,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   2, 'hcccc,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   3, 'hdddd,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   4, 'heeee,   0, 'bxx, 'hx, 'hxxxx );

    // Overwrite entries and read again

    t1( 0, 'hx, 'h????,   1, 'b11,   0, 'h0000 );
    t1( 0, 'hx, 'h????,   1, 'b11,   1, 'h1111 );
    t1( 0, 'hx, 'h????,   1, 'b11,   2, 'h2222 );
    t1( 0, 'hx, 'h????,   1, 'b11,   3, 'h3333 );
    t1( 0, 'hx, 'h????,   1, 'b11,   4, 'h4444 );

    t1( 1,   0, 'h0000,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   1, 'h1111,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   2, 'h2222,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   3, 'h3333,   0, 'bxx, 'hx, 'hxxxx );
    t1( 1,   4, 'h4444,   0, 'bxx, 'hx, 'hxxxx );

    // Write a partial entry and read it

    t1( 0, 'hx, 'h????,   1, 'b10,   0, 'haaaa );
    t1( 1,   0, 'haa00,   0, 'bxx, 'hx, 'hxxxx );
    t1( 0, 'hx, 'h????,   1, 'b01,   0, 'hdddd );
    t1( 1,   0, 'haadd,   0, 'bxx, 'hx, 'hxxxx );

    // If byte write enables are zero then nothing is written

    t1( 0, 'hx, 'h????,   1, 'b00,   0, 'h0123 );
    t1( 1,   0, 'haadd,   0, 'bxx, 'hx, 'hxxxx );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test vc_SynchronousSRAM_1rw
  //----------------------------------------------------------------------

  localparam t2_p_data_nbits  = 16;
  localparam t2_p_num_entries = 5;
  localparam t2_c_addr_nbits  = $clog2(t2_p_num_entries);
  localparam t2_c_data_nbytes = (t2_p_data_nbits+7)/8;

  reg                         t2_reset;
  reg                         t2_read_en;
  reg  [t2_c_addr_nbits-1:0]  t2_read_addr;
  wire [t2_p_data_nbits-1:0]  t2_read_data;
  reg                         t2_write_en;
  reg  [t2_c_data_nbytes-1:0] t2_write_byte_en;
  reg  [t2_c_addr_nbits-1:0]  t2_write_addr;
  reg  [t2_p_data_nbits-1:0]  t2_write_data;

  vc_SynchronousSRAM_1rw
  #(
    .p_data_nbits  (t2_p_data_nbits),
    .p_num_entries (t2_p_num_entries)
  )
  t2_synchronous_sram_1rw
  (
    .clk           (clk),
    .reset         (t2_reset),
    .read_en       (t2_read_en),
    .read_addr     (t2_read_addr),
    .read_data     (t2_read_data),
    .write_en      (t2_write_en),
    .write_byte_en (t2_write_byte_en),
    .write_addr    (t2_write_addr),
    .write_data    (t2_write_data)
  );

  // Helper task

  task t2
  (
    input                        read_en,
    input  [t2_c_addr_nbits-1:0] read_addr,
    input  [t2_p_data_nbits-1:0] read_data,
    input                        write_en,
    input [t2_c_data_nbytes-1:0] write_byte_en,
    input  [t2_c_addr_nbits-1:0] write_addr,
    input  [t2_p_data_nbits-1:0] write_data
  );
  begin
    t2_read_en       = read_en;
    t2_read_addr     = read_addr;
    t2_write_en      = write_en;
    t2_write_byte_en = write_byte_en;
    t2_write_addr    = write_addr;
    t2_write_data    = write_data;
    #1;
    `VC_TEST_NOTE_INPUTS_2( read_en, read_addr );
    `VC_TEST_NOTE_INPUTS_4( write_en, write_byte_en, write_addr, write_data );
    `VC_TEST_NET( t2_read_data, read_data );
    #9;
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 2, "vc_SynchronousSRAM_1rw" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    //  ---- read ----   ------- write ------
    //  en addr  data     en  wben addr  data

    t2( 0, 'hx, 'h????,   0, 'bxx, 'hx, 'hxxxx );

    // Write an entry and read it

    t2( 0, 'hx, 'h????,   1, 'b11,   0, 'haaaa );
    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'haaaa,   0, 'bxx, 'hx, 'hxxxx );

    // Fill with entries then read

    t2( 0, 'hx, 'h????,   1, 'b11,   0, 'haaaa );
    t2( 0, 'hx, 'h????,   1, 'b11,   1, 'hbbbb );
    t2( 0, 'hx, 'h????,   1, 'b11,   2, 'hcccc );
    t2( 0, 'hx, 'h????,   1, 'b11,   3, 'hdddd );
    t2( 0, 'hx, 'h????,   1, 'b11,   4, 'heeee );

    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   1, 'haaaa,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   2, 'hbbbb,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   3, 'hcccc,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   4, 'hdddd,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'heeee,   0, 'bxx, 'hx, 'hxxxx );

    // Overwrite entries and read again

    t2( 0, 'hx, 'h????,   1, 'b11,   0, 'h0000 );
    t2( 0, 'hx, 'h????,   1, 'b11,   1, 'h1111 );
    t2( 0, 'hx, 'h????,   1, 'b11,   2, 'h2222 );
    t2( 0, 'hx, 'h????,   1, 'b11,   3, 'h3333 );
    t2( 0, 'hx, 'h????,   1, 'b11,   4, 'h4444 );

    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   1, 'h0000,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   2, 'h1111,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   3, 'h2222,   0, 'bxx, 'hx, 'hxxxx );
    t2( 1,   4, 'h3333,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'h4444,   0, 'bxx, 'hx, 'hxxxx );

    // Write a partial entry and read it

    t2( 0, 'hx, 'h????,   1, 'b10,   0, 'haaaa );
    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'haa00,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'h????,   1, 'b01,   0, 'hdddd );
    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'haadd,   0, 'bxx, 'hx, 'hxxxx );

    // If byte write enables are zero then nothing is written

    t2( 0, 'hx, 'h????,   1, 'b00,   0, 'h0123 );
    t2( 1,   0, 'h????,   0, 'bxx, 'hx, 'hxxxx );
    t2( 0, 'hx, 'haadd,   0, 'bxx, 'hx, 'hxxxx );

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

