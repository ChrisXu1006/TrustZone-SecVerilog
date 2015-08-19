//========================================================================
// Test Cases for beq instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_beq_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0  r3, mngr2proc  "); init_src(  32'h00000001 );
  inst( "mfc0  r4, mngr2proc  "); init_src(  32'h00000001 );
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "beq   r3, r4, [+8]   "); // goto 2: (branch taken)
  // 1: send zero if fail
  inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");

  // 2:
  inst( "mtc0  r3, proc2mngr  "); init_sink(  32'h00000001 );
  inst( "addu  r5, r3, r4     ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "nop                  ");
  inst( "beq   r4, r5, [+2]   "); // goto 3: (branch not taken)
  inst( "beq   r4, r3, [+2]   "); // goto 4: (branch taken)
  // 3:
  // send zero if fail
  inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
  // 4:
  inst( "mtc0  r3, proc2mngr  "); init_sink(  32'h00000001 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_beq_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_br2_src01_byp( 0, 0, "beq", 0, -1 );
  test_br2_src01_byp( 0, 1, "beq", 0, -1 );
  test_br2_src01_byp( 0, 2, "beq", 0, -1 );
  test_br2_src01_byp( 1, 0, "beq", 0, -1 );
  test_br2_src01_byp( 1, 1, "beq", 0, -1 );
  test_br2_src01_byp( 2, 0, "beq", 0, -1 );

  test_br2_src10_byp( 0, 0, "beq", 0, -1 );
  test_br2_src10_byp( 0, 1, "beq", 0, -1 );
  test_br2_src10_byp( 0, 2, "beq", 0, -1 );
  test_br2_src10_byp( 1, 0, "beq", 0, -1 );
  test_br2_src10_byp( 1, 1, "beq", 0, -1 );
  test_br2_src10_byp( 2, 0, "beq", 0, -1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_beq_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Branch tests
  //----------------------------------------------------------------------

  test_br2_op_taken( "beq",  0,  0 );
  test_br2_op_taken( "beq",  1,  1 );
  test_br2_op_taken( "beq", -1, -1 );

  test_br2_op_nottaken( "beq",  0,  1 );
  test_br2_op_nottaken( "beq",  1,  0 );
  test_br2_op_nottaken( "beq", -1,  1 );
  test_br2_op_nottaken( "beq",  1, -1 );

  //----------------------------------------------------------------------
  // Test that there is no branch delay slot
  //----------------------------------------------------------------------

  inst( "mfc0 r3, mngr2proc  " ); init_src( 32'd0 );
  inst( "mfc0 r1, mngr2proc  " ); init_src( 32'd1 );
  inst( "addu r2, r0, r0     " );
  inst( "beq  r3, r0, [+5]   " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " );
  inst( "addu r2, r2, r1     " ); // branch here
  inst( "addu r2, r2, r1     " );
  inst( "mtc0 r2, proc2mngr  " ); init_sink( 32'd2 );


  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_beq_long;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Test backwards walk (back to back branch taken)
  //----------------------------------------------------------------------

  inst( "mfc0  r3, mngr2proc  "); init_src( 32'd0 );
  inst( "mfc0  r1, mngr2proc  "); init_src( 32'd1 );
  for ( idx = 0; idx < 10; idx = idx + 1 ) begin
    inst( "beq   r3, r0, [+13]  ");
    inst( "mtc0  r0, proc2mngr  "); // we don't expect a message here
    inst( "nop                  ");
    inst( "mtc0  r1, proc2mngr  "); init_sink(32'd1 );
    inst( "beq   r3, r0, [+10]  ");
    inst( "beq   r3, r0, [-2]   "); // goto two above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
    inst( "beq   r3, r0, [-1]   "); // goto one above
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: beq basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "beq basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_beq_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: beq bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "beq bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_beq_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: beq value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "beq value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_beq_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: beq stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "beq stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_beq_long;
  run_test;
end
`VC_TEST_CASE_END

