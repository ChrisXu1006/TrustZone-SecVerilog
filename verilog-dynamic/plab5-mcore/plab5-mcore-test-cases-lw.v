//========================================================================
// Test Cases for lw instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_lw_basic;
begin

  clear_mem;

  inst_address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src(   32'h00009000, 0 ); init_src( 32'h0000c000, 1 );
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
  inst( "mtc0  r4, proc2mngr " ); init_sink(  32'hcafecafe, 0 ); init_sink( 32'hdeadbeef, 1 );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "chmod				 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );


  // initialize data
  data_address( 32'h9000 );
  data( 32'hcafecafe );
  data_address( 32'hc000 );
  data( 32'hdeadbeef );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_lw_bypass;
begin

  clear_mem;

  inst_address( c_reset_vector );

  test_ld_dest_byp( 0, "lw", 0, 32'h0000a000, 32'h0000d000, 32'h000000ff, 32'h0000700f );
  test_ld_dest_byp( 1, "lw", 4, 32'h0000a000, 32'h0000d000, 32'h00007f00, 32'habbc0000 );
  test_ld_dest_byp( 2, "lw", 0, 32'h0000a004, 32'h0000d004, 32'h00007f00, 32'habbc0000 );
  test_ld_dest_byp( 3, "lw", 4, 32'h0000a004, 32'h0000d004, 32'habcd0ff0, 32'hddddcccc );

  test_ld_src_byp( 0, "lw", 0, 32'h0000a000, 32'h0000d000, 32'h000000ff, 32'h0000700f );
  test_ld_src_byp( 1, "lw", 4, 32'h0000a000, 32'h0000d000, 32'h00007f00, 32'habbc0000 );
  test_ld_src_byp( 2, "lw", 0, 32'h0000a004, 32'h0000d004, 32'h00007f00, 32'habbc0000 );
  test_ld_src_byp( 3, "lw", 4, 32'h0000a004, 32'h0000d004, 32'habcd0ff0, 32'hddddcccc );

  test_insert_nops( 8 );

  // initialize data
  data_address( 32'ha000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  data_address( 32'hd000 );
  data( 32'h0000700f );
  data( 32'habbc0000 );
  data( 32'hddddcccc );

end
endtask


//------------------------------------------------------------------------
// Random tests
//------------------------------------------------------------------------

reg [31:0]		base_proc0;
reg [31:0]		base_proc1;
reg [31:0]		result_proc0;
reg [31:0]		result_proc1;

integer			idx ;

task init_lw_random;
begin
	
	clear_mem;

	inst_address( c_reset_vector );

	for ( idx = 0; idx < 5; idx = idx + 1 ) begin
		base_proc0 = ($random % (32'h00001000)) * 4 + 32'h8000;
		base_proc1 = ($random % (32'h00002000)) * 4 + 32'h8000;
		result_proc0 = $random;
		result_proc1 = $random;
		test_ld_dest_byp( idx, "lw", 0, base_proc0, base_proc1, result_proc0, result_proc1);
		test_ld_src_byp(idx, "lw", 0, base_proc0, base_proc1, result_proc0, result_proc1);

		test_insert_nops( 2 );

		data_address ( base_proc0 );
		data( result_proc0 );
		data_address ( base_proc1 );
		data( result_proc1 );
		$display( "Domain1 needs to execute No. %d lw from Address: %x, the expected data should be %x", idx, base_proc0, result_proc0);
		$display( "Domain2 needs to execute No. %d lw from Address: %x, the expected data should be %x", idx, base_proc1, result_proc1);
	end

	for ( idx = 5; idx < 10; idx = idx + 1 ) begin
		base_proc0 = ($random % (32'h00001000)) * 4 + 32'h8000;
		base_proc1 = ($random % (32'h00002000)) * 4 + 32'h8000;
		result_proc0 = $random;
		result_proc1 = $random;
		test_ld_dest_byp( idx, "lw", 0, base_proc0, base_proc1, result_proc0, result_proc1);
		test_ld_src_byp(idx, "lw", 0, base_proc0, base_proc1, result_proc0, result_proc1);

		test_insert_nops( 2 );

		data_address ( base_proc0 );
		data( result_proc0 );
		data_address ( base_proc1 );
		data( result_proc1 );
		$display( "Domain1 needs to execute No. %d lw from Address: %x, the expected data should be %x", idx, base_proc0, result_proc0);
		$display( "Domain2 needs to execute No. %d lw from Address: %x, the expected data should be %x", idx, base_proc1, result_proc1);


	end
end
endtask

/*//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_lw_value;
begin

  clear_mem;

  inst_address( c_reset_vector );

  //----------------------------------------------------------------------
  // Value tests
  //----------------------------------------------------------------------

  test_ld_op( "lw",   0, 32'h00002000, 32'h000000ff );
  test_ld_op( "lw",   4, 32'h00002000, 32'h00007f00 );
  test_ld_op( "lw",   8, 32'h00002000, 32'habcd0ff0 );
  test_ld_op( "lw",  12, 32'h00002000, 32'h0000700f );
  test_ld_op( "lw", -12, 32'h0000200c, 32'h000000ff );
  test_ld_op( "lw",  -8, 32'h0000200c, 32'h00007f00 );
  test_ld_op( "lw",  -4, 32'h0000200c, 32'habcd0ff0 );
  test_ld_op( "lw",   0, 32'h0000200c, 32'h0000700f );

  // Test with a negative base

  test_ld_op( "lw", 16'h3000, -32'h00001000, 32'h000000ff );

  // Test with unaligned base

  test_ld_op( "lw",   7, 32'h00001ffd, 32'h00007f00 );

  //----------------------------------------------------------------------
  // Test WAW Hazard
  //----------------------------------------------------------------------

  inst( "mfc0 r1, mngr2proc" ); init_src(  32'h00002000 );
  inst( "mfc0 r2, mngr2proc" ); init_src(  32'h00000002 );
  inst( "lw   r3, 0(r1)    " );
  inst( "addu r3, r1, r2   " );
  inst( "mtc0 r3, proc2mngr" ); init_sink( 32'h00002002 );

  test_insert_nops( 8 );

  // initialize data
  data_address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  data_address( 32'h200c );
  data( 32'h0000700f );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_lw_long;
begin

  clear_mem;

  inst_address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_ld_op( "lw",   0, 32'h0000d000, 32'h000000ff );
    test_ld_op( "lw",   4, 32'h0000d000, 32'h00007f00 );
  end

  test_insert_nops( 8 );

  // initialize data
  data_address( 32'hd000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  data_address( 32'hd00c );
  data( 32'h0000700f );

end
endtask*/


//------------------------------------------------------------------------
// Test Case: lw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "lw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "lw bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "lw random" )
begin
	init_rand_delays( 0, 0, 0 );
	init_lw_random;
	run_test;
end
`VC_TEST_CASE_END
/*//------------------------------------------------------------------------
// Test Case: lw value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "lw value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lw stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "lw stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_lw_long;
  run_test;
end
`VC_TEST_CASE_END*/


