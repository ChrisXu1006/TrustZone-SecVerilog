//=========================================================================
// 5-Stage Bypass Pipelined Processor Datapath
//=========================================================================

`ifndef PLAB2_PROC_PIPELINED_PROC_DYNAMIC_DPATH_V
`define PLAB2_PROC_PIPELINED_PROC_DYNAMIC_DPATH_V

`include "plab2-proc-dpath-components.v"
`include "vc-arithmetic.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "pisa-inst.v"
`include "plab1-imul-msgs.v"
`include "plab1-imul-IntMulVarLat.v"

module plab2_proc_PipelinedProcDynamicDpath
#(
  parameter p_num_cores = 1,
  parameter p_core_id   = 0,
  parameter c_reset_vector = 32'h1000
)
(
  input     {L} clk,
  input     {L} reset,

  input     {L} domain,
  // Instruction Memory Port

  output [31:0] {Ctrl domain} imemreq_msg_addr,
  input  [31:0] {Data domain} imemresp_msg_data,

  // Data Memory Port

  output [31:0] {Ctrl domain} dmemreq_msg_addr,
  output [31:0] {Data domain} dmemreq_msg_data,
  input  [31:0] {Data domain} dmemresp_msg_data,

  // mngr communication ports

  input  [31:0] {Data domain} from_mngr_data,
  output [31:0] {Data domain} to_mngr_data,

  // imul unit ports

  input         {Ctrl domain} mul_req_val_D,
  output        {Ctrl domain} mul_req_rdy_D,

  output        {Ctrl domain} mul_resp_val_X,
  input         {Ctrl domain} mul_resp_rdy_X,

  // control signals (ctrl->dpath)

  input [1:0]   {Ctrl domain} pc_sel_F,
  input         {Ctrl domain} reg_en_F,
  input         {Ctrl domain} reg_en_D,
  input         {Ctrl domain} reg_en_X,
  input         {Ctrl domain} reg_en_M,
  input         {Ctrl domain} reg_en_W,
  input [1:0]   {Ctrl domain} op0_sel_D,
  input [2:0]   {Ctrl domain} op1_sel_D,
  input [1:0]   {Ctrl domain} op0_byp_sel_D,
  input [1:0]   {Ctrl domain} op1_byp_sel_D,
  input [1:0]   {Ctrl domain} mfc_sel_D,
  input [3:0]   {Ctrl domain} alu_fn_X,
  input         {Ctrl domain} ex_result_sel_X,
  input         {Ctrl domain} wb_result_sel_M,
  input [4:0]   {Ctrl domain} rf_waddr_W,
  input         {Ctrl domain} rf_wen_W,
  input         {Ctrl domain} stats_en_wen_W,

  // status signals (dpath->ctrl)

  output [31:0] {Data domain} inst_D,
  output        {Ctrl domain} br_cond_zero_X,
  output        {Ctrl domain} br_cond_neg_X,
  output        {Ctrl domain} br_cond_eq_X,

  // stats_en output

  output        {Ctrl domain} stats_en
);
	
  localparam c_reset_inst   = 32'h00000000;

  //--------------------------------------------------------------------
  // F stage
  //--------------------------------------------------------------------

  wire [31:0] {Data domain} pc_F;
  wire [31:0] {Data domain} pc_next_F;
  wire [31:0] {Data domain} pc_plus4_F;
  wire [31:0] {Data domain} pc_plus4_next_F;
  wire [31:0] {Data domain} br_target_X;
  wire [31:0] {Data domain} j_target_D;
  wire [31:0] {Data domain} jr_target_D;

  vc_EnResetReg #(32, c_reset_vector) pc_plus4_reg_F
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_F),
    .d      (pc_plus4_next_F),
    .q      (pc_plus4_F)
  );

  vc_Incrementer #(32, 4) pc_incr_F
  (
    .domain (domain),
    .in     (pc_next_F),
    .out    (pc_plus4_next_F)
  );

  vc_Mux4 #(32) pc_sel_mux_F
  (
    .domain (domain),
    .in0    (pc_plus4_F),
    .in1    (br_target_X),
    .in2    (j_target_D),
    .in3    (jr_target_D),
    .sel    (pc_sel_F),
    .out    (pc_next_F)
  );

  assign imemreq_msg_addr = pc_next_F;

  // note: we don't need pc_F except to draw the line tracing

  vc_EnResetReg #(32) pc_reg_F
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_F),
    .d      (pc_next_F),
    .q      (pc_F)
  );

  //--------------------------------------------------------------------
  // D stage
  //--------------------------------------------------------------------

  wire  [31:0] {Data domain} pc_plus4_D;
  wire  [31:0] {Data domain} inst_D;
  wire   [5:0] {Data domain} inst_op_D;
  wire   [4:0] {Data domain} inst_rs_D;
  wire   [4:0] {Data domain} inst_rt_D;
  wire   [4:0] {Data domain} inst_rd_D;
  wire   [4:0] {Data domain} inst_shamt_D;
  wire  [31:0] {Data domain} inst_shamt_zext_D;
  wire   [5:0] {Data domain} inst_func_D;
  wire  [15:0] {Data domain} inst_imm_D;
  wire  [31:0] {Data domain} inst_imm_sext_D;
  wire  [31:0] {Data domain} inst_imm_zext_D;
  wire  [25:0] {Data domain} inst_target_D;

  vc_EnResetReg #(32) pc_plus4_reg_D
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_D),
    .d      (pc_plus4_F),
    .q      (pc_plus4_D)
  );

  vc_EnResetReg #(32, c_reset_inst) inst_D_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_D),
    .d      (imemresp_msg_data),
    .q      (inst_D)
  );

  pisa_InstUnpack inst_unpack
  (
    .domain   (domain),
    .inst     (inst_D),
    .opcode   (inst_op_D),
    .rs       (inst_rs_D),
    .rt       (inst_rt_D),
    .rd       (inst_rd_D),
    .shamt    (inst_shamt_D),
    .func     (inst_func_D),
    .imm      (inst_imm_D),
    .target   (inst_target_D)
  );

  wire [ 4:0] {Data domain} rf_raddr0_D = inst_rs_D;
  wire [31:0] {Data domain} rf_rdata0_D;
  wire [ 4:0] {Data domain} rf_raddr1_D = inst_rt_D;
  wire [31:0] {Data domain} rf_rdata1_D;

  plab2_proc_Regfile rfile
  (
    .clk         (clk),
    .reset       (reset),
    .domain      (domain),
    .read_addr0  (rf_raddr0_D),
    .read_data0  (rf_rdata0_D),
    .read_addr1  (rf_raddr1_D),
    .read_data1  (rf_rdata1_D),
    .write_en    (rf_wen_W),
    .write_addr  (rf_waddr_W),
    .write_data  (rf_wdata_W)
  );

  wire [31:0] {Data domain} op0_D;
  wire [31:0] {Data domain} op1_D;

  vc_ZeroExtender #(5, 32) shamt_zext_D
  (
    .domain (domain),
    .in     (inst_shamt_D),
    .out    (inst_shamt_zext_D)
  );

  wire [31:0] {Data domain} op0_byp_out_D;
  wire [31:0] {Data domain} byp_data_X;
  wire [31:0] {Data domain} byp_data_M;
  wire [31:0] {Data domain} byp_data_W;

  vc_Mux4 #(32) op0_byp_mux_D
  (
    .domain (domain),
    .in0    (rf_rdata0_D),
    .in1    (byp_data_X),
    .in2    (byp_data_M),
    .in3    (byp_data_W),
    .sel    (op0_byp_sel_D),
    .out    (op0_byp_out_D)
  );

  vc_Mux3 #(32) op0_sel_mux_D
  (
    .domain (domain),
    .in0    (op0_byp_out_D),
    .in1    (inst_shamt_zext_D),
    .in2    (32'd16),
    .sel    (op0_sel_D),
    .out    (op0_D)
  );

  assign jr_target_D = op0_byp_out_D;

  vc_SignExtender #(16, 32) imm_sext_D
  (
    .domain (domain),
    .in     (inst_imm_D),
    .out    (inst_imm_sext_D)
  );

  vc_ZeroExtender #(16, 32) imm_zext_D
  (
    .domain (domain),
    .in     (inst_imm_D),
    .out    (inst_imm_zext_D)
  );

  wire [31:0] {Data domain} op1_byp_out_D;
  wire [31:0] {Data domain} op1_byp_data_X;
  wire [31:0] {Data domain} op1_byp_data_M;
  wire [31:0] {Data domain} op1_byp_data_W;

  vc_Mux4 #(32) op1_byp_mux_D
  (
    .domain (domain),
    .in0    (rf_rdata1_D),
    .in1    (byp_data_X),
    .in2    (byp_data_M),
    .in3    (byp_data_W),
    .sel    (op1_byp_sel_D),
    .out    (op1_byp_out_D)
  );

  wire [31:0] {Data domain} mfc_data_D;

  vc_Mux5 #(32) op1_sel_mux_D
  (
    .domain (domain),
    .in0    (op1_byp_out_D),
    .in1    (inst_imm_sext_D),
    .in2    (inst_imm_zext_D),
    .in3    (pc_plus4_D),
    .in4    (mfc_data_D),
    .sel    (op1_sel_D),
    .out    (op1_D)
  );

  vc_Mux3 #(32) mfc_sel_mux_D
  (
    .domain (domain),
    .in0    (from_mngr_data),
    .in1    (p_num_cores),
    .in2    (p_core_id),
    .sel    (mfc_sel_D),
    .out    (mfc_data_D)
  );

  wire [31:0] {Data domain} br_target_D;

  plab2_proc_BrTarget br_target_calc_D
  (
    .domain    (domain),
    .pc_plus4  (pc_plus4_D),
    .imm_sext  (inst_imm_sext_D),
    .br_target (br_target_D)
  );

  plab2_proc_JTarget j_target_calc_D
  (
    .domain     (domain),
    .pc_plus4   (pc_plus4_D),
    .imm_target (inst_target_D),
    .j_target   (j_target_D)
  );

  wire [31:0] {Data domain} dmem_write_data_D;

  assign dmem_write_data_D = op1_byp_out_D;

  // the multiply unit

  wire [`PLAB1_IMUL_MULDIV_REQ_MSG_NBITS-1:0] {Data domain} mul_req_msg_D;
  wire [31:0]                                 {Data domain} mul_resp_msg_X;

  plab1_imul_IntMulVarLat imul
  (
    .clk      (clk),
    .reset    (reset),

    .domain   (domain),

    .in_val   (mul_req_val_D),
    .in_rdy   (mul_req_rdy_D),
    .in_msg   (mul_req_msg_D),

    .out_val  (mul_resp_val_X),
    .out_rdy  (mul_resp_rdy_X),
    .out_msg  (mul_resp_msg_X)
  );

  plab1_imul_MulDivReqMsgPack mul_req_msg_pack
  (
    .domain (domain),
    .func   (`PLAB1_IMUL_MULDIV_REQ_MSG_FUNC_MUL),
    .a      (op0_D),
    .b      (op1_D),

    .msg    (mul_req_msg_D)
  );

  //--------------------------------------------------------------------
  // X stage
  //--------------------------------------------------------------------

  wire [31:0] {Data domain} op0_X;
  wire [31:0] {Data domain} op1_X;

  vc_EnResetReg #(32, 0) op0_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_X),
    .d      (op0_D),
    .q      (op0_X)
  );

  vc_EnResetReg #(32, 0) op1_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_X),
    .d      (op1_D),
    .q      (op1_X)
  );


  vc_EnResetReg #(32, 0) br_target_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_X),
    .d      (br_target_D),
    .q      (br_target_X)
  );


  vc_EqComparator #(32) br_cond_eq_comp_X
  (
    .domain (domain),
    .in0  (op0_X),
    .in1  (op1_X),
    .out  (br_cond_eq_X)
  );

  vc_ZeroComparator #(32) br_cond_zero_comp_X
  (
    .domain (domain),
    .in     (op0_X),
    .out    (br_cond_zero_X)
  );

  vc_EqComparator #(1) br_cond_neg_comp_X
  (
    .domain (domain),
    .in0    (op0_X[31]),
    .in1    (1'b1),
    .out    (br_cond_neg_X)
  );

  wire [31:0] {Data domain} alu_result_X;
  wire [31:0] {Data domain} ex_result_X;

  plab2_proc_Alu alu
  (
    .domain (domain),
    .in0    (op0_X),
    .in1    (op1_X),
    .fn     (alu_fn_X),
    .out    (alu_result_X)
  );

  vc_Mux2 #(32) ex_result_sel_mux_X
  (
    .domain (domain),
    .in0    (alu_result_X),
    .in1    (mul_resp_msg_X),
    .sel    (ex_result_sel_X),
    .out    (ex_result_X)
  );

  wire [31:0] {Data domain} dmem_write_data_X;

  // this is the bypassing data from x
  assign byp_data_X = ex_result_X;

  vc_EnResetReg #(32, 0) dmem_write_data_reg_X
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_X),
    .d      (dmem_write_data_D),
    .q      (dmem_write_data_X)
  );

  assign dmemreq_msg_addr = alu_result_X;
  assign dmemreq_msg_data = dmem_write_data_X;

  //--------------------------------------------------------------------
  // M stage
  //--------------------------------------------------------------------

  wire [31:0] {Data domain} ex_result_M;

  vc_EnResetReg #(32, 0) ex_result_reg_M
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_M),
    .d      (ex_result_X),
    .q      (ex_result_M)
  );

  wire [31:0] {Data domain} dmem_result_M;
  wire [31:0] {Data domain} wb_result_M;

  assign dmem_result_M = dmemresp_msg_data;

  vc_Mux2 #(32) wb_result_sel_mux_M
  (
    .domain (domain),
    .in0    (ex_result_M),
    .in1    (dmem_result_M),
    .sel    (wb_result_sel_M),
    .out    (wb_result_M)
  );

  // this is the bypassing data from m
  assign byp_data_M = wb_result_M;

  //--------------------------------------------------------------------
  // W stage
  //--------------------------------------------------------------------

  wire [31:0] {Data domain} wb_result_W;

  vc_EnResetReg #(32, 0) wb_result_reg_W
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (reg_en_W),
    .d      (wb_result_M),
    .q      (wb_result_W)
  );

  assign to_mngr_data = wb_result_W;

  // this is the bypassing data from m
  assign byp_data_W = wb_result_W;

  wire [31:0] {Data domain} rf_wdata_W = wb_result_W;

  // stats output

  // note the stats en is full 32-bit here but the outside port is one
  // bit.
  wire [31:0] {Data domain} stats_en_W;

  assign stats_en = | stats_en_W;

  vc_EnResetReg #(32, 0) stats_en_reg_W
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (stats_en_wen_W),
    .d      (wb_result_W),
    .q      (stats_en_W)
  );

endmodule

`endif

