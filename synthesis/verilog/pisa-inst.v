//========================================================================
// PARC Instruction Type
//========================================================================
// Instruction types are similar to message types but are strictly used
// for communication within a PARC-based processor. Instruction
// "messages" can be unpacked into the various fields as defined by the
// PARC ISA, as well as be constructed from specifying each field
// explicitly. The 32-bit instruction has different fields depending on
// the format of the instruction used. The following are the various
// instruction encoding formats used in the PARC ISA.
//
// R-Type:
//
//   31  26 25  21 20  16 15  11 10   6 5    0
//  +------+------+------+------+------+------+
//  |  op  |  rs  |  rt  |  rd  |  sa  | func |
//  +------+------+------+------+------+------+
//
// I-Type:
//
//   31  26 25  21 20  16 15                 0
//  +------+------+------+--------------------+
//  |  op  |  rs  |  rt  |         imm        |
//  +------+------+------+--------------------+
//
// J-Type:
//
//   31  26 25                               0
//  +------+----------------------------------+
//  |  op  |             target               |
//  +------+----------------------------------+
//
// The instruction type also defines a list of instruction encodings in
// the PARC ISA, which are used to decode instructions in the control unit.

`ifndef PISA_INST_V
`define PISA_INST_V

//------------------------------------------------------------------------
// Instruction fields
//------------------------------------------------------------------------

`define PISA_INST_OPCODE    31:26
`define PISA_INST_RS        25:21
`define PISA_INST_RT        20:16
`define PISA_INST_RD        15:11
`define PISA_INST_SHAMT     10:6
`define PISA_INST_FUNC      5:0
`define PISA_INST_IMM       15:0
`define PISA_INST_TARGET    25:0

//------------------------------------------------------------------------
// Field sizes
//------------------------------------------------------------------------

`define PISA_INST_NBITS          32
`define PISA_INST_OPCODE_NBITS   6
`define PISA_INST_RS_NBITS       5
`define PISA_INST_RT_NBITS       5
`define PISA_INST_RD_NBITS       5
`define PISA_INST_SHAMT_NBITS    5
`define PISA_INST_FUNC_NBITS     6
`define PISA_INST_IMM_NBITS      16
`define PISA_INST_TARGET_NBITS   26

//------------------------------------------------------------------------
// Instruction opcodes
//------------------------------------------------------------------------

// Basic instructions

`define PISA_INST_MFC0    32'b010000_00000_?????_?????_00000_000000
`define PISA_INST_MTC0    32'b010000_00100_?????_?????_00000_000000
`define PISA_INST_NOP     32'b000000_00000_00000_00000_00000_000000

// Register-register arithmetic, logical, and comparison instructions

`define PISA_INST_ADDU    32'b000000_?????_?????_?????_00000_100001
`define PISA_INST_SUBU    32'b000000_?????_?????_?????_00000_100011
`define PISA_INST_AND     32'b000000_?????_?????_?????_00000_100100
`define PISA_INST_OR      32'b000000_?????_?????_?????_00000_100101
`define PISA_INST_XOR     32'b000000_?????_?????_?????_00000_100110
`define PISA_INST_NOR     32'b000000_?????_?????_?????_00000_100111
`define PISA_INST_SLT     32'b000000_?????_?????_?????_00000_101010
`define PISA_INST_SLTU    32'b000000_?????_?????_?????_00000_101011

// Register-immediate arithmetic, logical, and comparison instructions

`define PISA_INST_ADDIU   32'b001001_?????_?????_?????_?????_??????
`define PISA_INST_ANDI    32'b001100_?????_?????_?????_?????_??????
`define PISA_INST_ORI     32'b001101_?????_?????_?????_?????_??????
`define PISA_INST_XORI    32'b001110_?????_?????_?????_?????_??????
`define PISA_INST_SLTI    32'b001010_?????_?????_?????_?????_??????
`define PISA_INST_SLTIU   32'b001011_?????_?????_?????_?????_??????

// Shift instructions

