//========================================================================
// Test Cases for jal instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_jal_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc " ); init_src( 32'h00000001 );
  inst( "jal   [+8]          " ); // goto 1:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr " ); // we don't expect a message here
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // 1:
  // pass
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "mtc0  r31, proc2mngr" ); init_sink( c_reset_vector + 8 );

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

task init_jal_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_jal_dest_byp( 0, "jal" );
  test_jal_dest_byp( 1, "jal" );
  test_jal_dest_byp( 2, "jal" );
  test_jal_dest_byp( 3, "jal" );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_jal_misc;
begin

  clear_mem;

  address( c_reset_vector );


  // note: we are setting the sinks here in order because the code jumps
  // backwards as well, but sinks always happen in order

  // msg 1
  init_sink( c_reset_vector +  2 * 4 );
  // msg 2
  init_sink( c_reset_vector + 14 * 4 );
  // msg 3
  init_sink( c_reset_vector + 11 * 4 );

  inst( "mfc0  r3, mngr2proc " ); init_src( 32'h00000001 );
  inst( "jal   [+11]         " ); // goto 2:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr " ); // we don't expect a message here
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

  // 1:
  // pass
  // check the correct PC
  inst( "mtc0  r31, proc2mngr" ); // expect msg 2
  inst( "jal   [+5]          " ); // goto 3:
  // fail
  inst( "mtc0  r0, proc2mngr " );

  // 2:
  // pass
  inst( "mtc0  r31, proc2mngr" ); // expect msg 1
  inst( "jal   [-4]          " ); // goto 1:
  // fail
  inst( "mtc0  r0, proc2mngr " );
  // 3:
  // pass
  inst( "mtc0  r31, proc2mngr" ); // expect msg 3

  // test branch's priority over jump
  inst( "bne   r3, r0, [+4]  " ); // goto 5:
  inst( "jal     [+2]        " );
  inst( "mtc0  r0, proc2mngr " );

  // 4:
  // fail
  inst( "mtc0  r0, proc2mngr " );
  // 5:
  // pass -- check that r31 is not corrupt
  inst( "mtc0  r31, proc2mngr" ); init_sink( c_reset_vector + 11 * 4 );


  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );
  inst( "nop                 " );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_jal_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_jal_dest_byp( 0, "jal" );
  end

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Test Case: jal basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "jal basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "jal bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "jal misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_jal_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: jal stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "jal stall/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_jal_long;
  run_test;
end
`VC_TEST_CASE_END

