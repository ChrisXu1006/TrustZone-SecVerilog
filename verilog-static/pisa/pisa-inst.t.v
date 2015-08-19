//========================================================================
// pisa-inst Unit Tests
//========================================================================

`include "pisa-inst.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "pisa-inst" )

  // PISA Tasks

  pisa_InstTasks pisa();

  //----------------------------------------------------------------------
  // Setup for assembly functiont tests
  //----------------------------------------------------------------------

  reg  [`PISA_INST_NBITS-1:0]        t1_inst;
  wire [`PISA_INST_OPCODE_NBITS-1:0] t1_unpack_opcode;
  wire [`PISA_INST_RS_NBITS-1:0]     t1_unpack_rs;
  wire [`PISA_INST_RT_NBITS-1:0]     t1_unpack_rt;
  wire [`PISA_INST_RD_NBITS-1:0]     t1_unpack_rd;
  wire [`PISA_INST_SHAMT_NBITS-1:0]  t1_unpack_shamt;
  wire [`PISA_INST_FUNC_NBITS-1:0]   t1_unpack_func;
  wire [`PISA_INST_IMM_NBITS-1:0]    t1_unpack_imm;
  wire [`PISA_INST_TARGET_NBITS-1:0] t1_unpack_target;

  pisa_InstUnpack t1_unpack
  (
    .inst   (t1_inst),
    .opcode (t1_unpack_opcode),
    .rs     (t1_unpack_rs),
    .rt     (t1_unpack_rt),
    .rd     (t1_unpack_rd),
    .shamt  (t1_unpack_shamt),
    .func   (t1_unpack_func),
    .imm    (t1_unpack_imm),
    .target (t1_unpack_target)
  );

  reg t1_reset = 1;

  pisa_InstTrace t1_trace
  (
    .clk    (clk),
    .reset  (t1_reset),
    .inst   (t1_inst)
  );

  // Helper tasks

  task check_fmt_r
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_RS_NBITS-1:0]     rs,
    input [`PISA_INST_RT_NBITS-1:0]     rt,
    input [`PISA_INST_RD_NBITS-1:0]     rd,
    input [`PISA_INST_SHAMT_NBITS-1:0]  shamt,
    input [`PISA_INST_FUNC_NBITS-1:0]   func
  );
  begin
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_opcode, opcode );
    `VC_TEST_NET( t1_unpack_rs,     rs     );
    `VC_TEST_NET( t1_unpack_rt,     rt     );
    `VC_TEST_NET( t1_unpack_rd,     rd     );
    `VC_TEST_NET( t1_unpack_shamt,  shamt  );
    `VC_TEST_NET( t1_unpack_func,   func   );
    t1_inst = 32'hx;
    #9;
  end
  endtask

  task check_fmt_i
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_RS_NBITS-1:0]     rs,
    input [`PISA_INST_RT_NBITS-1:0]     rt,
    input [`PISA_INST_IMM_NBITS-1:0]    imm
  );
  begin
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_opcode, opcode );
    `VC_TEST_NET( t1_unpack_rs,     rs     );
    `VC_TEST_NET( t1_unpack_rt,     rt     );
    `VC_TEST_NET( t1_unpack_imm,    imm    );
    t1_inst = 32'hx;
    #9;
  end
  endtask

  task check_fmt_j
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_TARGET_NBITS-1:0] target
  );
  begin
    #1;
    t1_trace.trace_display();
    `VC_TEST_NET( t1_unpack_opcode, opcode );
    `VC_TEST_NET( t1_unpack_target, target );
    t1_inst = 32'hx;
    #9;
  end
  endtask

  //----------------------------------------------------------------------
  // Assembly funcrtions for basic instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "asm functions: basic instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_mfc0( 5'd3, 5'd2 );
    check_fmt_r( 6'b010000, 5'b00000, 5'd3, 5'd2, 5'b00000, 6'b000000 );

    t1_inst = pisa.asm_mtc0( 5'd3, 5'd2 );
    check_fmt_r( 6'b010000, 5'b00100, 5'd3, 5'd2, 5'b00000, 6'b000000 );

    t1_inst = pisa.asm_nop(0);
    check_fmt_i( 6'b000000, 5'd0, 5'd0, 16'h0 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for reg-reg arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "asm functions: reg-reg instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_addu( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100001 );

    t1_inst = pisa.asm_subu( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100011 );

    t1_inst = pisa.asm_and( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100100 );

    t1_inst = pisa.asm_or( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100101 );

    t1_inst = pisa.asm_xor( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100110 );

    t1_inst = pisa.asm_nor( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b100111 );

    t1_inst = pisa.asm_slt( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b101010 );

    t1_inst = pisa.asm_sltu( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd7, 5'd29, 5'd13, 5'd0, 6'b101011 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for reg-imm arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "asm functions: reg-imm instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_addiu( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001001, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_andi( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001100, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_ori( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001101, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_xori( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001110, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_slti( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001010, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_sltiu( 5'd7, 5'd29, 16'habcd );
    check_fmt_i( 6'b001011, 5'd29, 5'd7, 16'habcd );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for shift instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "asm functions: shift instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_sll( 5'd13, 5'd7, 5'd3 );
    check_fmt_r( 6'b000000, 5'd0, 5'd7, 5'd13, 5'd3, 6'b000000 );

    t1_inst = pisa.asm_srl( 5'd13, 5'd7, 5'd3 );
    check_fmt_r( 6'b000000, 5'd0, 5'd7, 5'd13, 5'd3, 6'b000010 );

    t1_inst = pisa.asm_sra( 5'd13, 5'd7, 5'd3 );
    check_fmt_r( 6'b000000, 5'd0, 5'd7, 5'd13, 5'd3, 6'b000011 );

    t1_inst = pisa.asm_sllv( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000100 );

    t1_inst = pisa.asm_srlv( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000110 );

    t1_inst = pisa.asm_srav( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b000000, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000111 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for other instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "asm functions: other instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_lui( 5'd7, 16'habcd );
    check_fmt_i( 6'b001111, 5'd0, 5'd7, 16'habcd );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for multiply/divide instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "asm functions: multiply/divide instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_mul( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b011100, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000010 );

    t1_inst = pisa.asm_div( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000101 );

    t1_inst = pisa.asm_divu( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000111 );

    t1_inst = pisa.asm_rem( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd29, 5'd7, 5'd13, 5'd0, 6'b000110 );

    t1_inst = pisa.asm_remu( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd29, 5'd7, 5'd13, 5'd0, 6'b001000 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for load instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "asm functions: load instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_lw( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b100011, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_lh( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b100001, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_lhu( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b100101, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_lb( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b100000, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_lbu( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b100100, 5'd29, 5'd7, 16'habcd );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for store instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "asm functions: store instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_sw( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b101011, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_sh( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b101001, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_sb( 5'd7, 16'habcd, 5'd29 );
    check_fmt_i( 6'b101000, 5'd29, 5'd7, 16'habcd );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for unconditional jump instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "asm functions: unconditional jump instructinos" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_j( 26'h3deadbe );
    check_fmt_j( 6'b000010, 26'h3deadbe );

    t1_inst = pisa.asm_jal( 26'h3deadbe );
    check_fmt_j( 6'b000011, 26'h3deadbe );

    t1_inst = pisa.asm_jr( 5'd29 );
    check_fmt_r( 6'b000000, 5'd29, 5'd0, 5'd0, 5'd0, 6'b001000 );

    t1_inst = pisa.asm_jalr( 5'd13, 5'd29 );
    check_fmt_r( 6'b000000, 5'd29, 5'd0, 5'd13, 5'd0, 6'b001001 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for conditional branch instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "asm functions: conditional branch instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_beq( 5'd29, 5'd7, 16'habcd );
    check_fmt_i( 6'b000100, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_bne( 5'd29, 5'd7, 16'habcd );
    check_fmt_i( 6'b000101, 5'd29, 5'd7, 16'habcd );

    t1_inst = pisa.asm_blez( 5'd29, 16'habcd );
    check_fmt_i( 6'b000110, 5'd29, 5'd0, 16'habcd );

    t1_inst = pisa.asm_bgtz( 5'd29, 16'habcd );
    check_fmt_i( 6'b000111, 5'd29, 5'd0, 16'habcd );

    t1_inst = pisa.asm_bltz( 5'd29, 16'habcd );
    check_fmt_i( 6'b000001, 5'd29, 5'd0, 16'habcd );

    t1_inst = pisa.asm_bgez( 5'd29, 16'habcd );
    check_fmt_i( 6'b000001, 5'd29, 5'd1, 16'habcd );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for system-level instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "asm functions: system-level instructions" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_syscall(0);
    check_fmt_r( 6'b000000, 5'd0, 5'd0, 5'd0, 5'd0, 6'b001100 );

    t1_inst = pisa.asm_eret(0);
    check_fmt_r( 6'b010000, 5'b10000, 5'd0, 5'd0, 5'd0, 6'b011000 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for atomic memory operations
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 12, "asm functions: atomic memory operations" )
  begin

    #1;  t1_reset = 1'b1;
    #20; t1_reset = 1'b0;

    t1_inst = pisa.asm_amo_add( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd7, 5'd29, 5'd13, 5'd0, 6'b000010 );

    t1_inst = pisa.asm_amo_and( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd7, 5'd29, 5'd13, 5'd0, 6'b000011 );

    t1_inst = pisa.asm_amo_or( 5'd13, 5'd7, 5'd29 );
    check_fmt_r( 6'b100111, 5'd7, 5'd29, 5'd13, 5'd0, 6'b000100 );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Setup for assembly string tests
  //----------------------------------------------------------------------

  reg [`PISA_INST_NBITS-1:0] t2_inst_asm_func;
  reg [`PISA_INST_NBITS-1:0] t2_inst_asm_str;

  reg t2_reset = 1;

  pisa_InstTrace t2_trace
  (
    .clk    (clk),
    .reset  (t2_reset),
    .inst   (t2_inst_asm_str)
  );

  task check_asm_func_vs_str;
  begin
    #1;
    t2_trace.trace_display();
    `VC_TEST_NET( t2_inst_asm_str, t2_inst_asm_func );
    t2_inst_asm_func = 32'hx;
    t2_inst_asm_str  = 32'hx;
    #9;
  end
  endtask

  //----------------------------------------------------------------------
  // Assembly strings for basic instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 13, "asm strings: basic instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_mfc0( 5'd3, 5'd2 );
    t2_inst_asm_str  = pisa.asm( 0, "mfc0 r3, r2" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_mtc0( 5'd3, 5'd2 );
    t2_inst_asm_str  = pisa.asm( 0, "mtc0 r3, r2" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_nop(0);
    t2_inst_asm_str  = pisa.asm( 0, "nop" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly strings for reg-reg arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 14, "asm strings: reg-reg instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_addu( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "addu r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_subu( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "subu r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_and( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "and r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_or( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "or r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_xor( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "xor r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_nor( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "nor r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_slt( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "slt r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sltu( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "sltu r13, r7, r29" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly strings for reg-imm arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 15, "asm strings: reg-imm instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_addiu( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "addiu r7, r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_andi( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "andi r7, r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_ori( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "ori r7, r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_xori( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "xori r7, r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_slti( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "slti r7, r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sltiu( 5'd7, 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "sltiu r7, r29, 0xabcd" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for shift instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 16, "asm functions: shift instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_sll( 5'd13, 5'd7, 5'd3 );
    t2_inst_asm_str  = pisa.asm( 0, "sll r13, r7, 3" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_srl( 5'd13, 5'd7, 5'd3 );
    t2_inst_asm_str  = pisa.asm( 0, "srl r13, r7, 3" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sra( 5'd13, 5'd7, 5'd3 );
    t2_inst_asm_str  = pisa.asm( 0, "sra r13, r7, 3" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sllv( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "sllv r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_srlv( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "srlv r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_srav( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "srav r13, r7, r29" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for other instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 17, "asm functions: other instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_lui( 5'd7, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "lui r7, 0xabcd" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for multiply/divide instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 18, "asm functions: multiply/divide instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_mul( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "mul r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_div( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "div r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_divu( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "divu r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_rem( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "rem r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_remu( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "remu r13, r7, r29" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for load instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 19, "asm functions: load instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_lw( 5'd7, 16'habcd, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "lw r7, 0xabcd(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_lh( 5'd7, 16'habcd, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "lh r7, 0xabcd(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_lhu( 5'd7, 16'd0, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "lhu r7, 0(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_lb( 5'd7, 16'd4, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "lb r7, 4(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_lbu( 5'd7, 16'd8, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "lbu r7, 8(r29)" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for store instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 20, "asm functions: store instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_sw( 5'd7, 16'habcd, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "sw r7, 0xabcd(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sh( 5'd7, 16'd4, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "sh r7, 4(r29)" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_sb( 5'd7, 16'd8, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "sb r7, 8(r29)" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for unconditional jump instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 21, "asm functions: unconditional jump instructinos" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_j( 26'h3deadbe );
    t2_inst_asm_str  = pisa.asm( 0, "j 0x3deadbe" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_j( 26'h0000404 );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "j [0x1010]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_j( 26'h0000403 );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "j [+3]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_j( 26'h00003fd );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "j [-3]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_jal( 26'd13526 );
    t2_inst_asm_str  = pisa.asm( 0, "jal 13526" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_jr( 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "jr r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_jalr( 5'd13, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "jalr r13, r29" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for conditional branch instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 22, "asm functions: conditional branch instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_beq( 5'd29, 5'd7, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "beq r29, r7, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_beq( 5'd29, 5'd7, 16'h0003 );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "beq r29, r7, [0x1010]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_beq( 5'd29, 5'd7, 16'hfc3f );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "beq r29, r7, [0x0100]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_beq( 5'd29, 5'd7, 16'h0002 );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "beq r29, r7, [+3]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_beq( 5'd29, 5'd7, 16'hfffc );
    t2_inst_asm_str  = pisa.asm( 32'h00001000, "beq r29, r7, [-3]" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_bne( 5'd29, 5'd7, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "bne r29, r7, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_blez( 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "blez r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_bgtz( 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "bgtz r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_bltz( 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "bltz r29, 0xabcd" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_bgez( 5'd29, 16'habcd );
    t2_inst_asm_str  = pisa.asm( 0, "bgez r29, 0xabcd" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly functions for system-level instructions
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 23, "asm functions: system-level instructions" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_syscall(0);
    t2_inst_asm_str  = pisa.asm( 0, "syscall" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_eret(0);
    t2_inst_asm_str  = pisa.asm( 0, "eret" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Assembly strings for atomic memory operations
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 24, "asm strings: atomic memory operations" )
  begin

    #1;  t2_reset = 1'b1;
    #20; t2_reset = 1'b0;

    t2_inst_asm_func = pisa.asm_amo_add( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "amo.add r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_amo_and( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "amo.and r13, r7, r29" );
    check_asm_func_vs_str;

    t2_inst_asm_func = pisa.asm_amo_or( 5'd13, 5'd7, 5'd29 );
    t2_inst_asm_str  = pisa.asm( 0, "amo.or r13, r7, r29" );
    check_asm_func_vs_str;

  end
  `VC_TEST_CASE_END

  // addresss ( 0x1000 );
  // inst ( "mfc0 r1, mngr2proc" ); init_src  ( 0x00000001 );
  // inst ( "mfc0 r2, mngr2proc" ); init_src  ( 0x00000002 );
  // inst ( "addu r3, r1, r2"    );
  // inst ( "mtc0 r3, proc2mngr" ); init_sink ( 0x00000003 );

  // addresss ( 0x1000 );
  // inst ( "mfc0 r1, mngr2proc" ); init_src  ( 0x00002000 );
  // inst ( "lw   r2, 0(r1)"     );
  // inst ( "mtc0 r2, proc2mngr" ); init_sink ( 0x0a0b0c0d );
  //
  // addresss ( 0x2000 );
  // data ( 0x0a0b0c0d );

  // addresss ( 0x1000 );
  // inst ( "mfc0 r1, mngr2proc" ); init_src  ( 0x00000001 );
  // inst ( "mfc0 r2, mngr2proc" ); init_src  ( 0x00000002 );
  // inst ( "bne  r1, r2, [+2]"  );
  // inst ( "mtc0 r0, proc2mngr" );
  // inst ( "mtc0 r1, proc2mngr" ); init_sink ( 0x00000001 );

  `VC_TEST_SUITE_END
endmodule

