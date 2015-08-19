//========================================================================
// Test Cases for sw instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sw_sec_basic;
begin

  clear_mem;

  inst_address( c_reset_vector_p0 );
  inst( "nop			     " );
  inst( "nop				 " );
  inst( "nop				 " );
  inst( "mfc0  r3, mngr2proc " ); 
  init_src( 32'h0000d000, 0 ); 
  inst( "mfc0  r5, mngr2proc " ); 
  init_src( 32'h00000001, 0 ); 
  inst( "nop                 " );
  inst( "sw    r5, 0(r3)     " );
  inst( "nop                 " );
  inst( "lw    r4, 0(r3)     " );
  inst( "nop                 " );
  inst( "mtc0  r4, proc2mngr " ); 
  init_sink( 32'h00000001, 0 ); 
  inst( "nop                 " );

  inst_address(c_reset_vector_p1);
  inst( "mfc0  r3, mngr2proc " ); 
  init_src( 32'h0000d000, 1 );
  inst( "mfc0  r5, mngr2proc " ); 
  init_src( 32'hdeadbeef, 1 );
  inst( "nop                 " );
  inst( "sw    r5, 0(r3)     " );
  inst( "nop                 " );
  inst( "lw    r4, 0(r3)     " );
  inst( "nop                 " );
  inst( "mtc0  r4, proc2mngr " ); 
  init_sink ( 32'hdeadbeef, 1 );
  inst( "nop                 " );


end
endtask

//------------------------------------------------------------------------
// Test Case: sw basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sw basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sw_sec_basic;
  run_test;
end
`VC_TEST_CASE_END