`define PISA_INST_SLL     32'b000000_00000_?????_?????_?????_000000
`define PISA_INST_SRL     32'b000000_00000_?????_?????_?????_000010
`define PISA_INST_SRA     32'b000000_00000_?????_?????_?????_000011
`define PISA_INST_SLLV    32'b000000_?????_?????_?????_00000_000100
`define PISA_INST_SRLV    32'b000000_?????_?????_?????_00000_000110
`define PISA_INST_SRAV    32'b000000_?????_?????_?????_00000_000111

// Other instructions

`define PISA_INST_LUI     32'b001111_00000_?????_?????_?????_??????

// Multiply/divide instructions

`define PISA_INST_MUL     32'b011100_?????_?????_?????_00000_000010
`define PISA_INST_DIV     32'b100111_?????_?????_?????_00000_000101
`define PISA_INST_DIVU    32'b100111_?????_?????_?????_00000_000111
`define PISA_INST_REM     32'b100111_?????_?????_?????_00000_000110
`define PISA_INST_REMU    32'b100111_?????_?????_?????_00000_001000

// Load instructions

`define PISA_INST_LW      32'b100011_?????_?????_?????_?????_??????
`define PISA_INST_LH      32'b100001_?????_?????_?????_?????_??????
`define PISA_INST_LHU     32'b100101_?????_?????_?????_?????_??????
`define PISA_INST_LB      32'b100000_?????_?????_?????_?????_??????
`define PISA_INST_LBU     32'b100100_?????_?????_?????_?????_??????
`define PISA_INST_PRELW   32'b100111_?????_?????_?????_?????_??????

// Store instructions

`define PISA_INST_SW      32'b101011_?????_?????_?????_?????_??????
`define PISA_INST_SH      32'b101001_?????_?????_?????_?????_??????
`define PISA_INST_SB      32'b101000_?????_?????_?????_?????_??????

// Unconditional jump instructions

`define PISA_INST_J       32'b000010_?????_?????_?????_?????_??????
`define PISA_INST_JAL     32'b000011_?????_?????_?????_?????_??????
`define PISA_INST_JR      32'b000000_?????_00000_00000_00000_001000
`define PISA_INST_JALR    32'b000000_?????_00000_?????_00000_001001

// Conditional branch instructions

`define PISA_INST_BEQ     32'b000100_?????_?????_?????_?????_??????
`define PISA_INST_BNE     32'b000101_?????_?????_?????_?????_??????
`define PISA_INST_BLEZ    32'b000110_?????_00000_?????_?????_??????
`define PISA_INST_BGTZ    32'b000111_?????_00000_?????_?????_??????
`define PISA_INST_BLTZ    32'b000001_?????_00000_?????_?????_??????
`define PISA_INST_BGEZ    32'b000001_?????_00001_?????_?????_??????

// System-level instructions

`define PISA_INST_SYSCALL 32'b000000_?????_?????_?????_?????_001100
`define PISA_INST_ERET    32'b010000_10000_00000_00000_00000_011000

// Atomic memory operations

`define PISA_INST_AMO_ADD 32'b100111_?????_?????_?????_00000_000010
`define PISA_INST_AMO_AND 32'b100111_?????_?????_?????_00000_000011
`define PISA_INST_AMO_OR  32'b100111_?????_?????_?????_00000_000100

// Interrupt operations
`define PISA_INST_INTR	  32'b000111_?????_?????_?????_?????_?????0
`define PISA_INST_SETINTR 32'b000111_?????_?????_?????_?????_?????1

// Change Mode operations
`define PISA_INST_CHMOD   32'b111111_?????_?????_?????_11111_111111

// Change Control Register Operations
`define PISA_INST_CHMEMPAR 32'b011111_?????_?????_?????_?????_??????

// Direct Memory Access instruction
`define PISA_INST_DIRMEM  32'b101111_?????_?????_?????_?????_??????

// Debug Intrucstion
`define PISA_INST_DEBUG	  32'b101110_?????_?????_?????_?????_??????

//------------------------------------------------------------------------
// Coprocessor registers
//------------------------------------------------------------------------

