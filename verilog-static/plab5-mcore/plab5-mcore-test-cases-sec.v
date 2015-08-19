//========================================================================
// Test Cases for lw instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// basic secure lw tests
//------------------------------------------------------------------------

task init_sec_lw_basic;
begin

	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "mfc0  r3, mngr2proc " );     init_src(   32'h00009000, 0  ); 
	inst( "nop                 " );
	inst( "nop                 " );
	inst( "lw    r4, 0(r3)     " );
	inst( "nop                 " );
	inst( "nop                 " );
	inst( "mtc0  r4, proc2mngr " );		init_sink( 32'hcafecafe, 0	 );
	inst( "nop                 " );
	inst( "nop                 " );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0  r3, mngr2proc " );		init_src(   32'h0000c000, 1  ); 
	inst( "nop                 " );
	inst( "nop                 " );
	inst( "lw    r4, 0(r3)     " );
	inst( "nop                 " );
	inst( "nop                 " );
	inst( "mtc0  r4, proc2mngr " );		init_sink( 32'hdeadbeef, 1	 );
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
// basic sw tests
//------------------------------------------------------------------------
task init_sec_sw_basic;
begin

	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h00009000,	  0 );
	inst( "mfc0 r5, mngr2proc " );		init_src( 32'haaaabbbb,	  0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "sw	r5, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw   r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );		init_sink( 32'haaaabbbb,  0 );
	inst( "nop				  " );
	inst( "nop				  " );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0000c000,	  1 );
	inst( "mfc0 r5, mngr2proc " );		init_src( 32'hccccdddd,	  1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "sw	r5, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw   r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );		init_sink( 32'hccccdddd,  1 );
	inst( "nop				  " );
	inst( "nop				  " );

end
endtask

//------------------------------------------------------------------------
// attack1: low security processor reads/writes high memory
//------------------------------------------------------------------------
task init_lowproc_rw_attack;
begin

	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0000c000,  0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "mtc0	r4, proc2mngr " );		init_sink( 32'h11223344, 0 );
	inst( "nop				  " );
	inst( "nop				  " );

	// initialize data
	data_address( 32'hc000 );
	data( 32'h11223344 );

end
endtask

//------------------------------------------------------------------------
// attack2: low security processor flip its NS-bit to access high memory 
//------------------------------------------------------------------------
task init_NSbit_flip_attack;
begin 
	
	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0000d000, 0 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r4, 0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );		init_sink( 32'h77885566, 0 );
	inst( "nop				  " );
	inst( "nop				  " );

	// initialize data
	data_address( 32'hd000 );
	data( 32'h77885566 );

end
endtask

//------------------------------------------------------------------------
// attack3: network flip the NS-bit of response, and change the routing 
// field to low processor 
//------------------------------------------------------------------------
task init_flip_route_attack;
begin
	
	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("mtc0	r4, proc2mngr " );		init_sink(32'heeedddcc, 0 );
	inst("nop				  " );
	inst("nop				  " );
	
	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0000e000, 1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r4,	0(r3)	  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "mtc0 r4, proc2mngr " );		init_sink(32'heeedddcc, 1 );
	inst( "nop				  " );
	inst( "nop				  " );

	// initialize data
	data_address( 32'he000 );
	data( 32'heeedddcc );

end
endtask

//------------------------------------------------------------------------
// attack4: attackers change the destination field of response message, 
// and a broken processor access control module allow low processor to 
// recieve high processor 
//------------------------------------------------------------------------

task init_lw_route_attack;
begin

	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst("nop				  " );
	inst( "mtc0 r4, proc2mngr " );		init_sink( 32'hdeadbeef,  0 );
	inst( "nop				  " );
	inst( "nop				  " );

	inst_address( c_reset_vector_p1 );
	inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0000c000,	  1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "lw	r4, 0(r3)	  " );		init_sink( 32'hdeadbeef,  1 );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );
	inst( "nop				  " );

	// initialize data
	data_address( 32'h9000 );
	data( 32'hcafecafe );
	data_address( 32'hc000 );
	data( 32'hdeadbeef );

end
endtask

//------------------------------------------------------------------------
// attack5: attackers is able to change the security tag associated to
// each cache line, by this way, low processor is able to read sensitive
// in the data 
//------------------------------------------------------------------------

task init_cache_sectag_flip;
begin

	clear_mem;

	inst_address( c_reset_vector_p0 );
	inst( "nop                 " );
	inst( "nop                 " );
	inst( "mfc0  r3, mngr2proc " );     init_src(  32'h00009000, 0  ); 
	inst( "nop                 " );
	inst( "lw    r4, 0(r3)     " );
	inst( "nop                 " );
	inst( "mtc0  r4, proc2mngr " );		init_sink( 32'hcafecafe, 0	 );
	inst( "nop                 " );


	inst_address( c_reset_vector_p1 );
	inst( "mfc0  r3, mngr2proc " );		init_src(   32'h0000c000, 1  ); 
	inst( "nop                 " );
	inst( "lw    r4, 0(r3)     " );
	inst( "nop                 " );
	inst( "mtc0  r4, proc2mngr " );		init_sink( 32'hdeadbeef, 1 );
	inst( "nop                 " );


	// initialize data
	data_address( 32'h9000 );
	data( 32'hcafecafe );
	data_address( 32'hc000 );
	data( 32'hdeadbeef );

end
endtask

//------------------------------------------------------------------------
// attack6: when there is a match between tag match and mismatck between
// security tags, attacks change control unit to redirect next state to
// real write stage, and change the secure tag of written information, so
// attackers can realize cache posisoning 
//------------------------------------------------------------------------

task init_cache_wr_sectag;
begin
	
	clear_mem;

	inst_address ( c_reset_vector_p0 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 0	);
	inst( "mfc0  r5, mngr2proc " );		init_src( 32'haabbccdd, 0	);
	inst( "nop				   " );
	inst( "sw	 r5, 0(r3)	   " );
	inst( "nop				   " );
	
	inst_address ( c_reset_vector_p1 );
	inst( "nop				   " );
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 1	);
	inst( "nop				   " );
	inst( "lw	 r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "lw	 r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "mtc0	 r4, proc2mngr " );		init_sink( 32'hccccdddd, 1 );

	// initialize data
	data_address( 32'hc000 );
	data( 32'hccccdddd );

end
endtask

//------------------------------------------------------------------------
// attack 7: when processor1 send a change partition command to data memory
// address/access control. 
//------------------------------------------------------------------------

task init_chmempar;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst( "mfc0  r3, mngr2proc " );		    init_src(32'h0000d000,  0 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "lw	 r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "mtc0  r4, proc2mngr " );			init_sink(32'hccccdddd, 0 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "lw	 r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "mtc0	 r4, proc2mngr " );			init_sink(32'hccccdddd, 0 );


	inst_address(c_reset_vector_p1);
	inst( "mfc0	 r6, mngr2proc " );			init_src(32'h0000e000,	1 );
	inst( "mfc0	 r7, mngr2proc " );			init_src(32'h00000000,	1 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "sw	 r6, 0(r7)	   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "mfc0  r3, mngr2proc " );			init_src( 32'h0000c000, 1 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	//inst( "lw	 r4, 0(r3)	   " );
	//inst( "nop				   " );
	//inst( "mtc0	 r4, proc2mngr " );			init_sink(32'hcafebeef, 1);

	//initialize data
	data_address( 32'hc000 );
	data( 32'hcafebeef	);
	data_address( 32'hd000 );
	data( 32'hccccdddd );

end
endtask

//------------------------------------------------------------------------
// attack 8: SMM Mode Attack
//------------------------------------------------------------------------

task init_smm;
begin

	clear_mem;

	inst_address(c_reset_vector_p0);
	inst( "mfc0 r3, mngr2proc  " );		init_src( 32'h00000004,   0 );
	inst( "mfc0 r4, mngr2proc  " );		init_src( 32'h0000d000,   0 );
	inst( "nop				   " );
	inst( "sw	r4,  0(r3)	   " );
	inst( "nop				   " );
	inst( "mfc0 r3, mngr2proc  " );		init_src( 32'h0000c000,	  0 );
	inst( "mfc0 r5, mngr2proc  " );		init_src( 32'haabbccdd,	  0 );
	inst( "nop				   " );
	inst( "sw    r5, 0(r3)	   " );
	inst( "nop				   " );


	inst_address(c_reset_vector_p1);
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 1 );	
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "lw    r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "mtc0  r4, proc2mngr " );		init_sink(32'haabbccdd, 1 );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "lw    r4, 0(r3)	   " );
	inst( "nop				   " );
	inst( "mtc0  r4, proc2mngr " );		init_sink(32'haabbccdd, 1 );

	//intialize data
	data_address ( 32'hc000 );
	data( 32'h11223344 );

end
endtask

//------------------------------------------------------------------------
// attack 9: Proccessor may issue illegal pretch instruction, and lead to
// uncacheable data to be cacheable into the cache
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
// interrupt operation 
//------------------------------------------------------------------------

task init_intr;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst( "setintr			   " );
	inst( "intr				   " );
	inst( "nop				   " );
	inst( "intr				   " );
	inst( "nop				   " );
	inst( "nop				   " );
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h00009000, 0 );

	inst_address(c_reset_vector_p1);
	//inst( "setintr			   " );
	inst( "nop				   " );
	inst( "intr				   " );
	inst( "nop				   " );
	inst( "intr				   " );
	inst( "nop				   " );
	inst( "mfc0  r3, mngr2proc " );		init_src( 32'h0000c000, 1 );
	inst( "nop				   " );

end
endtask

//------------------------------------------------------------------------
// Memory-mapped control register test 
//------------------------------------------------------------------------

task init_mmctlreg;
begin
	
	 clear_mem;

	 inst_address(c_reset_vector_p0);
	 inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0004, 0 );
	 inst( "mfc0 r4, mngr2proc " );		init_src( 32'hb000, 0 );
	 inst( "nop				   " );
	 inst( "nop				   " );
	 inst( "sw	 r4, 0(r3)	   " );
	 inst( "nop				   " );
	 inst( "mtc0 r4, proc2mngr " );		init_sink( 32'hb000, 0 );
	 inst( "nop				   " );

	 inst_address(c_reset_vector_p1);
	 inst( "mfc0 r3, mngr2proc " );		init_src( 32'h0004, 1 );
	 inst( "mfc0 r4, mngr2proc " );		init_src( 32'hb000, 1 );
	 inst( "nop				   " );
	 inst( "nop				   " );
	 inst( "sw	 r4, 0(r3)	   " );
	 inst( "nop				   " );
	 inst( "mtc0 r4, proc2mngr " );		init_sink( 32'hb000, 1 );
	 inst( "nop				   " );

end
endtask

//------------------------------------------------------------------------
// Change mode test 
//------------------------------------------------------------------------

task init_chmod;
begin
	
	clear_mem;

	inst_address(c_reset_vector_p0);
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000d000, 0  );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'haabbccdd, 0 );
	inst("nop					");
	inst("chmod					");
	inst("nop					");
	inst("mfc0  r3, mngr2proc	");     init_src(   32'h0000d000, 0  );	
	inst("nop					");
	inst("lw	r4,	0(r3)		");
	inst("nop					");
	inst("mtc0	r4,	proc2mngr	");		init_sink(  32'haabbccdd, 0 );

	data_address(32'h0000d000);
	data(32'haabbccdd);

end
endtask

//------------------------------------------------------------------------
// Test Case: basic secure lws
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "basic secure lws" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sec_lw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: basic secure sws
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "basic secure sws" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sec_sw_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: low processors read/write to high memory attacks
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(3, "attack1: low proc r/w to high mem" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lowproc_rw_attack;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: low security processor flip its NS-bit to access high memory 
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(4, "attack2: low proc flip NS-bit attack" )
begin
  init_rand_delays( 0, 0, 0 );
  init_NSbit_flip_attack;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: network flip the NS-bit of response, and change the routing 
// field to low processor
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(5, "attack3: low proc flip high resp's NS-bit attack" )
begin
  init_rand_delays( 0, 0, 0 );
  init_flip_route_attack;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: attackers change the destination field of response message, 
// and a broken processor access control module allow low processor to 
// recieve high processor 
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(6, "attack4: lw routing attacks" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lw_route_attack;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: to see whether sec tag in cache reading works or not
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(7, "attacks5: cache sectag attacks" )
begin
	init_rand_delays( 0, 0, 0 );
	init_cache_sectag_flip;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: to see whether sec tag in cache writing works or not
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(8, "security tag in cache write" )
begin
	init_rand_delays( 0, 0, 0 );
	init_cache_wr_sectag;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: to see memory partition instruction work or not
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(9, "memory partiton change" )
begin
	init_rand_delays( 0, 0, 0 );
	init_chmempar;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: SMM mode attack
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(10, "SMM Mode Attack" )
begin
	init_rand_delays( 0, 0, 0 );
	init_smm;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Prefetch/Processor issue illegal pretech instruction
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(11, "Illegal Prefetch" )
begin
	init_rand_delays( 0, 0, 0 );
	init_prefetch;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Interrupt operation 
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(12, "Interrupt Opertation" )
begin
	init_rand_delays( 0, 0, 0 );
	init_intr;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Memory-mapped control register 
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(13, "Memory-mapped control register" )
begin
	init_rand_delays( 0, 0, 0 );
	init_mmctlreg;
	run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: Change mode test
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(14, "Dynamic security level switch" )
begin
	init_rand_delays( 0, 0, 0 );
	init_chmod;
	run_test;
end
`VC_TEST_CASE_END

