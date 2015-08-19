//------------------------------------------------------------------------
// Test Case: basic change mode operation 
//------------------------------------------------------------------------

task init_basic;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000d000, 0 );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'haabbccdd, 0 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000d000, 0 );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'haabbccdd, 0 );

	inst_address(c_reset_vector_p1);
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000e000, 1 );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'h11223344, 1 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000e000, 1 );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'h11223344, 1 );

	data_address(32'h0000d000);
	data(32'haabbccdd);
	data_address(32'h0000e000);
	data(32'h11223344);

end
endtask

//------------------------------------------------------------------------
// Test Case: multiple change mode operations
//------------------------------------------------------------------------

task init_multch;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000d000, 0 );	
	inst("nop					");
	inst("lw	r4, 0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'hdeadbeef, 0 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("lw	r4, 0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'hdeadbeef, 0 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("lw	r5, 0(r3)		");
	inst("nop					");
	inst("mtc0	r5,	proc2mngr	");		init_sink(  32'hdeadbeef, 0 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("lw	r5, 0(r3)		");
	inst("nop					");
	inst("mtc0	r5,	proc2mngr	");		init_sink(  32'hdeadbeef, 0 );

	data_address(32'h0000d000);
	data(32'hdeadbeef);

end
endtask

//------------------------------------------------------------------------
// Test Case: change mode operation with DMA commands
//------------------------------------------------------------------------

task init_dma;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0	r3, mngr2proc	");		init_src( 32'hc000, 0 );
	inst("mfc0	r4, mngr2proc	");		init_src( 32'hd000, 0 );
	inst("nop					");				
	inst("dirmem r4, 0(r3)		");		
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("dirmem r4, 0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(32'hd000, 0);

	inst_address(c_reset_vector_p1);
	inst("mfc0	r3,	mngr2proc	");		init_src( 32'hc000, 1);
	inst("mfc0	r4, mngr2proc	");		init_src( 32'hd000, 1);
	inst("nop					");				
	inst("lw	r5, 0(r4)		");
	inst("nop					");	
	inst("mtc0	r5,	proc2mngr	");		init_sink(32'h12345678,1);
	inst("nop					");
	inst("nop					");
	inst("lw	r5, 0(r4)		");
	inst("nop					");	
	inst("mtc0	r5,	proc2mngr	");		init_sink(32'h12345678,1);

	data_address(32'hc000);
	data(32'h12345678);

end
endtask

//------------------------------------------------------------------------
// Test Case: change mode operation with debug instruction
//------------------------------------------------------------------------

task init_debug;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0	r3, mngr2proc	");		init_src( 32'h9000, 0 );
	inst("mfc0	r4, mngr2proc	");		init_src( 32'ha000, 0 );
	inst("nop					");
	inst("debug	r4,	0(r3)		");
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("mfc0	r3, mngr2proc	");		init_src( 32'hc000, 0 );
	inst("mfc0	r4, mngr2proc	");		init_src( 32'hd000, 0 );
	inst("nop					");
	inst("debug	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4, proc2mngr	");		init_sink(32'hd000, 0);

	inst_address(c_reset_vector_p1);
	inst("mfc0	r3,	mngr2proc	");		init_src( 32'ha000, 1);
	inst("mfc0	r4, mngr2proc	");		init_src( 32'hd000, 1);
	inst("nop					");
	inst("nop					");
	inst("lw	r5, 0(r3)		");
	inst("nop					");
	inst("mtc0	r5,	proc2mngr	");		init_sink( 32'hbdac2468, 1);
	inst("nop					");
	inst("nop					");
	inst("nop					");
	inst("lw	r5, 0(r4)		");
	inst("nop					");
	inst("mtc0	r5,	proc2mngr	");		init_sink( 32'h1357acef, 1);

	data_address(32'h9000);
	data(32'hbdac2468);
	data_address(32'hc000);
	data(32'h1357acef);

end
endtask

//------------------------------------------------------------------------
// Test Case: Memory Partition Register
//------------------------------------------------------------------------

task init_mpar_reg;
begin

	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0	r3, mngr2proc	");		init_src( 32'h0000, 0 );
	inst("mfc0	r4,	mngr2proc	");		init_src( 32'hd000,	0 );
	inst("nop					");
	inst("sw	r4,	0(r3)		");
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("sw	r4, 0(r3)		");
	inst("nop					");
	inst("mtc0	r4, proc2mngr	");		init_sink( 32'd000, 0 );

	inst_address(c_reset_vector_p1);
	inst("mfc0	r3, mngr2proc	");		init_src( 32'hc010, 1 );
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink( 32'habcd1234, 1 );	
	inst("nop					");
	inst("nop					");
	inst("lw	r4, 0(r3)		");
	inst("nop					");
	inst("mtc0	r4, proc2mngr	");		init_sink( 32'habcd1234, 1 );

	data_address(32'hc010);
	data(32'habcd1234);

end
endtask

//------------------------------------------------------------------------
// Test Case: Prefetch instructions
//------------------------------------------------------------------------

task init_prefetch;
begin

	clear_mem;

	inst_address(c_reset_vector_p0);
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 0 );
	inst( "nop				   " );
	inst( "nop				   " );
    inst( "nop				   " );
    inst( "nop				   " );
    inst( "nop				   " );
    inst( "nop				   " );
    inst( "nop				   " );
    inst( "lw   r4, 0(r3)	   " );
    inst( "nop				   " );
	inst( "mtc0 r4, proc2mngr  " );		init_sink( 32'hcafebeef, 0 ); 

	inst_address(c_reset_vector_p1);
	inst("chmod				   " );
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 1 );
	inst( "mfc0	 r5, mngr2proc " );		init_src( 32'haabbccdd, 1 );
	inst( "nop				   " );		
	inst( "prelw r4, 0(r3)	   " );
	inst( "nop				   " );		
	inst( "sw	r5, 0(r3)	   " );
	inst( "nop				   " );
	inst( "nop				   " );
    inst( "lw   r4, 0(r3)	   " );
	inst( "nop				   " );
    inst( "nop				   " );
    inst( "mtc0  r4, proc2mngr " );		init_sink( 32'haabbccdd, 1 );	

	//initiliaze data
	data_address ( 32'hc000 );
	data( 32'hcafebeef );


end
endtask

//------------------------------------------------------------------------
// Test Case: basic change mode operation 
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "Basic Change Mode Operation" )
begin
	init_rand_delays( 0, 0, 0 );
	init_basic;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: multiple change mode operations
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "Multiple Change Mode Operations" )
begin
	init_rand_delays( 0, 0, 0 );
	init_multch;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: change mode operation with DMA commands
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "Direct Memory Access Command" )
begin
	init_rand_delays( 0, 0, 0 );
	init_dma;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: change mode operation with debug instruction
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "Debug Instruction" )
begin
	init_rand_delays( 0, 0, 0 );
	init_debug;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Memory Partition Register
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(5, "Memory Partition Register")
begin
	init_rand_delays( 0, 0, 0 );
	init_mpar_reg;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Prefetch instruction
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(6, "Prefetch instruction")
begin
	init_rand_delays( 0, 0, 0 );
	init_prefetch;
	run_test;
end
`VC_TEST_CASE_END