`define PISA_CPR_MNGR2PROC  1
`define PISA_CPR_PROC2MNGR  2
`define PISA_CPR_STATS_EN   21
`define PISA_CPR_NUMCORES   16
`define PISA_CPR_COREID     17

//------------------------------------------------------------------------
// Helper Tasks
//------------------------------------------------------------------------

module pisa_InstTasks();

  //----------------------------------------------------------------------
  // Assembly functions for each format type
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_fmt_r
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_RS_NBITS-1:0]     rs,
    input [`PISA_INST_RT_NBITS-1:0]     rt,
    input [`PISA_INST_RD_NBITS-1:0]     rd,
    input [`PISA_INST_SHAMT_NBITS-1:0]  shamt,
    input [`PISA_INST_FUNC_NBITS-1:0]   func
  );
  begin
    asm_fmt_r[`PISA_INST_OPCODE] = opcode;
    asm_fmt_r[`PISA_INST_RS]     = rs;
    asm_fmt_r[`PISA_INST_RT]     = rt;
    asm_fmt_r[`PISA_INST_RD]     = rd;
    asm_fmt_r[`PISA_INST_SHAMT]  = shamt;
    asm_fmt_r[`PISA_INST_FUNC]   = func;
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_fmt_i
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_RS_NBITS-1:0]     rs,
    input [`PISA_INST_RT_NBITS-1:0]     rt,
    input [`PISA_INST_IMM_NBITS-1:0]    imm
  );
  begin
    asm_fmt_i[`PISA_INST_OPCODE] = opcode;
    asm_fmt_i[`PISA_INST_RS]     = rs;
    asm_fmt_i[`PISA_INST_RT]     = rt;
    asm_fmt_i[`PISA_INST_IMM]    = imm;
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_fmt_j
  (
    input [`PISA_INST_OPCODE_NBITS-1:0] opcode,
    input [`PISA_INST_TARGET_NBITS-1:0] target
  );
  begin
    asm_fmt_j[`PISA_INST_OPCODE] = opcode;
    asm_fmt_j[`PISA_INST_TARGET] = target;
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for basic instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_mfc0
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RD_NBITS-1:0]  rd
  );
  begin
    asm_mfc0 = asm_fmt_r( 6'b010000, 5'd0, rt, rd, 5'd0, 6'b000000 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_mtc0
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RD_NBITS-1:0]  rd
  );
  begin
    asm_mtc0 = asm_fmt_r( 6'b010000, 5'b00100, rt, rd, 5'd0, 6'b000000 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_nop( input dummy );
  begin
    asm_nop = asm_fmt_i( 6'b000000, 5'd0, 5'd0, 16'h0 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for reg-reg arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_addu
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_addu = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100001 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_subu
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_subu = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100011 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_and
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_and = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100100 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_or
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_or = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100101 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_xor
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_xor = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100110 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_nor
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_nor = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b100111 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_slt
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_slt = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b101010 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sltu
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_sltu = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b101011 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for reg-imm arith, logical, and cmp instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_addiu
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_addiu = asm_fmt_i( 6'b001001, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_andi
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_andi = asm_fmt_i( 6'b001100, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_ori
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_ori = asm_fmt_i( 6'b001101, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_xori
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_xori = asm_fmt_i( 6'b001110, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_slti
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_slti = asm_fmt_i( 6'b001010, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sltiu
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_sltiu = asm_fmt_i( 6'b001011, rs, rt, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for shift instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_sll
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_SHAMT_NBITS-1:0] shamt
  );
  begin
    asm_sll = asm_fmt_r( 6'b000000, 5'd0, rt, rd, shamt, 6'b000000 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_srl
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_SHAMT_NBITS-1:0] shamt
  );
  begin
    asm_srl = asm_fmt_r( 6'b000000, 5'd0, rt, rd, shamt, 6'b000010 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sra
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_SHAMT_NBITS-1:0] shamt
  );
  begin
    asm_sra = asm_fmt_r( 6'b000000, 5'd0, rt, rd, shamt, 6'b000011 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sllv
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_RS_NBITS-1:0]    rs
  );
  begin
    asm_sllv = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b000100 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_srlv
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_RS_NBITS-1:0]    rs
  );
  begin
    asm_srlv = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b000110 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_srav
  (
    input [`PISA_INST_RD_NBITS-1:0]    rd,
    input [`PISA_INST_RT_NBITS-1:0]    rt,
    input [`PISA_INST_RS_NBITS-1:0]    rs
  );
  begin
    asm_srav = asm_fmt_r( 6'b000000, rs, rt, rd, 5'd0, 6'b000111 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for other instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_lui
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_lui = asm_fmt_i( 6'b001111, 5'd0, rt, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for multiply/divide instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_mul
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RT_NBITS-1:0] rt,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_mul = asm_fmt_r( 6'b011100, rs, rt, rd, 5'd0, 6'b000010 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_div
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RT_NBITS-1:0] rt,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_div = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000101 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_divu
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RT_NBITS-1:0] rt,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_divu = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000111 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_rem
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RT_NBITS-1:0] rt,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_rem = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000110 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_remu
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RT_NBITS-1:0] rt,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_remu = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b001000 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for load instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_lw
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_lw = asm_fmt_i( 6'b100011, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_lh
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_lh = asm_fmt_i( 6'b100001, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_lhu
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_lhu = asm_fmt_i( 6'b100101, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_lb
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_lb = asm_fmt_i( 6'b100000, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_lbu
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_lbu = asm_fmt_i( 6'b100100, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_prelw
  (
    input [`PISA_INST_RT_NBITS-1:0]	 rt,
	input [`PISA_INST_IMM_NBITS-1:0] imm,
	input [`PISA_INST_RS_NBITS-1:0]	 rs
  );
  begin
	asm_prelw = asm_fmt_i( 6'b100111, rs, rt, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for store instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_sw
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_sw = asm_fmt_i( 6'b101011, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sh
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_sh = asm_fmt_i( 6'b101001, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_sb
  (
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm,
    input [`PISA_INST_RS_NBITS-1:0]  rs
  );
  begin
    asm_sb = asm_fmt_i( 6'b101000, rs, rt, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for unconditional jump instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_j
  (
    input [`PISA_INST_TARGET_NBITS-1:0] target
  );
  begin
    asm_j = asm_fmt_j( 6'b000010, target );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_jal
  (
    input [`PISA_INST_TARGET_NBITS-1:0] target
  );
  begin
    asm_jal = asm_fmt_j( 6'b000011, target );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_jr
  (
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_jr = asm_fmt_r( 6'b000000, rs, 5'd0, 5'd0, 5'd0, 6'b001000 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_jalr
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs
  );
  begin
    asm_jalr = asm_fmt_r( 6'b000000, rs, 5'd0, rd, 5'd0, 6'b001001 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for conditional branch instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_beq
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_beq = asm_fmt_i( 6'b000100, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_bne
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_RT_NBITS-1:0]  rt,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_bne = asm_fmt_i( 6'b000101, rs, rt, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_blez
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_blez = asm_fmt_i( 6'b000110, rs, 5'd0, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_bgtz
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_bgtz = asm_fmt_i( 6'b000111, rs, 5'd0, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_bltz
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_bltz = asm_fmt_i( 6'b000001, rs, 5'd0, imm );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_bgez
  (
    input [`PISA_INST_RS_NBITS-1:0]  rs,
    input [`PISA_INST_IMM_NBITS-1:0] imm
  );
  begin
    asm_bgez = asm_fmt_i( 6'b000001, rs, 5'd1, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for system-level instructions
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_syscall( input dummy );
  begin
    asm_syscall = asm_fmt_r( 6'b000000, 5'd0, 5'd0, 5'd0, 5'd0, 6'b001100 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_eret( input dummy );
  begin
    asm_eret = asm_fmt_r( 6'b010000, 5'b10000, 5'd0, 5'd0, 5'd0, 6'b011000 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for atomic memory operations
  //----------------------------------------------------------------------

  function [`PISA_INST_NBITS-1:0] asm_amo_add
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_amo_add = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000010 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_amo_and
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_amo_and = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000011 );
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_amo_or
  (
    input [`PISA_INST_RD_NBITS-1:0] rd,
    input [`PISA_INST_RS_NBITS-1:0] rs,
    input [`PISA_INST_RT_NBITS-1:0] rt
  );
  begin
    asm_amo_or = asm_fmt_r( 6'b100111, rs, rt, rd, 5'd0, 6'b000100 );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for interrupt operations
  //----------------------------------------------------------------------
  function [`PISA_INST_NBITS-1:0] asm_intr( input dummy );
  begin
	asm_intr = asm_fmt_r( 6'b000111, 'hx, 'hx, 'hx, 'hx, 6'bxxxxx0);
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm_setintr( input dummy );
  begin
	asm_setintr = asm_fmt_r( 6'b000111, 'hx, 'hx, 'hx, 'hx, 6'bxxxxx1);
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for changing execution code
  //----------------------------------------------------------------------
  function [`PISA_INST_NBITS-1:0] asm_chmod( input dummy );
  begin
	asm_chmod = asm_fmt_r( 6'b111111, 'hx, 'hx, 'hx, 5'b11111, 6'b111111);
  end
  endfunction
	
  //----------------------------------------------------------------------
  // Assembly functions for changing memory partition register
  //----------------------------------------------------------------------
  function [`PISA_INST_NBITS-1:0]	asm_chmempar
  (
	input [`PISA_INST_RT_NBITS-1:0]		rt,
    input [`PISA_INST_IMM_NBITS-1:0]	imm,
    input [`PISA_INST_RS_NBITS-1:0]		rs
  );
  begin
	asm_chmempar = asm_fmt_i( 6'b011111, rs, rt, imm );
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for direct memory access
  //----------------------------------------------------------------------
  function [`PISA_INST_NBITS-1:0]	asm_dirmem
  (
	input [`PISA_INST_RT_NBITS-1:0]		rt,
	input [`PISA_INST_IMM_NBITS-1:0]	imm,
	input [`PISA_INST_RS_NBITS-1:0]		rs
  );
  begin
	asm_dirmem = asm_fmt_i( 6'b101111, rs, rt, imm);
  end
  endfunction

  //----------------------------------------------------------------------
  // Assembly functions for debug instruction
  //----------------------------------------------------------------------
  function [`PISA_INST_NBITS-1:0]	asm_debug
  (
	input [`PISA_INST_RT_NBITS-1:0]		rt,
	input [`PISA_INST_IMM_NBITS-1:0]	imm,
	input [`PISA_INST_RS_NBITS-1:0]		rs
  );
  begin
	asm_debug = asm_fmt_i( 6'b101110, rs, rt, imm );
  end
  endfunction

endmodule
//------------------------------------------------------------------------
// Unpack instruction
//------------------------------------------------------------------------

module pisa_InstUnpack
(
  // Packed message

  input  [`PISA_INST_NBITS-1:0]        inst,

  // Packed fields

  output [`PISA_INST_OPCODE_NBITS-1:0] opcode,
  output [`PISA_INST_RS_NBITS-1:0]     rs,
  output [`PISA_INST_RT_NBITS-1:0]     rt,
  output [`PISA_INST_RD_NBITS-1:0]     rd,
  output [`PISA_INST_SHAMT_NBITS-1:0]  shamt,
  output [`PISA_INST_FUNC_NBITS-1:0]   func,
  output [`PISA_INST_IMM_NBITS-1:0]    imm,
  output [`PISA_INST_TARGET_NBITS-1:0] target
);

  assign opcode   = inst[`PISA_INST_OPCODE];
  assign rs       = inst[`PISA_INST_RS];
  assign rt       = inst[`PISA_INST_RT];
  assign rd       = inst[`PISA_INST_RD];
  assign shamt    = inst[`PISA_INST_SHAMT];
  assign func     = inst[`PISA_INST_FUNC];
  assign imm      = inst[`PISA_INST_IMM];
  assign target   = inst[`PISA_INST_TARGET];

endmodule

`endif /* PISA_INST_V */
