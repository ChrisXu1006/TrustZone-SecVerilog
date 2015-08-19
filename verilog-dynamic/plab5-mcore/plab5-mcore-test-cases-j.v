//========================================================================
// Test Cases for j instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_j_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );
  inst( "j     [+8]         "); // goto 1:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr"); // we don't expect a message here
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

  // 1:
  // pass
  inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );

  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

//------------------------------------------------------------------------
// Misc tests
//------------------------------------------------------------------------

task init_j_misc;
begin

  clear_mem;

  address( c_reset_vector );

  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );
  inst( "j     [+11]        "); // goto 2:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr"); // we don't expect a message here
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

  // 1:
  // pass
  inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );
  inst( "j     [+5]         "); // goto 3:
  // fail
  inst( "mtc0  r0, proc2mngr");

  // 2:
  // pass
  inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );
  inst( "j     [-4]         "); // goto 1:
  // fail
  inst( "mtc0  r0, proc2mngr");
  // 3:
  // pass
  inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );

  // test branch's priority over jump
  inst( "bne   r3, r0, [+4] "); // goto 5:
  inst( "j     [+2]         ");
  inst( "mtc0  r0, proc2mngr");

  // 4:
  // fail
  inst( "mtc0  r0, proc2mngr");
  // 5:
  // pass
  inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );

  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");
  inst( "nop                ");

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_j_long;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc"); init_src( 32'h00000001 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "j     [+12]        "); // goto botton
    // send zero if fail
    inst( "mtc0  r0, proc2mngr"); // we don't expect a message here
    inst( "mtc0  r3, proc2mngr"); init_sink( 32'h00000001 );
    inst( "j     [+10]        ");
    inst( "j     [-2]         "); // goto two above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
    inst( "j     [-1]         "); // goto one above
  end

end
endtask

//------------------------------------------------------------------------
// Test Case: j basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "j basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_j_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: j misc
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "j misc" )
begin
  init_rand_delays( 0, 0, 0 );
  init_j_misc;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: j stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "j stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_j_long;
  run_test;
end
`VC_TEST_CASE_END

