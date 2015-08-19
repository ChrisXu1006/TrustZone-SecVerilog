//========================================================================
// Test Cases for sw instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sw_basic;
begin

  clear_mem;

  inst_address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src( 32'h00009000, 0 ); init_src( 32'h0000c000, 1 );
  inst( "mfc0  r5, mngr2proc " ); init_src( 32'h00000001, 0 ); init_src( 32'hdeadbeef, 1 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "sw    r5, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "lw    r4, 0(r3)     " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "mtc0  r4, proc2mngr " ); init_sink( 32'h00000001, 0 ); init_sink ( 32'hdeadbeef, 1 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_sw_bypass;
begin

  clear_mem;

  inst_address( c_reset_vector );

  test_sw_src01_byp( 0, 0, "sw", 32'haabbccdd, 32'hccddeeff, 0, 32'h00002000, 32'h00003000 );
  test_sw_src01_byp( 0, 1, "sw", 32'heeff0011, 32'h12188712, 4, 32'h00002000, 32'h00003000 );
  test_sw_src01_byp( 0, 2, "sw", 32'hbeefdead, 32'h01234567, 0, 32'h00002004, 32'h00003004 );
  test_sw_src01_byp( 0, 3, "sw", 32'haabbeeff, 32'heeeeeeee, 4, 32'h00002004, 32'h00003004 );
  test_sw_src01_byp( 0, 4, "sw", 32'hccdd1234, 32'h1234ccdd, 0, 32'h00002008, 32'h00003008 );
  test_sw_src01_byp( 0, 3, "sw", 32'heeffccdd, 32'haabbccdd, 4, 32'h00002008, 32'h00003008 );

  test_sw_src01_byp( 1, 0, "sw", 32'hffffffff, 32'h00000000, 0, 32'h0000200c, 32'h0000300c );
  test_sw_src01_byp( 1, 1, "sw", 32'h00000000, 32'hffffffff, 0, 32'h00002010, 32'h00003010 );

  test_sw_src10_byp( 0, 0, "sw", 32'hdeadbeef, 32'h10000200, 0, 32'h00004014, 32'h0000c014 );
  test_sw_src10_byp( 0, 1, "sw", 32'hdeadbeef, 32'h22223333, 4, 32'h00004014, 32'h0000c014 );
  test_sw_src10_byp( 0, 2, "sw", 32'hbeefdead, 32'hdeadbeef, 0, 32'h00004018, 32'h0000c018 );
  test_sw_src10_byp( 0, 3, "sw", 32'hdeadbeef, 32'hccaa1122, 4, 32'h00004018, 32'h0000c018 );
  test_sw_src10_byp( 0, 4, "sw", 32'hbeefdead, 32'hbbdd4455, 0, 32'h0000401c, 32'h0000c01c );
  test_sw_src10_byp( 0, 3, "sw", 32'hdeadbeef, 32'h778899aa, 4, 32'h0000401c, 32'h0000c01c );

  test_sw_src10_byp( 1, 0, "sw", 32'hbeefdead, 32'hdeaddead, 0, 32'h00004020, 32'h0000c020 );
  test_sw_src10_byp( 1, 1, "sw", 32'hdeadbeef, 32'hcccccccc, 4, 32'h00004020, 32'h0000c020 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Random tests
//------------------------------------------------------------------------
reg [31:0]	wdata_proc0;
reg [31:0]	wdata_proc1;
reg [31:0]	base_proc0;
reg [31:0]	base_proc1;

integer idx;

task init_sw_random;
begin
	
	clear_mem;

	inst_address( c_reset_vector );

	for ( idx = 0; idx < 10; idx = idx + 1 ) begin
		wdata_proc0 = $random;
		wdata_proc1 = $random;
		base_proc0 = ($random % 32'h00004000) * 4;
		base_proc1 = ($random % 32'h00004000) * 4;

		test_sw_src01_byp(0, idx, "sw", wdata_proc0, wdata_proc1, 0, base_proc0, base_proc1);
		test_sw_src10_byp(1, idx, "sw", wdata_proc0, wdata_proc1, 0, base_proc0, base_proc1);

		test_insert_nops( 4 );

		$display( "Proc0 needs to execute No. %d sw from Address: %x, the expected data should be %x", idx, base_proc0, wdata_proc0);
		$display( "Proc1 needs to execute No. %d sw from Address: %x, the expected data should be %x", idx, base_proc1, wdata_proc1);

	end
end
endtask
/*//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sw_value;
begin

  clear_mem;

  inst_address( c_reset_vector );

  //----------------------------------------------------------------------
  // Value tests
  //----------------------------------------------------------------------

  test_sw_op( "sw", 32'h000000ff,   0, 32'h00002000 );
  test_sw_op( "sw", 32'h00007f00,   4, 32'h00002000 );
  test_sw_op( "sw", 32'h00000ff0,   8, 32'h00002000 );
  test_sw_op( "sw", 32'h0000700f,  12, 32'h00002000 );
  test_sw_op( "sw", 32'hdeadbeef, -12, 32'h0000200c );
  test_sw_op( "sw", 32'hdeadbeef,  -8, 32'h0000200c );
  test_sw_op( "sw", 32'hdeadbeef,  -4, 32'h0000200c );
  test_sw_op( "sw", 32'hdeadbeef,   0, 32'h0000200c );

  // Test with a negative base

  test_sw_op( "sw", 32'h0000700f, 16'h3000, -32'h00001000 );

  // Test with unaligned base

  test_sw_op( "sw", 32'h00007f00,        7,  32'h00001ffd );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_sw_long;
begin

  clear_mem;

  inst_address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_sw_op( "sw", 32'h000000ff,   0, 32'h00002000 );
    test_sw_op( "sw", 32'h00007f00,   4, 32'h00002000 );
  end

  test_insert_nops( 8 );

end
endtask*/

//------------------------------------------------------------------------
// Test Case: sw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "sw bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "sw random" )
begin
	init_rand_delays( 0, 0, 0 );
	init_sw_random;
	run_test;
end
`VC_TEST_CASE_END
/*//------------------------------------------------------------------------
// Test Case: sw value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "sw value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sw stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "sw stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sw_long;
  run_test;
end
`VC_TEST_CASE_END*/

