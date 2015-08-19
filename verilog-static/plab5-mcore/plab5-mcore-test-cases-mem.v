//========================================================================
// Test Cases for Various Memory Instructions
//========================================================================
// this file is to be `include by plab2-proc-test-harness.v

//========================================================================
// basic direct memory access tests
//========================================================================

task init_dma_inst_basic;
begin
	
	clear_mem;
	
	inst_address( c_reset_vector_p0 );
	inst( "mfc0	r3, mngr2proc " );	init_src( 32'h9000, 0 );
	inst( "mfc0 r4, mngr2proc " );	init_src( 32'ha000, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "dirmem r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw   r5,	0(r4)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink(32'hdeadbeef, 0 );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );	init_src( 32'hd000, 1 );
	inst( "mfc0 r4, mngr2proc " );	init_src( 32'he000, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "dirmem r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r5, 0(r4)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink( 32'h00001111, 1 );
	
	// initialize data
	data_address( 32'h9000 );
	data( 32'hdeadbeef );
	data_address( 32'ha000 );
	data( 32'h11223344 );

	data_address( 32'hd000 );
	data( 32'h00001111 );
	data_address( 32'he000 );
	data( 32'haabbccdd );

end
endtask

//========================================================================
// Debug instruction
//========================================================================

task init_debug_inst_basic;
begin
	
	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );	init_src( 32'hd000, 0 );
	inst( "mfc0 r4, mngr2proc " );	init_src( 32'he000, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "debug r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );	init_sink( 32'he000, 0 );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3,	mngr2proc " );	init_src( 32'he000, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw   r5, 0(r3)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink( 32'hdeadbeef, 1 );

	// initialize data
	data_address( 32'hd000 );
	data( 32'hdeadbeef );
	data_address( 32'he000 );
	data( 32'haaaabbbb );
end
endtask

//========================================================================
// SW Declassification/Endorsement Load 
//========================================================================

task init_sw_delw_basic;
begin
	
	clear_mem;

	inst_address ( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );  init_src( 32'h9000, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "delw 0, r4, 0(r3)  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );	init_sink( 32'h11223344, 0 );

	inst_address ( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );  init_src( 32'hd000, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "delw 0, r4, 0(r3)  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );  init_sink( 32'hdeadbeef, 1 );

	//initialize data
	data_address( 32'h9000 );
	data( 32'h11223344 );
	data_address( 32'hd000 );
	data( 32'hdeadbeef );
end
endtask

//========================================================================
// SW Declassification/Endorsement Store 
//========================================================================

task init_sw_desw_basic;
begin
	
	clear_mem;

	inst_address ( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );  init_src( 32'h9000, 0 );
	inst( "mfc0 r4, mngr2proc " );  init_src( 32'haabbccdd, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "desw 0, r4, 0(r3)  " );
	inst( "nop				  " );
	inst( "lw   r5, 0(r3)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink( 32'haabbccdd, 0 );

	inst_address ( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );  init_src( 32'ha000, 1 );
	inst( "mfc0 r4, mngr2proc " );  init_src( 32'h00001111, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "desw 0, r4, 0(r3)  " );
	inst( "nop				  " );
	inst( "lw   r5, 0(r3)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );  init_sink( 32'hdeadbeef, 1 );

	//initialize data
	data_address( 32'h9000 );
	data( 32'h11223344 );
	data_address( 32'ha000 );
	data( 32'h67887656 );
	data_address( 32'he000 );
	data( 32'hdeadbeef );
end
endtask

//========================================================================
// SW Declassification/Endorsement Direct Memory Access 
//========================================================================

task init_sw_dedma_basic;
begin
	
	clear_mem;
	
	inst_address( c_reset_vector_p0 );
	inst( "mfc0	r3, mngr2proc " );	init_src( 32'h9000, 0 );
	inst( "mfc0 r4, mngr2proc " );	init_src( 32'ha000, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "dedma 0, 0 ,r4, 0(r3) " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw   r5,	0(r4)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink(32'hdeadbeef, 0 );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );	init_src( 32'hd000, 1 );
	inst( "mfc0 r4, mngr2proc " );	init_src( 32'hb000, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "dedma 1, 0, r4, 0(r3) " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r5, 0(r4)	  " );
	inst( "nop				  " );
	inst( "mtc0 r5, proc2mngr " );	init_sink( 32'h00001111, 1 );
	
	// initialize data
	data_address( 32'h9000 );
	data( 32'hdeadbeef );
	data_address( 32'ha000 );
	data( 32'h11223344 );

	data_address( 32'hd000 );
	data( 32'h00001111 );
	data_address( 32'he000 );
	data( 32'haabbccdd );

end
endtask

//========================================================================
// Test Case: Direct Memory Access Tests
//========================================================================

`VC_TEST_CASE_BEGIN(1, "Direct Memory Access")
begin
	init_rand_delays( 0, 0, 0 );
	init_dma_inst_basic;
	run_test;
end
`VC_TEST_CASE_END

//========================================================================
// Test Case: Debug Instruction 
//========================================================================

`VC_TEST_CASE_BEGIN(2, "Debug Instruction")
begin
	init_rand_delays( 0, 0, 0 );
	init_debug_inst_basic;
	run_test;
end
`VC_TEST_CASE_END

//========================================================================
// Test Case: SW Declassification/Endorsement Load 
//========================================================================

`VC_TEST_CASE_BEGIN(3, "SW Declassification/Endorsement Load")
begin
	init_rand_delays( 0, 0, 0 );
	init_sw_delw_basic;
	run_test;
end
`VC_TEST_CASE_END

//========================================================================
// Test Case: SW Declassification/Endorsement Store 
//========================================================================

`VC_TEST_CASE_BEGIN(4, "SW Declassification/Endorsement Store")
begin
	init_rand_delays( 0, 0, 0 );
	init_sw_desw_basic;
	run_test;
end
`VC_TEST_CASE_END

//========================================================================
// Test Case: SW Declassification/Endorsement Direct Memory Access
//========================================================================

`VC_TEST_CASE_BEGIN(5, "SW Declassification/Endorsement DMA")
begin
	init_rand_delays( 0, 0, 0 );
	init_sw_dedma_basic;
	run_test;
end
`VC_TEST_CASE_END
