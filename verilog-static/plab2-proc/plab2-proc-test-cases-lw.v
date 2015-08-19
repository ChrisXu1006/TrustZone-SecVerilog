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

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src(   32'h00002000 );
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
  inst( "mtc0  r4, proc2mngr " ); init_sink(  32'hcafecafe );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // initialize data
  address( 32'h2000 );
  data( 32'hcafecafe );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_lw_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_ld_dest_byp( 0, "lw", 0, 32'h00002000, 32'h000000ff );
  test_ld_dest_byp( 1, "lw", 4, 32'h00002000, 32'h00007f00 );
  test_ld_dest_byp( 2, "lw", 0, 32'h00002004, 32'h00007f00 );
  test_ld_dest_byp( 3, "lw", 4, 32'h00002004, 32'habcd0ff0 );
  test_ld_dest_byp( 4, "lw", 0, 32'h0000200c, 32'h0000700f );

  test_ld_src0_byp( 0, "lw", 0, 32'h00002000, 32'h000000ff );
  test_ld_src0_byp( 1, "lw", 4, 32'h00002000, 32'h00007f00 );
  test_ld_src0_byp( 2, "lw", 0, 32'h00002004, 32'h00007f00 );
  test_ld_src0_byp( 3, "lw", 4, 32'h00002004, 32'habcd0ff0 );
  test_ld_src0_byp( 4, "lw", 0, 32'h0000200c, 32'h0000700f );

  test_insert_nops( 8 );

  // initialize data
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
  data( 32'h0000700f );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_lw_value;
begin

  clear_mem;

  address( c_reset_vector );

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
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
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

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_ld_op( "lw",   0, 32'h00002000, 32'h000000ff );
    test_ld_op( "lw",   4, 32'h00002000, 32'h00007f00 );
  end

  test_insert_nops( 8 );

  // initialize data
  address( 32'h2000 );
  data( 32'h000000ff );
  data( 32'h00007f00 );
  data( 32'habcd0ff0 );

  address( 32'h200c );
  data( 32'h0000700f );

end
endtask


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
`VC_TEST_CASE_END

