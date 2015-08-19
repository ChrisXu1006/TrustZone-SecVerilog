//========================================================================
// Test Cases for mngr interfacing
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_mngr_iface_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2,mngr2proc" );  init_src(  32'h00000001 );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'h00000001 );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );


end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_mngr_iface_misc;
begin

  clear_mem;

  address( c_reset_vector );

  // test bypassing

  inst( "mfc0 r2,mngr2proc" );  init_src(  32'hdeadbeef );
  test_insert_nops( 3 );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'hdeadbeef );
  inst( "mfc0 r2,mngr2proc" );  init_src(  32'h00000eef );
  test_insert_nops( 2 );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'h00000eef );
  inst( "mfc0 r2,mngr2proc" );  init_src(  32'hdeadbee0 );
  test_insert_nops( 1 );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'hdeadbee0 );
  inst( "mfc0 r2,mngr2proc" );  init_src(  32'hde000eef );
  test_insert_nops( 0 );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'hde000eef );


  inst( "mfc0 r2,mngr2proc" );  init_src(  32'hdeadbeef );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'hdeadbeef );
  inst( "mfc0 r1,mngr2proc" );  init_src(  32'hcafecafe );
  inst( "mtc0 r1,proc2mngr" );  init_sink( 32'hcafecafe );

  // test r0 is always 0

  inst( "mtc0 r0,proc2mngr" );  init_sink( 32'h00000000 );
  inst( "mfc0 r0,mngr2proc" );  init_src(  32'habcabcff );
  inst( "mtc0 r0,proc2mngr" );  init_sink( 32'h00000000 );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );


end
endtask

//------------------------------------------------------------------------
// Core tests
//------------------------------------------------------------------------

task init_mngr_iface_core;
begin

  clear_mem;

  address( c_reset_vector );
  // test if the number of cores is as expected
  inst( "mfc0 r2,numcores " );
  inst( "mtc0 r2,proc2mngr" );  init_sink( `PLAB5_MCORE_NUM_CORES );
  // test if the core id is as expected
  inst( "mfc0 r2,coreid   " );
  inst( "mtc0 r2,proc2mngr" );  init_sink( 32'h00000000 );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );
  inst( "nop"               );


end
endtask

//------------------------------------------------------------------------
// Test Case: mngr interfacing basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "mngr interfacing basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mngr_iface_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: mngr interfacing misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "mngr interfacing misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mngr_iface_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: mngr interfacing core
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "mngr interfacing core" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mngr_iface_core;
  run_test;
end
`VC_TEST_CASE_END
