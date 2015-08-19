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

  //----------------------------------------------------------------------
  // Assembly from string
  //----------------------------------------------------------------------

  integer e;
  reg [10*8-1:0] inst_str;

  reg [`PISA_INST_OPCODE_NBITS-1:0] opcode;
  reg [`PISA_INST_RS_NBITS-1:0]     rs;
  reg [`PISA_INST_RT_NBITS-1:0]     rt;
  reg [`PISA_INST_RD_NBITS-1:0]     rd;
  reg [`PISA_INST_SHAMT_NBITS-1:0]  shamt;
  reg [`PISA_INST_FUNC_NBITS-1:0]   func;
  reg [`PISA_INST_IMM_NBITS-1:0]    imm;
  reg [`PISA_INST_TARGET_NBITS-1:0] target;

  reg [4:0]      ra;
  reg [4:0]      rb;
  reg [4:0]      rc;

  reg [20*8-1:0]  imm_s;

  integer s2i_16b_e;
  function [15:0] s2i_16b( input [20*8-1:0] imm_s );
  begin
    s2i_16b_e = $sscanf( imm_s, "0x%x", s2i_16b );
    if ( s2i_16b_e == 0 )
      s2i_16b_e = $sscanf( imm_s, "%d", s2i_16b );
    if ( s2i_16b_e == 0 )
      e = 0;
  end
  endfunction

  integer s2i_5b_e;
  function [4:0] s2i_5b( input [20*8-1:0] imm_s );
  begin
    s2i_5b_e = $sscanf( imm_s, "0x%x", s2i_5b );
    if ( s2i_5b_e == 0 )
      s2i_5b_e = $sscanf( imm_s, "%d", s2i_5b );
    if ( s2i_5b_e == 0 )
      e = 0;
  end
  endfunction

  // Technically we would need to make sure the 4 msb of the PC match
  // the given target ... but for now we just assume they are both zero.

  reg [20*8-1:0] jtarg_s;
  reg [25:0]     jtarg_temp;

  integer s2jt_e;
  function [25:0] s2jt( input [31:0] pc, input [20*8-1:0] jtarg_s );
  begin
    s2jt_e = $sscanf( jtarg_s, "0x%x", s2jt );
    if ( s2jt_e == 0 )
      s2jt_e = $sscanf( jtarg_s, "%d", s2jt );
    if ( s2jt_e == 0 ) begin
      s2jt_e = $sscanf( jtarg_s, "[0x%x]", jtarg_temp );
      s2jt = (jtarg_temp >> 2);
    end
    if ( s2jt_e == 0 ) begin
      s2jt_e = $sscanf( jtarg_s, "[+%d]", jtarg_temp );
      s2jt = (pc + jtarg_temp*4) >> 2;
    end
    if ( s2jt_e == 0 ) begin
      s2jt_e = $sscanf( jtarg_s, "[-%d]", jtarg_temp );
      s2jt = (pc - jtarg_temp*4) >> 2;
    end
    if ( s2jt_e == 0 )
      e = 0;
  end
  endfunction

  reg [20*8-1:0] btarg_s;
  reg [25:0]     btarg_temp;

  integer s2bt_e;
  function [25:0] s2bt( input [31:0] pc, input [20*8-1:0] btarg_s );
  begin
    s2bt_e = $sscanf( btarg_s, "0x%x", s2bt );
    if ( s2bt_e == 0 )
      s2bt_e = $sscanf( btarg_s, "%d", s2bt );
    if ( s2bt_e == 0 ) begin
      s2bt_e = $sscanf( btarg_s, "[0x%x]", btarg_temp );
      s2bt = (btarg_temp - pc - 4) >> 2;
    end
    if ( s2bt_e == 0 ) begin
      s2bt_e = $sscanf( btarg_s, "[+%d]", btarg_temp );
      s2bt = ((pc + btarg_temp*4) - pc - 4) >> 2;
    end
    if ( s2bt_e == 0 ) begin
      s2bt_e = $sscanf( btarg_s, "[-%d]", btarg_temp );
      s2bt = ((pc - btarg_temp*4) - pc - 4) >> 2;
    end
    if ( s2bt_e == 0 )
      e = 0;
  end
  endfunction

  reg [20*8-1:0]  roff_s;

  integer ro_s2o_e;
  function [15:0] ro_s2o( input [20*8-1:0] roff_s );
  begin
    ro_s2o_e = $sscanf( roff_s, "0x%x(r%d)", ro_s2o, ra );
    if ( ro_s2o_e == 0 )
      ro_s2o_e = $sscanf( roff_s, "%d(r%d)", ro_s2o, ra );
    if ( ro_s2o_e == 0 )
      e = 0;
  end
  endfunction

  integer ro_s2r_e;
  function [15:0] ro_s2r( input [20*8-1:0] roff_s );
  begin
    ro_s2r_e = $sscanf( roff_s, "0x%x(r%d)", imm, ro_s2r );
    if ( ro_s2r_e == 0 )
      ro_s2r_e = $sscanf( roff_s, "%d(r%d)", imm, ro_s2r );
    if ( ro_s2r_e == 0 )
      e = 0;
  end
  endfunction

  reg [20*8-1:0]  cpr_s;

  integer s2cpr_e;
  function [4:0] s2cpr( input [20*8-1:0] cpr_s );
  begin
    case ( cpr_s )
      "mngr2proc" : s2cpr = `PISA_CPR_MNGR2PROC;
      "proc2mngr" : s2cpr = `PISA_CPR_PROC2MNGR;
      "numcores"  : s2cpr = `PISA_CPR_NUMCORES;
      "coreid"    : s2cpr = `PISA_CPR_COREID;
      "stats_en"  : s2cpr = `PISA_CPR_STATS_EN;
      default     : begin
        // if nothing matches, attemps to read the value from rNum repr
        s2cpr_e = $sscanf( cpr_s, "r%d", s2cpr );
        if ( s2cpr_e == 0 )
          e = 0;
      end
    endcase
  end
  endfunction

  function [`PISA_INST_NBITS-1:0] asm
  (
    input  [31:0]                 pc,
    input  [25*8-1:0]             str
  );
  begin

    e = $sscanf( str, "%s ", inst_str );
    case ( inst_str )

      "mfc0"    : begin e = $sscanf( str, "mfc0  r%d, %s",       ra, cpr_s );       asm = asm_mfc0  ( ra, s2cpr(cpr_s) );                   end
      "mtc0"    : begin e = $sscanf( str, "mtc0  r%d, %s",       ra, cpr_s );       asm = asm_mtc0  ( ra, s2cpr(cpr_s) );                   end
      "nop"     : begin                                                             asm = asm_nop   (0);                                    end

      "addu"    : begin e = $sscanf( str, "addu  r%d, r%d, r%d", ra, rb, rc );      asm = asm_addu  ( ra, rb, rc );                         end
      "subu"    : begin e = $sscanf( str, "subu  r%d, r%d, r%d", ra, rb, rc );      asm = asm_subu  ( ra, rb, rc );                         end
      "and"     : begin e = $sscanf( str, "and   r%d, r%d, r%d", ra, rb, rc );      asm = asm_and   ( ra, rb, rc );                         end
      "or"      : begin e = $sscanf( str, "or    r%d, r%d, r%d", ra, rb, rc );      asm = asm_or    ( ra, rb, rc );                         end
      "xor"     : begin e = $sscanf( str, "xor   r%d, r%d, r%d", ra, rb, rc );      asm = asm_xor   ( ra, rb, rc );                         end
      "nor"     : begin e = $sscanf( str, "nor   r%d, r%d, r%d", ra, rb, rc );      asm = asm_nor   ( ra, rb, rc );                         end
      "slt"     : begin e = $sscanf( str, "slt   r%d, r%d, r%d", ra, rb, rc );      asm = asm_slt   ( ra, rb, rc );                         end
      "sltu"    : begin e = $sscanf( str, "sltu  r%d, r%d, r%d", ra, rb, rc );      asm = asm_sltu  ( ra, rb, rc );                         end

      "addiu"   : begin e = $sscanf( str, "addiu r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_addiu ( ra, rb, s2i_16b(imm_s) );             end
      "andi"    : begin e = $sscanf( str, "andi  r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_andi  ( ra, rb, s2i_16b(imm_s) );             end
      "ori"     : begin e = $sscanf( str, "ori   r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_ori   ( ra, rb, s2i_16b(imm_s) );             end
      "xori"    : begin e = $sscanf( str, "xori  r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_xori  ( ra, rb, s2i_16b(imm_s) );             end
      "slti"    : begin e = $sscanf( str, "slti  r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_slti  ( ra, rb, s2i_16b(imm_s) );             end
      "sltiu"   : begin e = $sscanf( str, "sltiu r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_sltiu ( ra, rb, s2i_16b(imm_s) );             end

      "sll"     : begin e = $sscanf( str, "sll   r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_sll   ( ra, rb, s2i_5b(imm_s) );              end
      "srl"     : begin e = $sscanf( str, "srl   r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_srl   ( ra, rb, s2i_5b(imm_s) );              end
      "sra"     : begin e = $sscanf( str, "sra   r%d, r%d, %s",  ra, rb, imm_s );   asm = asm_sra   ( ra, rb, s2i_5b(imm_s) );              end
      "sllv"    : begin e = $sscanf( str, "sllv  r%d, r%d, r%d", ra, rb, rc );      asm = asm_sllv  ( ra, rb, rc );                         end
      "srlv"    : begin e = $sscanf( str, "srlv  r%d, r%d, r%d", ra, rb, rc );      asm = asm_srlv  ( ra, rb, rc );                         end
      "srav"    : begin e = $sscanf( str, "srav  r%d, r%d, r%d", ra, rb, rc );      asm = asm_srav  ( ra, rb, rc );                         end

      "lui"     : begin e = $sscanf( str, "lui   r%d, %s",       ra, imm_s );       asm = asm_lui   ( ra, s2i_16b(imm_s) );                 end

      "mul"     : begin e = $sscanf( str, "mul   r%d, r%d, r%d", ra, rb, rc );      asm = asm_mul   ( ra, rb, rc );                         end
      "div"     : begin e = $sscanf( str, "div   r%d, r%d, r%d", ra, rb, rc );      asm = asm_div   ( ra, rb, rc );                         end
      "divu"    : begin e = $sscanf( str, "divu  r%d, r%d, r%d", ra, rb, rc );      asm = asm_divu  ( ra, rb, rc );                         end
      "rem"     : begin e = $sscanf( str, "rem   r%d, r%d, r%d", ra, rb, rc );      asm = asm_rem   ( ra, rb, rc );                         end
      "remu"    : begin e = $sscanf( str, "remu  r%d, r%d, r%d", ra, rb, rc );      asm = asm_remu  ( ra, rb, rc );                         end

      "lw"      : begin e = $sscanf( str, "lw    r%d, %s",       ra, roff_s );      asm = asm_lw    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "lh"      : begin e = $sscanf( str, "lh    r%d, %s",       ra, roff_s );      asm = asm_lh    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "lhu"     : begin e = $sscanf( str, "lhu   r%d, %s",       ra, roff_s );      asm = asm_lhu   ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "lb"      : begin e = $sscanf( str, "lb    r%d, %s",       ra, roff_s );      asm = asm_lb    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "lbu"     : begin e = $sscanf( str, "lbu   r%d, %s",       ra, roff_s );      asm = asm_lbu   ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
	  "prelw"	: begin e = $sscanf( str, "prelw r%d, %s",		 ra, roff_s );		asm = asm_prelw ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end

      "sw"      : begin e = $sscanf( str, "sw    r%d, %s",       ra, roff_s );      asm = asm_sw    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "sh"      : begin e = $sscanf( str, "sh    r%d, %s",       ra, roff_s );      asm = asm_sh    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end
      "sb"      : begin e = $sscanf( str, "sb    r%d, %s",       ra, roff_s );      asm = asm_sb    ( ra, ro_s2o(roff_s), ro_s2r(roff_s) ); end

      "j"       : begin e = $sscanf( str, "j     %s",            jtarg_s );         asm = asm_j     ( s2jt(pc,jtarg_s) );                   end
      "jal"     : begin e = $sscanf( str, "jal   %s",            jtarg_s );         asm = asm_jal   ( s2jt(pc,jtarg_s) );                   end
      "jr"      : begin e = $sscanf( str, "jr    r%d",           ra );              asm = asm_jr    ( ra );                                 end
      "jalr"    : begin e = $sscanf( str, "jalr  r%d, r%d",      ra, rb );          asm = asm_jalr  ( ra, rb );                             end

      "beq"     : begin e = $sscanf( str, "beq   r%d, r%d, %s",  ra, rb, btarg_s ); asm = asm_beq   ( ra, rb, s2bt(pc,btarg_s) );           end
      "bne"     : begin e = $sscanf( str, "bne   r%d, r%d, %s",  ra, rb, btarg_s ); asm = asm_bne   ( ra, rb, s2bt(pc,btarg_s) );           end
      "blez"    : begin e = $sscanf( str, "blez  r%d, %s",       ra, btarg_s );     asm = asm_blez  ( ra, s2bt(pc,btarg_s) );               end
      "bgtz"    : begin e = $sscanf( str, "bgtz  r%d, %s",       ra, btarg_s );     asm = asm_bgtz  ( ra, s2bt(pc,btarg_s) );               end
      "bltz"    : begin e = $sscanf( str, "bltz  r%d, %s",       ra, btarg_s );     asm = asm_bltz  ( ra, s2bt(pc,btarg_s) );               end
      "bgez"    : begin e = $sscanf( str, "bgez  r%d, %s",       ra, btarg_s );     asm = asm_bgez  ( ra, s2bt(pc,btarg_s) );               end

      "syscall" : begin                                                             asm = asm_syscall (0);                                  end
      "eret"    : begin                                                             asm = asm_eret  (0);                                    end

      "amo.add" : begin e = $sscanf( str, "amo.add r%d, r%d, r%d", ra, rb, rc );    asm = asm_amo_add ( ra, rb, rc );                       end
      "amo.and" : begin e = $sscanf( str, "amo.and r%d, r%d, r%d", ra, rb, rc );    asm = asm_amo_and ( ra, rb, rc );                       end
      "amo.or"  : begin e = $sscanf( str, "amo.or  r%d, r%d, r%d", ra, rb, rc );    asm = asm_amo_or  ( ra, rb, rc );                       end

	  "intr"	: begin																asm = asm_intr	  (0);									end
	  "setintr" : begin																asm = asm_setintr (0);									end
	  "chmod"	: begin																asm = asm_chmod	  (0);									end
	  "chmempar": begin e = $sscanf( str, "chmempar r%d, %s",	  ra, roff_s );	    asm = asm_chmempar( ra, ro_s2o(roff_s),ro_s2r(roff_s)); end
	  "dirmem"  : begin e = $sscanf( str, "dirmem   r%d, %s",	  ra, roff_s );		asm = asm_dirmem  ( ra, ro_s2o(roff_s),ro_s2r(roff_s));	end
	  "debug"	: begin e = $sscanf( str, "debug	r%d, %s",	  ra, roff_s );		asm = asm_debug	  ( ra, ro_s2o(roff_s),ro_s2r(roff_s)); end

      default    : asm = {`PISA_INST_NBITS{1'bx}};
    endcase

    if ( e == 0 )
      asm = {`PISA_INST_NBITS{1'bx}};

    ra  = 5'bx;
    rb  = 5'bx;
    rc  = 5'bx;
    imm = 16'bx;

  end
  endfunction

  //----------------------------------------------------------------------
  // Disasm
  //----------------------------------------------------------------------

  reg [3*8-1:0]                     rs_str;
  reg [3*8-1:0]                     rt_str;
  reg [3*8-1:0]                     rd_str;

  function [24*8-1:0] disasm( input [`PISA_INST_NBITS-1:0] inst );
  begin

    // Unpack the fields

    opcode   = inst[`PISA_INST_OPCODE];
    rs       = inst[`PISA_INST_RS];
    rt       = inst[`PISA_INST_RT];
    rd       = inst[`PISA_INST_RD];
    shamt    = inst[`PISA_INST_SHAMT];
    func     = inst[`PISA_INST_FUNC];
    imm      = inst[`PISA_INST_IMM];
    target   = inst[`PISA_INST_TARGET];

    // Create fixed-width register specifiers

    if ( rs < 9 )
      $sformat( rs_str, "r0%0d", rs );
    else
      $sformat( rs_str, "r%d",  rs );

    if ( rt < 9 )
      $sformat( rt_str, "r0%0d", rt );
    else
      $sformat( rt_str, "r%d",  rt );

    if ( rd < 9 )
      $sformat( rd_str, "r0%0d", rd );
    else
      $sformat( rd_str, "r%d",  rd );

    // Actual disassembly

    casez ( inst )
      `PISA_INST_MFC0    : $sformat( disasm, "mfc0  %s, %s        ",   rt_str, rd_str );
      `PISA_INST_MTC0    : $sformat( disasm, "mtc0  %s, %s        ",   rt_str, rd_str );
      `PISA_INST_NOP     : $sformat( disasm, "nop                   " );

      `PISA_INST_ADDU    : $sformat( disasm, "addu  %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_SUBU    : $sformat( disasm, "subu  %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_AND     : $sformat( disasm, "and   %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_OR      : $sformat( disasm, "or    %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_XOR     : $sformat( disasm, "xor   %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_NOR     : $sformat( disasm, "nor   %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_SLT     : $sformat( disasm, "slt   %s, %s, %s   ",    rd_str, rs_str, rt_str );
      `PISA_INST_SLTU    : $sformat( disasm, "sltu  %s, %s, %s   ",    rd_str, rs_str, rt_str );

      `PISA_INST_ADDIU   : $sformat( disasm, "addiu %s, %s, 0x%x",     rt_str, rs_str, imm );
      `PISA_INST_ANDI    : $sformat( disasm, "andi  %s, %s, 0x%x",     rt_str, rs_str, imm );
      `PISA_INST_ORI     : $sformat( disasm, "ori   %s, %s, 0x%x",     rt_str, rs_str, imm );
      `PISA_INST_XORI    : $sformat( disasm, "xori  %s, %s, 0x%x",     rt_str, rs_str, imm );
      `PISA_INST_SLTI    : $sformat( disasm, "slti  %s, %s, 0x%x",     rt_str, rs_str, imm );
      `PISA_INST_SLTIU   : $sformat( disasm, "sltiu %s, %s, 0x%x",     rt_str, rs_str, imm );

      `PISA_INST_SLL     : $sformat( disasm, "sll   %s, %s, 0x%x  ",   rd_str, rt_str, shamt );
      `PISA_INST_SRL     : $sformat( disasm, "srl   %s, %s, 0x%x  ",   rd_str, rt_str, shamt );
      `PISA_INST_SRA     : $sformat( disasm, "sra   %s, %s, 0x%x  ",   rd_str, rt_str, shamt );
      `PISA_INST_SLLV    : $sformat( disasm, "sllv  %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_SRLV    : $sformat( disasm, "srlv  %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_SRAV    : $sformat( disasm, "srav  %s, %s, %s   ",    rd_str, rt_str, rs_str );

      `PISA_INST_LUI     : $sformat( disasm, "lui   %s, 0x%x     ",    rt_str, imm );

      `PISA_INST_MUL     : $sformat( disasm, "mul   %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_DIV     : $sformat( disasm, "div   %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_DIVU    : $sformat( disasm, "divu  %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_REM     : $sformat( disasm, "rem   %s, %s, %s   ",    rd_str, rt_str, rs_str );
      `PISA_INST_REMU    : $sformat( disasm, "remu  %s, %s, %s   ",    rd_str, rt_str, rs_str );

      `PISA_INST_LW      : $sformat( disasm, "lw    %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_LH      : $sformat( disasm, "lh    %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_LHU     : $sformat( disasm, "lhu   %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_LB      : $sformat( disasm, "lb    %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_LBU     : $sformat( disasm, "lbu   %s, 0x%x(%s)",     rt_str, imm, rs_str );

      `PISA_INST_SW      : $sformat( disasm, "sw    %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_SH      : $sformat( disasm, "sh    %s, 0x%x(%s)",     rt_str, imm, rs_str );
      `PISA_INST_SB      : $sformat( disasm, "sb    %s, 0x%x(%s)",     rt_str, imm, rs_str );

      `PISA_INST_J       : $sformat( disasm, "j     0x%x       ",      target );
      `PISA_INST_JAL     : $sformat( disasm, "jal   0x%x       ",      target );
      `PISA_INST_JR      : $sformat( disasm, "jr    %s             ",  rs_str );
      `PISA_INST_JALR    : $sformat( disasm, "jalr  %s, %s        ",   rd_str, rs_str );

      `PISA_INST_BEQ     : $sformat( disasm, "beq   %s, %s, 0x%x",     rs_str, rt_str, imm );
      `PISA_INST_BNE     : $sformat( disasm, "bne   %s, %s, 0x%x",     rs_str, rt_str, imm );
      `PISA_INST_BLEZ    : $sformat( disasm, "blez  %s, 0x%x     ",    rs_str, imm );
      `PISA_INST_BGTZ    : $sformat( disasm, "bgtz  %s, 0x%x     ",    rs_str, imm );
      `PISA_INST_BLTZ    : $sformat( disasm, "bltz  %s, 0x%x     ",    rs_str, imm );
      `PISA_INST_BGEZ    : $sformat( disasm, "bgez  %s, 0x%x     ",    rs_str, imm );

      `PISA_INST_SYSCALL : $sformat( disasm, "syscall               " );
      `PISA_INST_ERET    : $sformat( disasm, "eret                  " );

      `PISA_INST_AMO_ADD : $sformat( disasm, "amo.add %s, %s, %s ",    rd_str, rs_str, rt_str );
      `PISA_INST_AMO_AND : $sformat( disasm, "amo.and %s, %s, %s ",    rd_str, rs_str, rt_str );
      `PISA_INST_AMO_OR  : $sformat( disasm, "amo.or  %s, %s, %s ",    rd_str, rs_str, rt_str );

      default            : $sformat( disasm, "illegal inst          " );
    endcase

  end
  endfunction

  //----------------------------------------------------------------------
  // Disasm Tiny
  //----------------------------------------------------------------------

  function [4*8-1:0] disasm_tiny( input [`PISA_INST_NBITS-1:0] inst );
  begin

    casez ( inst )
      `PISA_INST_MFC0    : disasm_tiny = "mfc0";
      `PISA_INST_MTC0    : disasm_tiny = "mtc0";
      `PISA_INST_NOP     : disasm_tiny = "nop ";

      `PISA_INST_ADDU    : disasm_tiny = "addu";
      `PISA_INST_SUBU    : disasm_tiny = "subu";
      `PISA_INST_AND     : disasm_tiny = "and ";
      `PISA_INST_OR      : disasm_tiny = "or  ";
      `PISA_INST_XOR     : disasm_tiny = "xor ";
      `PISA_INST_NOR     : disasm_tiny = "nor ";
      `PISA_INST_SLT     : disasm_tiny = "slt ";
      `PISA_INST_SLTU    : disasm_tiny = "sltu";

      `PISA_INST_ADDIU   : disasm_tiny = "addi";
      `PISA_INST_ANDI    : disasm_tiny = "andi";
      `PISA_INST_ORI     : disasm_tiny = "ori ";
      `PISA_INST_XORI    : disasm_tiny = "xori";
      `PISA_INST_SLTI    : disasm_tiny = "slti";
      `PISA_INST_SLTIU   : disasm_tiny = "sltI";

      `PISA_INST_SLL     : disasm_tiny = "sll ";
      `PISA_INST_SRL     : disasm_tiny = "srl ";
      `PISA_INST_SRA     : disasm_tiny = "sra ";
      `PISA_INST_SLLV    : disasm_tiny = "sllv";
      `PISA_INST_SRLV    : disasm_tiny = "srlv";
      `PISA_INST_SRAV    : disasm_tiny = "srav";

      `PISA_INST_LUI     : disasm_tiny = "lui ";

      `PISA_INST_MUL     : disasm_tiny = "mul ";
      `PISA_INST_DIV     : disasm_tiny = "div ";
      `PISA_INST_DIVU    : disasm_tiny = "divu";
      `PISA_INST_REM     : disasm_tiny = "rem ";
      `PISA_INST_REMU    : disasm_tiny = "remu";

      `PISA_INST_LW      : disasm_tiny = "lw  ";
      `PISA_INST_LH      : disasm_tiny = "lh  ";
      `PISA_INST_LHU     : disasm_tiny = "lhu ";
      `PISA_INST_LB      : disasm_tiny = "lb  ";
      `PISA_INST_LBU     : disasm_tiny = "lbu ";

      `PISA_INST_SW      : disasm_tiny = "sw  ";
      `PISA_INST_SH      : disasm_tiny = "sh  ";
      `PISA_INST_SB      : disasm_tiny = "sb  ";

      `PISA_INST_J       : disasm_tiny = "j   ";
      `PISA_INST_JAL     : disasm_tiny = "jal ";
      `PISA_INST_JR      : disasm_tiny = "jr  ";
      `PISA_INST_JALR    : disasm_tiny = "jalr";

      `PISA_INST_BEQ     : disasm_tiny = "beq ";
      `PISA_INST_BNE     : disasm_tiny = "bne ";
      `PISA_INST_BLEZ    : disasm_tiny = "blez";
      `PISA_INST_BGTZ    : disasm_tiny = "bgtz";
      `PISA_INST_BLTZ    : disasm_tiny = "bltz";
      `PISA_INST_BGEZ    : disasm_tiny = "bgez";

      `PISA_INST_SYSCALL : disasm_tiny = "sysc";
      `PISA_INST_ERET    : disasm_tiny = "eret";

      `PISA_INST_AMO_ADD : disasm_tiny = "a.ad";
      `PISA_INST_AMO_AND : disasm_tiny = "a.an";
      `PISA_INST_AMO_OR  : disasm_tiny = "a.or";

      default            : disasm_tiny = "????";
    endcase

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

//------------------------------------------------------------------------
// Convert message to string
//------------------------------------------------------------------------

module pisa_InstTrace
(
  input                        clk,
  input                        reset,
  input [`PISA_INST_NBITS-1:0] inst
);

  `include "vc-trace-tasks.v"

  pisa_InstTasks pisa();

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    vc_trace_str( trace, pisa.disasm( inst ) );
    vc_trace_str( trace, " | " );
    vc_trace_str( trace, pisa.disasm_tiny( inst ) );
  end
  endtask

endmodule

`endif /* PISA_INST_V */
