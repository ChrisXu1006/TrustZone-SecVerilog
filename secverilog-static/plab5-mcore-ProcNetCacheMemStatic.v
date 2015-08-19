//========================================================================
// 2-Cores Processor-Network-Cache-Memory
//========================================================================

`ifndef PLAB5_MCORE_PROC_NET_CACHE_MEM_V
`define PLAB5_MCORE_PROC_NET_CACHE_MEM_V
`define PLAB4_NET_NUM_PORTS_2

`include "vc-mem-msgs.v"
`include "plab2-proc-PipelinedProcBypass.v"
`include "plab2-proc-PIC.v"
`include "plab3-mem-BlockingL1Cache.v"
`include "plab3-mem-BlockingL2Cache-Top.v"
`include "plab5-mcore-define.v"
`include "plab5-mcore-proc-acc.v"
`include "plab5-mcore-proc-acc-insecure.v"
`include "plab5-mcore-DMA-checker.v"
`include "plab5-mcore-Debug-checker.v"
`include "plab5-mcore-DMA-controller.v"
`include "plab5-mcore-Debug-Interface.v"
`include "plab5-mcore-mem-arbiter.v"
`include "plab5-mcore-mem-acc-ctrl.v"
`include "plab5-mcore-MemNet"
`include "plab5-mcore-MainMem.v"

module plab5_mcore_ProcNetCacheMem
#(
	parameter	p_mem_nbytes  = 1 << 16,
	parameter	p_l1_inst_nbytes = 256,		// L1 Cache Size
	parameter	p_l1_data_nbytes = 256,
	parameter   p_l2_inst_nbytes = 1024,	// L2 Cache Size
	parameter   p_l2_data_nbytes = 1024,

	parameter	p_num_cores	= 2,

	// local params not meant to be set from outside
	
	parameter	c_opaque_nbits	= 8,
	parameter	c_addr_nbits	= 32,
	parameter	c_data_nbits	= 32,
	parameter	c_memline_nbits	= 128,

	// short name for local params, more convenient for following code
	parameter	o	= c_opaque_nbits,
	parameter	a	= c_addr_nbits,
	parameter	d	= c_data_nbits,
	parameter	l	= c_memline_nbits

)
(
	input	{L} clk,
	input	{L} reset,

	input	{L} mem_clear,

	// proc0 manager ports
	
	input	[31:0]	{D1} proc0_from_mngr_msg,
	input			{L}  proc0_from_mngr_val,
	output			{L}  proc0_from_mngr_rdy,

	output	[31:0]	{D1} proc0_to_mngr_msg,
	output			{L}  proc0_to_mngr_val,
	input			{L}  proc0_to_mngr_rdy,

	output			{L}  stats_en_proc0,

	// proc1 manager ports
	
	input	[31:0]	{D2} proc1_from_mngr_msg,
	input			{L}  proc1_from_mngr_val,
	output			{L}  proc1_from_mngr_rdy,

	output	[31:0]	{D2} proc1_to_mngr_msg,
	output			{L}  proc1_to_mngr_val,
	input			{L}  proc1_to_mngr_rdy,

	output			{L} stats_en_proc1

);

	// processor message sizes
	
	localparam c_procreq_nbits	= `VC_MEM_REQ_MSG_NBITS(o,a,d);
	localparam c_procresp_nbits	= `VC_MEM_RESP_MSG_NBITS(o,d);

	// short name for the memory message sizes
	
	localparam prq	= c_procreq_nbits;
	localparam prs	= c_procresp_nbits;

	localparam crq	= `VC_MEM_REQ_MSG_NBITS(o,a,d);
	localparam crqc = `VC_MEM_REQ_MSG_NBITS(o,a,d) - d;
	localparam crqd = d;
	localparam crs	= `VC_MEM_RESP_MSG_NBITS(o,d);
	localparam crsc = `VC_MEM_RESP_MSG_NBITS(o,d) - d;
	localparam crsd = d;

	localparam mrq	= `VC_MEM_REQ_MSG_NBITS(o,a,l);
	localparam mrqc	= `VC_MEM_REQ_MSG_NBITS(o,a,l) - l;
	localparam mrqd	= l;
	localparam mrs	= `VC_MEM_RESP_MSG_NBITS(o,l);
	localparam mrsc	= `VC_MEM_RESP_MSG_NBITS(o,l) - l;
	localparam mrsd	= l;

	// define processor name
	
	`define PLAB5_MCORE_PROC0 proc0
	`define PLAB5_MCORE_PROC1 proc1

	// define processor wires
	
	// wires connected to processor0
	
	wire	[prq-1:0]	{D1} inst_cache_req_msg_p0;
	wire		        {L}  inst_cache_req_val_p0;
	wire				{L}  inst_cache_req_rdy_p0;

	wire	[prs-1:0]	{D1} inst_cache_resp_msg_p0;
	wire				{L}  inst_cache_resp_val_p0;
	wire				{L}  inst_cache_resp_rdy_p0;

	wire	[prq-1:0]	{D1} data_cache_req_msg_p0;
	wire				{L}  data_cache_req_val_p0;
	wire				{L}  data_cache_req_rdy_p0;

	wire	[prs-1:0]	{D1} data_cache_resp_msg_p0;
	wire				{L}  data_cache_resp_val_p0;
	wire				{L}  data_cache_resp_rdy_p0;

	wire				{D1} cacheable_p0;
	wire				{L}  req_in_domain_d0;
	
	wire				{L}  intr_rq_p0;
	wire				{L}  intr_set_p0;
	wire				{L}  intr_ack_p0;
	wire				{L}  intr_val_p0;

	wire	[prq-1:0]	{D1} debug_msg_p0;
	wire				{L}  debug_val_p0;
	wire				{L}  debug_rdy_p0;

	// wires connected to processor1
	
	wire	[prq-1:0]	{D2} inst_cache_req_msg_p1;
	wire				{L}  inst_cache_req_val_p1;
	wire				{L}  inst_cache_req_rdy_p1;

	wire	[prs-1:0]	{D2} inst_cache_resp_msg_p1;
	wire				{L}  inst_cache_resp_val_p1;
	wire				{L}  inst_cache_resp_rdy_p1;

	wire	[prq-1:0]	{D2} data_cache_req_msg_p1;
	wire				{L}  data_cache_req_val_p1;
	wire				{L}  data_cache_req_rdy_p1;

	wire	[prs-1:0]	{D2} data_cache_resp_msg_p1;
	wire				{L}  data_cache_resp_val_p1;
	wire				{L}  data_cache_resp_rdy_p1;

	wire				{D2} cacheable_p1;
	wire				{L}  req_in_domain_d1;
	
	wire				{L}  intr_rq_p1;
	wire				{L}  intr_set_p1;
	wire				{L}  intr_ack_p1;
	wire				{L}  intr_val_p1;

	wire	[prq-1:0]	{D2} debug_msg_p1;
	wire				{L}  debug_val_p1;
	wire				{L}  debug_rdy_p1;

	// Processor module claim
	
	plab2_proc_PipelinedProcBypass
	#(
		.p_num_cores	(p_num_cores),
		.p_core_id		(0),
		.c_reset_vector	(32'h1000)
	)
	proc0
	(
		.clk			(clk),
		.reset			(reset),

		.sec_domain		(1'b0),
		.req_domain		(req_in_domain_d0),

		.imemreq_msg	(inst_cache_req_msg_p0),
		.imemreq_val	(inst_cache_req_val_p0),
		.imemreq_rdy	(inst_cache_req_rdy_p0),

		.imemresp_msg	(inst_cache_resp_msg_p0),
		.imemresp_val	(inst_cache_resp_val_p0),
		.imemresp_rdy	(inst_cache_resp_rdy_p0),

		.dmemreq_msg	(data_cache_req_msg_p0),
		.dmemreq_val	(data_cache_req_val_p0),
		.dmemreq_rdy	(data_cache_req_rdy_p0),

		.dmemresp_msg	(data_cache_resp_msg_p0),
		.dmemresp_val	(data_cache_resp_val_p0),
		.dmemresp_rdy	(data_cache_resp_rdy_p0),

		.debug_msg		(debug_msg_p0),
		.debug_val		(debug_val_p0),
		.debug_rdy		(debug_rdy_p0),

		.from_mngr_msg	(proc0_from_mngr_msg),
		.from_mngr_val	(proc0_from_mngr_val),
		.from_mngr_rdy	(proc0_from_mngr_rdy),

		.to_mngr_msg	(proc0_to_mngr_msg),
		.to_mngr_val	(proc0_to_mngr_val),
		.to_mngr_rdy	(proc0_to_mngr_rdy),

		.stats_en		(stats_en_proc0)
	);

	plab2_proc_PipelinedProcBypass
	#(
		.p_num_cores	(p_num_cores),
		.p_core_id		(1),
		.c_reset_vector	(32'h2000)
	)
	proc1
	(
		.clk			(clk),
		.reset			(reset),

		.sec_domain		(1'b1),
		.req_domain		(req_in_domain_d1),

		.imemreq_msg	(inst_cache_req_msg_p1),
		.imemreq_val	(inst_cache_req_val_p1),
		.imemreq_rdy	(inst_cache_req_rdy_p1),

		.imemresp_msg	(inst_cache_resp_msg_p1),
		.imemresp_val	(inst_cache_resp_val_p1),
		.imemresp_rdy	(inst_cache_resp_rdy_p1),

		.dmemreq_msg	(data_cache_req_msg_p1),
		.dmemreq_val	(data_cache_req_val_p1),
		.dmemreq_rdy	(data_cache_req_rdy_p1),

		.dmemresp_msg	(data_cache_resp_msg_p1),
		.dmemresp_val	(data_cache_resp_val_p1),
		.dmemresp_rdy	(data_cache_resp_rdy_p1),

		.debug_msg		(debug_msg_p1),
		.debug_val		(debug_val_p1),
		.debug_rdy		(debug_rdy_p1),

		.from_mngr_msg	(proc1_from_mngr_msg),
		.from_mngr_val	(proc1_from_mngr_val),
		.from_mngr_rdy	(proc1_from_mngr_rdy),

		.to_mngr_msg	(proc1_to_mngr_msg),
		.to_mngr_val	(proc1_to_mngr_val),
		.to_mngr_rdy	(proc1_to_mngr_rdy),

		.stats_en		(stats_en_proc1)
	);

	// Declare private cache wires  
	
	wire [mrq-1:0]		{D1} inst_net_req_in_msg_proc_d0;
	wire				{L}  inst_net_req_in_val_d0;
	wire				{L}  inst_net_req_in_rdy_d0;

	wire [mrs-1:0]		{D1} inst_proc_resp_out_msg_proc_d0;
	wire			    {L}  inst_proc_resp_out_val_d0;
	wire				{L}  inst_proc_resp_out_rdy_d0;	
	wire				{L}  inst_proc_resp_out_fail_d0;

	wire [mrq-1:0]		{D2} inst_net_req_in_msg_proc_d1;
	wire				{L}  inst_net_req_in_val_d1;
	wire				{L}  inst_net_req_in_rdy_d1;

	wire [mrs-1:0]		{D2} inst_proc_resp_out_msg_proc_d1;
	wire				{L}  inst_proc_resp_out_val_d1;
	wire				{L}  inst_proc_resp_out_rdy_d1;
	wire				{L}  inst_proc_resp_out_fail_d1;

	wire [mrq-1:0]		{D1} data_net_req_in_msg_proc_d0;
	wire				{L}  data_net_req_in_val_d0;
	wire				{L}  data_net_req_in_rdy_d0;

	wire [mrs-1:0]		{D1} data_proc_resp_out_msg_proc_d0;
	wire				{L}  data_proc_resp_out_val_d0;
	wire				{L}  data_proc_resp_out_rdy_d0;
	wire				{L}  data_proc_resp_out_fail_d0;

	wire [mrq-1:0]		{D2} data_net_req_in_msg_proc_d1;
	wire				{L}  data_net_req_in_val_d1;
	wire				{L}  data_net_req_in_rdy_d1;

	wire [mrs-1:0]		{D2} data_proc_resp_out_msg_proc_d1;
	wire				{L}  data_proc_resp_out_val_d1;
	wire				{L}  data_proc_resp_out_rdy_d1;
	wire				{L}  data_proc_resp_out_fail_d1;

	// private instruction cache for processor0
	
	plab3_mem_BlockingL1Cache
	#(
		.p_mem_nbytes	(p_l1_inst_nbytes),
		.p_num_banks	(1),
		.p_opaque_nbits (o)
	)
	inst_l1cache_p0
	(
		.clk			(clk),
		.reset			(reset),

        .domain         (0),

		.cachereq_msg	(inst_cache_req_msg_p0),
		.cachereq_val	(inst_cache_req_val_p0),
		.cachereq_rdy	(inst_cache_req_rdy_p0),

		.cacheresp_msg	(inst_cache_resp_msg_p0),
		.cacheresp_val	(inst_cache_resp_val_p0),
		.cacheresp_rdy	(inst_cache_resp_rdy_p0),

		.memreq_msg		(inst_net_req_in_msg_proc_d0),
		.memreq_val		(inst_net_req_in_val_d0),
		.memreq_rdy		(inst_net_req_in_rdy_d0),

		.fail			(inst_proc_resp_out_fail_d0),
		.memresp_msg	(inst_proc_resp_out_msg_proc_d0),
		.memresp_val	(inst_proc_resp_out_val_d0),
		.memresp_rdy	(inst_proc_resp_out_rdy_d0)
	);

	// private instruction cache for processor1
	
	plab3_mem_BlockingL1Cache
	#(
		.p_mem_nbytes	(p_l1_inst_nbytes),
		.p_num_banks	(1),
		.p_opaque_nbits	(o)
	)
	inst_l1cache_p1
	(
		.clk			(clk),
		.reset			(reset),

        .domain         (1),

		.cachereq_msg	(inst_cache_req_msg_p1),
		.cachereq_val	(inst_cache_req_val_p1),
		.cachereq_rdy	(inst_cache_req_rdy_p1),

		.cacheresp_msg	(inst_cache_resp_msg_p1),
		.cacheresp_val	(inst_cache_resp_val_p1),
		.cacheresp_rdy	(inst_cache_resp_rdy_p1),

		.memreq_msg		(inst_net_req_in_msg_proc_d1),
		.memreq_val		(inst_net_req_in_val_d1),
		.memreq_rdy		(inst_net_req_in_rdy_d1),

		.fail			(inst_proc_resp_out_fail_d1),
		.memresp_msg	(inst_proc_resp_out_msg_proc_d1),
		.memresp_val	(inst_proc_resp_out_val_d1),
		.memresp_rdy	(inst_proc_resp_out_rdy_d1)
	);

	// private data cache for processor0
	
	plab3_mem_BlockingL1Cache
	#(
		.p_mem_nbytes	(p_l1_data_nbytes),
		.p_num_banks	(1),
		.p_opaque_nbits	(o)
	)
	data_l1cache_p0
	(
		.clk			(clk),
		.reset			(reset),

        .domain         (0),

		.cachereq_msg	(data_cache_req_msg_p0),
		.cachereq_val	(data_cache_req_val_p0),
		.cachereq_rdy	(data_cache_req_rdy_p0),

		.cacheresp_msg	(data_cache_resp_msg_p0),
		.cacheresp_val	(data_cache_resp_val_p0),
		.cacheresp_rdy	(data_cache_resp_rdy_p0),

		.memreq_msg		(data_net_req_in_msg_proc_d0),
		.memreq_val		(data_net_req_in_val_d0),
		.memreq_rdy		(data_net_req_in_rdy_d0),

		.fail			(data_proc_resp_out_fail_d0),
		.memresp_msg	(data_proc_resp_out_msg_proc_d0),
		.memresp_val	(data_proc_resp_out_val_d0),
		.memresp_rdy	(data_proc_resp_out_rdy_d0)
	);

	// private data cache for processor1
	
	plab3_mem_BlockingL1Cache
	#(
		.p_mem_nbytes	(p_l1_data_nbytes),
		.p_num_banks	(1),
		.p_opaque_nbits	(o)
	)
	data_l1cache_p1
	(
		.clk			(clk),
		.reset			(reset),

        .domain         (1),

		.cachereq_msg	(data_cache_req_msg_p1),
		.cachereq_val	(data_cache_req_val_p1),
		.cachereq_rdy	(data_cache_req_rdy_p1),

		.cacheresp_msg	(data_cache_resp_msg_p1),
		.cacheresp_val	(data_cache_resp_val_p1),
		.cacheresp_rdy	(data_cache_resp_rdy_p1),

		.memreq_msg		(data_net_req_in_msg_proc_d1),
		.memreq_val		(data_net_req_in_val_d1),
		.memreq_rdy		(data_net_req_in_rdy_d1),

		.fail			(data_proc_resp_out_fail_d1),
		.memresp_msg	(data_proc_resp_out_msg_proc_d1),
		.memresp_val	(data_proc_resp_out_val_d1),
		.memresp_rdy	(data_proc_resp_out_rdy_d1)
	);

	// network wires
	wire   {L} inst_net_resp_out_domain_d0;
	wire   {L} inst_net_resp_out_domain_d1;
	wire   {L} data_net_resp_out_domain_d0;
	wire   {L} data_net_resp_out_domain_d1;

	wire [mrs-1:0]	{Data inst_net_resp_out_domain_d0} inst_net_resp_out_msg_proc_d0;
	wire			{Ctrl inst_net_resp_out_domain_d0} inst_net_resp_out_val_d0;
	wire			{Ctrl inst_net_resp_out_domain_d0} inst_net_resp_out_rdy_d0;
	wire			{Ctrl inst_net_resp_out_domain_d0} inst_net_resp_out_fail_d0;

	wire [mrs-1:0]	{Data inst_net_resp_out_domain_d1} inst_net_resp_out_msg_proc_d1;
	wire			{Ctrl inst_net_resp_out_domain_d1} inst_net_resp_out_val_d1;
	wire			{Ctrl inst_net_resp_out_domain_d1} inst_net_resp_out_rdy_d1;
	wire			{Ctrl inst_net_resp_out_domain_d1} inst_net_resp_out_fail_d1;

	wire [mrs-1:0]	{Data data_net_resp_out_domain_d0} data_net_resp_out_msg_proc_d0;
	wire			{Ctrl data_net_resp_out_domain_d0} data_net_resp_out_val_d0;
	wire			{Ctrl data_net_resp_out_domain_d0} data_net_resp_out_rdy_d0;
	wire			{Ctrl data_net_resp_out_domain_d0} data_net_resp_out_fail_d0;

	wire [mrs-1:0]	{Data data_net_resp_out_domain_d1} data_net_resp_out_msg_proc_d1;
	wire			{Ctrl data_net_resp_out_domain_d1} data_net_resp_out_val_d1;
	wire			{Ctrl data_net_resp_out_domain_d1} data_net_resp_out_rdy_d1;
	wire			{Ctrl data_net_resp_out_domain_d1} data_net_resp_out_fail_d1;

	// processor0 instruction response access control
	`ifdef PROC_ACC_SECURE
		plab5_mcore_proc_resp_acc
	`elsif PROC_ACC_INSECURE
		plab5_mcore_proc_resp_acc_insecure
	`endif
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	inst_resp_acc_p0
	(
		.clk				(clk),
		.resp_sec_level		(inst_net_resp_out_domain_d0),
		.proc_sec_level		(0),

		.net_resp_val		(inst_net_resp_out_val_d0),
		.net_resp_rdy		(inst_net_resp_out_rdy_d0),
		.net_resp_msg		(inst_net_resp_out_msg_proc_d0),
		.net_resp_fail		(inst_net_resp_out_fail_d0),

		.proc_resp_val		(inst_proc_resp_out_val_d0),
		.proc_resp_rdy		(inst_proc_resp_out_rdy_d0),
		.proc_resp_msg		(inst_proc_resp_out_msg_proc_d0),
		.proc_resp_fail		(inst_proc_resp_out_fail_d0)
	);

	// processor1 instruction response access control
	`ifdef PROC_ACC_SECURE
		plab5_mcore_proc_resp_acc
	`elsif PROC_ACC_INSECURE
		plab5_mcore_proc_resp_acc_insecure
	`endif
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	inst_resp_acc_p1
	(
		.clk				(clk),
		.resp_sec_level		(inst_net_resp_out_domain_d1),
		.proc_sec_level		(1),

		.net_resp_val		(inst_net_resp_out_val_d1),
		.net_resp_rdy		(inst_net_resp_out_rdy_d1),
		.net_resp_msg		(inst_net_resp_out_msg_proc_d1),
		.net_resp_fail		(inst_net_resp_out_fail_d1),

		.proc_resp_val		(inst_proc_resp_out_val_d1),
		.proc_resp_rdy		(inst_proc_resp_out_rdy_d1),
		.proc_resp_msg		(inst_proc_resp_out_msg_proc_d1),
		.proc_resp_fail		(inst_proc_resp_out_fail_d1)
	);

	// processor0 data response access control
	`ifdef PROC_ACC_SECURE
		plab5_mcore_proc_resp_acc
	`elsif PROC_ACC_INSECURE
		plab5_mcore_proc_resp_acc_insecure
	`endif
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	data_resp_acc_p0
	(
		.clk				(clk),
		.resp_sec_level		(data_net_resp_out_domain_d0),
		.proc_sec_level		(0),

		.net_resp_val		(data_net_resp_out_val_d0),
		.net_resp_rdy		(data_net_resp_out_rdy_d0),
		.net_resp_msg		(data_net_resp_out_msg_proc_d0),
		.net_resp_fail		(data_net_resp_out_fail_d0),

		.proc_resp_val		(data_proc_resp_out_val_d0),
		.proc_resp_rdy		(data_proc_resp_out_rdy_d0),
		.proc_resp_msg		(data_proc_resp_out_msg_proc_d0),
		.proc_resp_fail		(data_proc_resp_out_fail_d0)
	);

	// processor1 data response access control
	`ifdef PROC_ACC_SECURE
		plab5_mcore_proc_resp_acc
	`elsif PROC_ACC_INSECURE
		plab5_mcore_proc_resp_acc_insecure
	`endif
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	data_resp_acc_p1
	(
		.clk				(clk),
		.resp_sec_level		(data_net_resp_out_domain_d1),
		.proc_sec_level		(1),

		.net_resp_val		(data_net_resp_out_val_d1),
		.net_resp_rdy		(data_net_resp_out_rdy_d1),
		.net_resp_msg		(data_net_resp_out_msg_proc_d1),
		.net_resp_fail		(data_net_resp_out_fail_d1),

		.proc_resp_val		(data_proc_resp_out_val_d1),
		.proc_resp_rdy		(data_proc_resp_out_rdy_d1),
		.proc_resp_msg		(data_proc_resp_out_msg_proc_d1),
		.proc_resp_fail		(data_proc_resp_out_fail_d1)
	);
	
	// declare cache-related wires
	// req0/resp0 connected to router0, req1/resp1 connected to router1
	
	wire	[mrqc-1:0]		{Ctrl inst_cachereq0_domain}  inst_cachereq0_control;
	wire	[mrqd-1:0]		{Data inst_cachereq0_domain}  inst_cachereq0_data;
	wire					{Ctrl inst_cachereq0_domain}  inst_cachereq0_val;
	wire					{Ctrl inst_cachereq0_domain}  inst_cachereq0_rdy;
	wire					{L}                           inst_cachereq0_domain;

	wire	[mrsc-1:0]		{Ctrl inst_cacheresp0_domain} inst_cacheresp0_control;
	wire	[mrsd-1:0]		{Data inst_cacheresp0_domain} inst_cacheresp0_data;
	wire					{Ctrl inst_cacheresp0_domain} inst_cacheresp0_val;
	wire					{Ctrl inst_cacheresp0_domain} inst_cacheresp0_rdy;
	wire					{L}                           inst_cacheresp0_domain;

	wire	[mrqc-1:0]		{Ctrl inst_cachereq1_domain}  inst_cachereq1_control;
    wire	[mrqd-1:0]		{Data inst_cachereq1_domain}  inst_cachereq1_data;
	wire					{Ctrl inst_cachereq1_domain}  inst_cachereq1_val;
	wire					{Ctrl inst_cachereq1_domain}  inst_cachereq1_rdy;
	wire					{L}                           inst_cachereq1_domain;

	wire	[mrsc-1:0]		{Ctrl inst_cacheresp1_domain} inst_cacheresp1_control;
	wire	[mrsd-1:0]		{Data inst_cacheresp1_domain} inst_cacheresp1_data;
	wire					{Ctrl inst_cacheresp1_domain} inst_cacheresp1_val;
	wire					{Ctrl inst_cacheresp1_domain} inst_cacheresp1_rdy;
	wire					{Ctrl inst_cacheresp1_domain} inst_cacheresp1_fail;
	wire					{L}                           inst_cacheresp1_domain;

	wire	[mrqc-1:0]		{Ctrl data_cachereq0_domain}  data_cachereq0_control;
	wire	[mrqd-1:0]		{Data data_cachereq0_domain}  data_cachereq0_data;
	wire					{Ctrl data_cachereq0_domain}  data_cachereq0_val;
	wire					{Ctrl data_cachereq0_domain}  data_cachereq0_rdy;
	wire					{L}                           data_cachereq0_domain;

	wire	[mrsc-1:0]		{Ctrl data_cacheresp0_domain} data_cacheresp0_control;
	wire	[mrsd-1:0]		{Data data_cacheresp0_domain} data_cacheresp0_data;
	wire					{Ctrl data_cacheresp0_domain} data_cacheresp0_val;
	wire					{Ctrl data_cacheresp0_domain} data_cacheresp0_rdy;
	wire					{L}                           data_cacheresp0_domain;

	wire	[mrqc-1:0]		{Ctrl data_cachereq1_domain}  data_cachereq1_control;
	wire	[mrqd-1:0]		{Data data_cachereq1_domain}  data_cachereq1_data;
	wire					{Ctrl data_cachereq1_domain}  data_cachereq1_val;
	wire					{Ctrl data_cachereq1_domain}  data_cachereq1_rdy;
	wire					{L}                           data_cachereq1_domain;

	wire	[mrsc-1:0]		{Ctrl data_cacheresp1_domain} data_cacheresp1_control;
	wire	[mrsd-1:0]		{Data data_cacheresp1_domain} data_cacheresp1_data;
	wire					{Ctrl data_cacheresp1_domain} data_cacheresp1_val;
	wire					{Ctrl data_cacheresp1_domain} data_cacheresp1_rdy;
	wire					{Ctrl data_cacheresp1_domain} data_cacheresp1_fail;
	wire					{L}                           data_cacheresp1_domain;

	//assign  inst_cacheresp0_domain = inst_cachereq0_domain;
	//assign  data_cacheresp0_domain = data_cachereq0_domain;

	assign  inst_cachereq1_rdy	= 1;
	assign	inst_cacheresp1_val = 1;
	//assign  data_cacheresp1_val = 1;

	// inst refill net

	plab5_mcore_MemNet
	#(
		.p_mem_opaque_nbits			(o),
		.p_mem_addr_nbits			(a),
		.p_mem_data_nbits			(l),

		.p_num_ports				(p_num_cores),

		.p_single_bank				(1)
	)
	inst_net
	(
		.clk						(clk),
		.reset						(reset),

		.mode						(1'b0),

		.req_in_msg_p0				(inst_net_req_in_msg_proc_d0),
		.req_in_domain_p0			(req_in_domain_d0),
		.req_in_val_p0				(inst_net_req_in_val_d0),
		.req_in_rdy_p0				(inst_net_req_in_rdy_d0),

		.req_out_msg_control_p0		(inst_cachereq0_control),
		.req_out_msg_data_p0		(inst_cachereq0_data),
		.req_out_domain_p0			(inst_cachereq0_domain),
		.req_out_val_p0				(inst_cachereq0_val),
		.req_out_rdy_p0				(inst_cachereq0_rdy),

		.resp_in_msg_control_p0		(inst_cacheresp0_control),
		.resp_in_msg_data_p0		(inst_cacheresp0_data),
		.resp_in_domain_p0			(inst_cacheresp0_domain),
		.resp_in_val_p0				(inst_cacheresp0_val),
		.resp_in_rdy_p0				(inst_cacheresp0_rdy),
		.resp_in_fail_p0			(inst_L2_fail),

		.resp_out_msg_p0			(inst_net_resp_out_msg_proc_d0),
		.resp_out_domain_p0			(inst_net_resp_out_domain_d0),
		.resp_out_val_p0			(inst_net_resp_out_val_d0),
		.resp_out_rdy_p0			(inst_net_resp_out_rdy_d0),
		.resp_out_fail_p0			(inst_net_resp_out_fail_d0),

		.req_in_msg_p1				(inst_net_req_in_msg_proc_d1),
		.req_in_domain_p1			(req_in_domain_d1),
		.req_in_val_p1				(inst_net_req_in_val_d1),
		.req_in_rdy_p1				(inst_net_req_in_rdy_d1),

		.req_out_msg_control_p1		(inst_cachereq1_control),
		.req_out_msg_data_p1		(inst_cachereq1_data),
		.req_out_domain_p1			(inst_cachereq1_domain),
		.req_out_val_p1				(inst_cachereq1_val),
		.req_out_rdy_p1				(inst_cachereq1_rdy),

		.resp_in_msg_control_p1		(inst_cacheresp1_control),
		.resp_in_msg_data_p1		(inst_cacheresp1_data),
		.resp_in_domain_p1			(inst_cacheresp1_domain),
		.resp_in_val_p1				(inst_cacheresp1_val),
		.resp_in_rdy_p1				(inst_cacheresp1_rdy),
		.resp_in_fail_p1			(inst_cacheresp1_fail),

		.resp_out_msg_p1			(inst_net_resp_out_msg_proc_d1),
		.resp_out_domain_p1			(inst_net_resp_out_domain_d1),
		.resp_out_val_p1			(inst_net_resp_out_val_d1),
		.resp_out_rdy_p1			(inst_net_resp_out_rdy_d1),
		.resp_out_fail_p1			(inst_net_resp_out_fail_d1)

	);

	plab5_mcore_MemNet
	#(
		.p_mem_opaque_nbits			(o),
		.p_mem_addr_nbits			(a),
		.p_mem_data_nbits			(l),

		.p_num_ports				(p_num_cores),

		.p_single_bank				(1)
	)
	data_net
	(
		.clk						(clk),
		.reset						(reset),

		.mode						(1'b1),

		.req_in_msg_p0				(data_net_req_in_msg_proc_d0),
		.req_in_domain_p0			(req_in_domain_d0),
		.req_in_val_p0				(data_net_req_in_val_d0),
		.req_in_rdy_p0				(data_net_req_in_rdy_d0),

		.req_out_msg_control_p0		(data_cachereq0_control),
		.req_out_msg_data_p0		(data_cachereq0_data),
		.req_out_domain_p0			(data_cachereq0_domain),
		.req_out_val_p0				(data_cachereq0_val),
		.req_out_rdy_p0				(data_cachereq0_rdy),

		.resp_in_msg_control_p0		(data_cacheresp0_control),
		.resp_in_msg_data_p0		(data_cacheresp0_data),
		.resp_in_domain_p0			(data_cacheresp0_domain),
		.resp_in_val_p0				(data_cacheresp0_val),
		.resp_in_rdy_p0				(data_cacheresp0_rdy),
		.resp_in_fail_p0			(data_L2_fail),

		.resp_out_msg_p0			(data_net_resp_out_msg_proc_d0),
		.resp_out_domain_p0			(data_net_resp_out_domain_d0),
		.resp_out_val_p0			(data_net_resp_out_val_d0),
		.resp_out_rdy_p0			(data_net_resp_out_rdy_d0),
		.resp_out_fail_p0			(data_net_resp_out_fail_d0),

		.req_in_msg_p1				(data_net_req_in_msg_proc_d1),
		.req_in_domain_p1			(req_in_domain_d1),
		.req_in_val_p1				(data_net_req_in_val_d1),
		.req_in_rdy_p1				(data_net_req_in_rdy_d1),

		.req_out_msg_control_p1		(data_cachereq1_control),
		.req_out_msg_data_p1		(data_cachereq1_data),
		.req_out_domain_p1			(data_cachereq1_domain),
		.req_out_val_p1				(data_cachereq1_val),
		.req_out_rdy_p1				(data_cachereq1_rdy),

		.resp_in_msg_control_p1		(data_cacheresp1_control),
		.resp_in_msg_data_p1		(data_cacheresp1_data),
		.resp_in_domain_p1			(data_cacheresp1_domain),
		.resp_in_val_p1				(data_cacheresp1_val),
		.resp_in_rdy_p1				(data_cacheresp1_rdy),
		.resp_in_fail_p1			(data_cacheresp1_fail),

		.resp_out_msg_p1			(data_net_resp_out_msg_proc_d1),
		.resp_out_domain_p1			(data_net_resp_out_domain_d1),
		.resp_out_val_p1			(data_net_resp_out_val_d1),
		.resp_out_rdy_p1			(data_net_resp_out_rdy_d1),
		.resp_out_fail_p1			(data_net_resp_out_fail_d1)

	);

	// declare cache's wires
	
	wire [`VC_MEM_REQ_MSG_NBITS(o,a,l)-1:0]	{Data inst_cachereq0_domain}  inst_cachereq0_msg;
	wire [`VC_MEM_RESP_MSG_NBITS(o,l)-1:0]	{Data inst_cacheresp0_domain} inst_cacheresp0_msg;
	wire [`VC_MEM_REQ_MSG_NBITS(o,a,l)-1:0]	{Data data_cachereq0_domain}  data_cachereq0_msg;
	wire [`VC_MEM_RESP_MSG_NBITS(o,l)-1:0]	{Data data_cacheresp0_domain} data_cacheresp0_msg;

	wire									{Ctrl inst_cacheresp0_domain} inst_L2_fail;
	wire									{Ctrl data_cacheresp0_domain} data_L2_fail;

	wire [`VC_MEM_REQ_MSG_NBITS(o,a,l)-1:0]	{Data inst_cache2memreq0_domain} inst_cache2memreq0_msg;
	wire									{Ctrl inst_cache2memreq0_domain} inst_cache2memreq0_val;
	wire									{Ctrl inst_cache2memreq0_domain} inst_cache2memreq0_rdy;

	wire [`VC_MEM_RESP_MSG_NBITS(o,l)-1:0]	{Data inst_mem2cacheresp0_domain} inst_mem2cacheresp0_msg;
	wire									{Ctrl inst_mem2cacheresp0_domain} inst_mem2cacheresp0_val;
	wire									{Ctrl inst_mem2cacheresp0_domain} inst_mem2cacheresp0_rdy;

	wire [`VC_MEM_REQ_MSG_NBITS(o,a,l)-1:0] {Data data_cache2memreq0_domain} data_cache2memreq0_msg;
	wire									{Ctrl data_cache2memreq0_domain} data_cache2memreq0_val;
	wire									{Ctrl data_cache2memreq0_domain} data_cache2memreq0_rdy;

	wire [`VC_MEM_RESP_MSG_NBITS(o,l)-1:0]	{Data data_mem2cacheresp0_domain} data_mem2cacheresp0_msg;	
	wire									{Ctrl data_mem2cacheresp0_domain} data_mem2cacheresp0_val;
	wire									{Ctrl data_mem2cacheresp0_domain} data_mem2cacheresp0_rdy;

	// combine control and data signal to be one big message signal
	// to caches, or split message signal into control and data signals
	assign inst_cachereq0_msg  = {inst_cachereq0_control, inst_cachereq0_data};
	assign data_cachereq0_msg  = {data_cachereq0_control, data_cachereq0_data};
	assign {inst_cacheresp0_control, inst_cacheresp0_data} = inst_cacheresp0_msg;
	assign {data_cacheresp0_control, data_cacheresp0_data} = data_cacheresp0_msg;

	// shared instruction cache
	
	plab3_mem_BlockingL2Cache_Top
	#(
		.mode			    (0),
		.p_mem_nbytes		(p_l2_inst_nbytes),
		.p_num_banks		(1),
		.p_opaque_nbits		(o)
	)
	icache
	(
		.clk				(clk),
		.reset				(reset),

		.procreq_msg		(inst_cachereq0_msg),
		.procreq_val		(inst_cachereq0_val),
		.procreq_domain		(inst_cachereq0_domain),
		.procreq_rdy		(inst_cachereq0_rdy),

		.fail				(inst_L2_fail),
		.procresp_msg		(inst_cacheresp0_msg),
		.procresp_val		(inst_cacheresp0_val),
		.procresp_domain	(inst_cacheresp0_domain),
		.procresp_rdy		(inst_cacheresp0_rdy),

		.memreq_msg			(inst_cache2memreq0_msg),
		.memreq_domain		(inst_cache2memreq0_domain),
		.memreq_val			(inst_cache2memreq0_val),
		.memreq_rdy			(inst_cache2memreq0_rdy),
		
		.insecure			(inst_insecure),
		.memresp_msg		(inst_mem2cacheresp0_msg),
		.memresp_domain		(inst_mem2cacheresp0_domain),
		.memresp_val		(inst_mem2cacheresp0_val),
		.memresp_rdy		(inst_mem2cacheresp0_rdy)
	);

	plab3_mem_BlockingL2Cache_Top
	#(
		.mode				(1),
		.p_mem_nbytes		(p_l2_data_nbytes),
		.p_num_banks		(1),
		.p_opaque_nbits		(o)
	)
	dcache
	(
		.clk				(clk),
		.reset				(reset),

		.procreq_msg		(data_cachereq0_msg),
		.procreq_val		(data_cachereq0_val),
		.procreq_domain		(data_cachereq0_domain),
		.procreq_rdy		(data_cachereq0_rdy),

		.fail				(data_L2_fail),
		.procresp_msg		(data_cacheresp0_msg),
		.procresp_val		(data_cacheresp0_val),
		.procresp_domain	(data_cacheresp0_domain),
		.procresp_rdy		(data_cacheresp0_rdy),

		.memreq_msg			(data_cache2memreq0_msg),
		.memreq_domain		(data_cache2memreq0_domain),
		.memreq_val			(data_cache2memreq0_val),
		.memreq_rdy			(data_cache2memreq0_rdy),

		.insecure			(data_insecure0),
		.memresp_msg		(data_mem2cacheresp0_msg),
		.memresp_domain		(data_mem2cacheresp0_domain),
		.memresp_val		(data_mem2cacheresp0_val),
		.memresp_rdy		(data_mem2cacheresp0_rdy)
	);

	// Direct Memory Access Security Checker
	
	// DMA checker's related wires
	wire [a-1:0]	{Ctrl data_cachereq1_domain}  dmache_noc_src_addr;
	wire [a-1:0]	{Ctrl data_cachereq1_domain}  dmache_noc_dest_addr;
	wire			{Ctrl data_cacheresp1_domain} dmache_noc_ack;

	assign dmache_noc_src_addr = data_cachereq1_control[4 +: a]; 
	assign dmache_noc_dest_addr = data_cachereq1_data[a-1:0];

	assign data_cacheresp1_val = dmache_noc_ack;
	assign data_cacheresp1_data = 'hx;
	assign data_cacheresp1_domain = 1'b0;
	assign data_cacheresp1_fail = 1'b0;
	
	plab5_mcore_DMA_checker
	#(
		.p_opaque_nbits	(o),
		.p_addr_nbits	(a),
		.p_data_nbits	(l)
	)
	DMA_checker
	(
		.clk				(clk),
		.reset				(reset),

		.noc_val			(data_cachereq1_val),
		.noc_rdy			(data_cachereq1_rdy),
		.noc_domain			(data_cachereq1_domain),
		.noc_src_addr		(dmache_noc_src_addr),
		.noc_dest_addr		(dmache_noc_dest_addr),
		.noc_req_control	(data_cachereq1_control),
		.noc_resp_control	(data_cacheresp1_control),
		.noc_inst			(0),
		.noc_ack			(data_cacheresp1_val),
		.noc_resp_domain	(data_cacheresp1_domain),

		.dma_val			(dmactrl_val),
		.dma_rdy			(dmactrl_rdy),
		.dma_domain			(dmactrl_domain),
		.dma_src_addr		(dmactrl_src_addr),
		.dma_dest_addr		(dmactrl_dest_addr),
		.dma_req_control	(dmactrl_req_control),
		.dma_inst			(dmactrl_inst),
		.dma_ack			(dmactrl_ack)
	);

    // Direct Memory Access Controller
	
	// declare DMA controller's wires
	wire				{Ctrl dmactrl_domain}      dmactrl_val;
	wire				{Ctrl dmactrl_domain}      dmactrl_rdy;
	wire				{L}                        dmactrl_domain;
	wire [a-1:0]		{Ctrl dmactrl_domain}      dmactrl_src_addr;
	wire [a-1:0]		{Ctrl dmactrl_domain}      dmactrl_dest_addr;
	wire [mrqc-1:0]		{Ctrl dmactrl_domain}      dmactrl_req_control;
	wire				{Ctrl dmactrl_domain}      dmactrl_inst;
	wire				{Ctrl dmactrl_domain}      dmactrl_ack;

	wire				{Ctrl dmactrl_domain}      dmactrl_db_val;
	wire [a-1:0]		{Ctrl dmactrl_domain}      dmactrl_db_src_addr;
	wire [a-1:0]		{Ctrl dmactrl_domain}      dmactrl_db_dest_addr;
	wire				{Ctrl dmactrl_domain}      dmactrl_db_inst;
	wire [l-1:0]		{Data dmactrl_domain}      dmactrl_debug_data;

	wire [mrqc-1:0]		{Ctrl data_dma2memreq_domain}  data_dma2memreq_control;
	wire [mrqd-1:0]		{Data data_dma2memreq_domain}  data_dma2memreq_data;
	wire				{Ctrl data_dma2memreq_domain}  data_dma2memreq_val;
	wire				{Ctrl data_dma2memreq_domain}  data_dma2memreq_rdy;
	wire				{L}                            data_dma2memreq_domain;

	wire [mrsc-1:0]		{Ctrl data_mem2dmaresp_domain} data_mem2dmaresp_control;
	wire [mrsd-1:0]		{Data data_mem2dmaresp_domain} data_mem2dmaresp_data;
	wire				{Ctrl data_mem2dmaresp_domain} data_mem2dmaresp_val;
	wire				{Ctrl data_mem2dmaresp_domain} data_mem2dmaresp_rdy;
	wire				{L}                            data_mem2dmaresp_domain;

	plab5_mcore_DMA_Controller
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	DMA_ctrl
	(
		.clk				(clk),
		.reset				(reset),

		.domain				(dmactrl_domain),

		.val				(dmactrl_val),
		.rdy				(dmactrl_rdy),
		.src_addr			(dmactrl_src_addr),
		.dest_addr			(dmactrl_dest_addr),
		.req_control		(dmactrl_req_control),
		.inst				(dmactrl_inst),
		.ack				(dmactrl_ack),

		.db_val				(dmactrl_db_val),
		.db_src_addr		(dmactrl_db_src_addr),
		.db_dest_addr		(dmactrl_db_dest_addr),
		.db_inst			(dmactrl_db_inst),
		.debug_data			(dmactrl_debug_data),

		.mem_req_val		(data_dma2memreq_val),
		.mem_req_rdy		(data_dma2memreq_rdy),
		.mem_req_control	(data_dma2memreq_control),
		.mem_req_data		(data_dma2memreq_data),
		.mem_req_domain		(data_dma2memreq_domain),

		.mem_resp_val		(data_mem2dmaresp_val),
		.mem_resp_rdy		(data_mem2dmaresp_rdy),
		.mem_resp_control	(data_mem2dmaresp_control),
		.mem_resp_data		(data_mem2dmaresp_data),
		.mem_resp_domain	(data_mem2dmaresp_domain)
	);

	// Debug Module associated with DMA controller
	
	// declare debug interface's wires
	
	wire			{Ctrl db_domain} db_start;
	wire			{Ctrl db_domain} db_inst;
	wire [a-1:0]	{Ctrl db_domain} db_out_src_addr;
	wire [a-1:0]	{Ctrl db_domain} db_out_dest_addr;
	wire			{Ctrl db_domain} db_result_rdy;
	wire [l-1:0]	{Data db_domain} db_result_data;	
	wire			{L}              db_domain;

	wire			{L} db_val;
	wire [a-1:0]	{L} db_in_src_addr;
	wire [a-1:0]	{L} db_in_dest_addr;

	wire			{Ctrl db_resp_domain} db_ack;
	wire [l-1:0]	{Data db_resp_domain} db_data;
    wire            {L}                   db_resp_domain;

	assign db_in_src_addr  = debug_msg_p0[`VC_MEM_REQ_MSG_ADDR_FIELD(o,a,d)];
	assign db_in_dest_addr = debug_msg_p0[`VC_MEM_REQ_MSG_DATA_FIELD(o,a,d)];
	
	plab5_mcore_Debug_checker
	#(
		.p_opaque_nbits		(o),
		.p_addr_nbits		(a),
		.p_data_nbits		(l)
	)
	Debug_checker
	(
		.clk				(clk),
		.reset				(reset),

		.debug_val			(db_start),
		.debug_domain		(db_domain),
		.debug_src_addr		(db_out_src_addr),
		.debug_dest_addr	(db_out_dest_addr),
		.debug_inst			(db_inst),
		.debug_ack			(db_ack),
		.debug_data			(db_data),
        .debug_resp_domain  (db_resp_domain),

		.dma_domain			(dmactrl_domain),
		.dma_ack			(dmactrl_ack),
		.dma_db_val			(dmactrl_db_val),
		.dma_db_src_addr	(dmactrl_db_src_addr),
		.dma_db_dest_addr	(dmactrl_db_dest_addr),
		.dma_db_inst		(dmactrl_db_inst),
		.dma_db_debug_data	(dmactrl_debug_data)
	);
	
	plab5_mcore_Debug_Interface
	#(
		.p_addr_nbits	(a),
		.p_data_nbits	(l)
	)
	Debug_interface
	(
		.clk			(clk),
		.reset			(reset),

		.start			(db_start),
		.inst			(db_inst),
		.src_addr		(db_out_src_addr),
		.dest_addr		(db_out_dest_addr),
		.domain			(db_domain),
		.result_rdy		(db_result_rdy),
		.db_result		(db_result_data),

		.val			(debug_val_p0),
		.db_src_addr	(db_in_src_addr),
		.db_dest_addr	(db_in_dest_addr),
		.db_domain		(0),
		.ack			(db_ack),
		.read_data		(db_data)
	);

	// declare address access control wire
	
	wire [mrqc-1:0]			{Ctrl inst_cache2memreq0_domain}  inst_cache2memreq0_control;
	wire [mrqd-1:0]			{Data inst_cache2memreq0_domain}  inst_cache2memreq0_data;
	wire					{L}                               inst_cache2memreq0_domain;

	wire [mrsc-1:0]			{Ctrl inst_mem2cacheresp0_domain} inst_mem2cacheresp0_control;
	wire [mrsd-1:0]			{Data inst_mem2cacheresp0_domain} inst_mem2cacheresp0_data;
	wire					{L}                               inst_mem2cacheresp0_domain;

	wire					{Ctrl inst_mem2cacheresp0_domain} inst_insecure;

	wire [mrqc-1:0]			{Ctrl data_cache2memreq0_domain}  data_cache2memreq0_control;
	wire [mrqd-1:0]			{Data data_cache2memreq0_domain}  data_cache2memreq0_data;
	wire					{L}                               data_cache2memreq0_domain;

	wire [mrsc-1:0]			{Ctrl data_mem2cacheresp0_domain} data_mem2cacheresp0_control;
	wire [mrsd-1:0]			{Data data_mem2cacheresp0_domain} data_mem2cacheresp0_data;
	wire					{L}                               data_mem2cacheresp0_domain;

    wire                    {Ctrl data_mem2cacheresp0_domain} data_insecure0;
    wire                    {Ctrl data_mem2dmaresp_domain}    data_insecure1;
	wire					{Ctrl data_mem2arbresp_domain}    data_insecure;

	// combine control/data signals into a big whole structure or
	// split a whole signal into control/data signals
	assign {inst_cache2memreq0_control, inst_cache2memreq0_data}
											= inst_cache2memreq0_msg;
	assign {data_cache2memreq0_control, data_cache2memreq0_data}
											= data_cache2memreq0_msg;
	assign	inst_mem2cacheresp0_msg 
			=	{inst_mem2cacheresp0_control, inst_mem2cacheresp0_data};
	assign	data_mem2cacheresp0_msg
			=	{data_mem2cacheresp0_control, data_mem2cacheresp0_data};

	// instruction memory address/access control module

	plab5_mcore_mem_acc_ctrl
	#(
		.mem_size				(p_mem_nbytes/2),
		.initial_par			(32'h4000),
		.p_opaque_nbits			(o),
		.p_addr_nbits			(a),
		.p_data_nbits			(l)
	)
	inst_mem_acc_ctrl
	(
		.clk					(clk),
		.reset					(reset),

		.req_sec_level			(inst_cache2memreq0_domain),
		.resp_sec_level			(inst_mem2cacheresp0_domain),
		.insecure				(inst_insecure),

		.cache2mem_req_control	(inst_cache2memreq0_control),
		.cache2mem_req_data		(inst_cache2memreq0_data),
		.cache2mem_req_val		(inst_cache2memreq0_val),
		.cache2mem_req_rdy		(inst_cache2memreq0_rdy),

		.mem_req_control		(inst_memreq0_control),
		.mem_req_data			(inst_memreq0_data),
		.mem_req_val			(inst_memreq0_val),
		.mem_req_rdy			(inst_memreq0_rdy),
        .mem_req_domain         (inst_memreq0_domain),

		.mem2cache_resp_control	(inst_mem2cacheresp0_control),
		.mem2cache_resp_data	(inst_mem2cacheresp0_data),
		.mem2cache_resp_val		(inst_mem2cacheresp0_val),
		.mem2cache_resp_rdy		(inst_mem2cacheresp0_rdy),

		.mem_resp_control		(inst_memresp0_control),
		.mem_resp_data			(inst_memresp0_data),
		.mem_resp_val			(inst_memresp0_val),
		.mem_resp_rdy			(inst_memresp0_rdy),
        .mem_resp_domain        (inst_memresp0_domain)
	);

	// mem accesses arbiter for data main memory part
	
	// declare related wires
	wire					{Ctrl data_arb2memreq_domain}  data_arb2memreq_val;
	wire					{Ctrl data_arb2memreq_domain}  data_arb2memreq_rdy;	
	wire [mrqc-1:0]			{Ctrl data_arb2memreq_domain}  data_arb2memreq_control;
	wire [mrqd-1:0]			{Data data_arb2memreq_domain}  data_arb2memreq_data;
	wire					{L}                            data_arb2memreq_domain;

	wire					{Ctrl data_mem2arbresp_domain} data_mem2arbresp_val;
	wire					{Ctrl data_mem2arbresp_domain} data_mem2arbresp_rdy;
	wire [mrsc-1:0]			{Ctrl data_mem2arbresp_domain} data_mem2arbresp_control;
	wire [mrsd-1:0]			{Data data_mem2arbresp_domain} data_mem2arbresp_data;
	wire					{L}                            data_mem2arbresp_domain;

	plab5_mcore_mem_arbiter
	#(
		.p_opaque_nbits			(o),
		.p_addr_nbits			(a),
		.p_data_nbits			(l)
	)
	data_mem_arbiter
	(
		.clk					(clk),
		.reset					(reset),

		.req0_val				(data_cache2memreq0_val),
		.req0_rdy				(data_cache2memreq0_rdy),
		.req0_control			(data_cache2memreq0_control),
		.req0_data				(data_cache2memreq0_data),
		.req0_domain			(data_cache2memreq0_domain),

		.req1_val				(data_dma2memreq_val),
		.req1_rdy				(data_dma2memreq_rdy),
		.req1_control			(data_dma2memreq_control),
		.req1_data				(data_dma2memreq_data),
		.req1_domain			(data_dma2memreq_domain),

		.req_val				(data_arb2memreq_val),
		.req_rdy				(data_arb2memreq_rdy),
		.req_control			(data_arb2memreq_control),
		.req_data				(data_arb2memreq_data),
		.req_domain				(data_arb2memreq_domain),

		.resp0_val				(data_mem2cacheresp0_val),
		.resp0_rdy				(data_mem2cacheresp0_rdy),
		.resp0_control			(data_mem2cacheresp0_control),
		.resp0_data				(data_mem2cacheresp0_data),
        .resp0_insecure         (data_insecure0),
		.resp0_domain			(data_mem2cacheresp0_domain),

		.resp1_val				(data_mem2dmaresp_val),
		.resp1_rdy				(data_mem2dmaresp_rdy),
		.resp1_control			(data_mem2dmaresp_control),
		.resp1_data				(data_mem2dmaresp_data),
        .resp1_insecure         (data_insecure1),
		.resp1_domain			(data_mem2dmaresp_domain),

		.resp_val				(data_mem2arbresp_val),
		.resp_rdy				(data_mem2arbresp_rdy),
		.resp_control			(data_mem2arbresp_control),
		.resp_data				(data_mem2arbresp_data),
        .resp_insecure          (data_insecure),
		.resp_domain			(data_mem2arbresp_domain)
	);

	// data memory address/access control module

	plab5_mcore_mem_acc_ctrl
	#(
		.mem_size				(p_mem_nbytes/2),
		.initial_par			(32'hc000),
		.p_opaque_nbits			(o),
		.p_addr_nbits			(a),
		.p_data_nbits			(l)
	)
	data_mem_acc_ctrl
	(
		.clk					(clk),
		.reset					(reset),

		.req_sec_level			(data_arb2memreq_domain),
		.resp_sec_level			(data_mem2arbresp_domain),
		.insecure				(data_insecure),

		.cache2mem_req_control	(data_arb2memreq_control),
		.cache2mem_req_data		(data_arb2memreq_data),
		.cache2mem_req_val		(data_arb2memreq_val),
		.cache2mem_req_rdy		(data_arb2memreq_rdy),

		.mem_req_control		(data_memreq0_control),
		.mem_req_data			(data_memreq0_data),
		.mem_req_val			(data_memreq0_val),
		.mem_req_rdy			(data_memreq0_rdy),
        .mem_req_domain         (data_memreq0_domain),

		.mem2cache_resp_control	(data_mem2arbresp_control),
		.mem2cache_resp_data	(data_mem2arbresp_data),
		.mem2cache_resp_val		(data_mem2arbresp_val),
		.mem2cache_resp_rdy		(data_mem2arbresp_rdy),

		.mem_resp_control		(data_memresp0_control),
		.mem_resp_data			(data_memresp0_data),
		.mem_resp_val			(data_memresp0_val),
		.mem_resp_rdy			(data_memresp0_rdy),
        .mem_resp_domain        (data_memresp0_domain)
	);

	// declare memory's wire
	
	wire [mrqc-1:0]		{Ctrl inst_memreq0_domain}  inst_memreq0_control;
	wire [mrqd-1:0]		{Data inst_memreq0_domain}  inst_memreq0_data;
	wire				{Ctrl inst_memreq0_domain}  inst_memreq0_val;
	wire				{Ctrl inst_memreq0_domain}  inst_memreq0_rdy;
	wire				{L}                         inst_memreq0_domain;

	wire [mrqc-1:0]		{Ctrl data_memreq0_domain}  data_memreq0_control;
	wire [mrqd-1:0]		{Data data_memreq0_domain}  data_memreq0_data;
	wire				{Ctrl data_memreq0_domain}  data_memreq0_val;
	wire				{Ctrl data_memreq0_domain}  data_memreq0_rdy;
	wire				{L}                         data_memreq0_domain;

	wire [mrsc-1:0]		{Ctrl inst_memresp0_domain} inst_memresp0_control;
	wire [mrsd-1:0]		{Data inst_memresp0_domain} inst_memresp0_data;
	wire				{Ctrl inst_memresp0_domain} inst_memresp0_val;
	wire				{Ctrl inst_memresp0_domain} inst_memresp0_rdy;
	wire				{L}                         inst_memresp0_domain;

	wire [mrsc-1:0]		{Ctrl data_memresp0_domain} data_memresp0_control;
	wire [mrsd-1:0]		{Data data_memresp0_domain} data_memresp0_data;
	wire				{Ctrl data_memresp0_domain} data_memresp0_val;
	wire				{Ctrl data_memresp0_domain} data_memresp0_rdy;
	wire				{L}                         data_memresp0_domain;

	// shared instruction main memory
	
	plab5_mcore_MainMem	
	#(
		.p_mem_nbytes	(p_mem_nbytes/4), 
		.p_opaque_nbits	(o), 
		.p_addr_nbits	(a), 
		.p_data_nbits	(l)
	)
	inst_mem
	(
		.clk			(clk),
		.reset			(reset),

		.mode			(0),
		.mem_clear		(mem_clear),

		.memreq_val		(inst_memreq0_val),
		.memreq_rdy		(inst_memreq0_rdy),
		.memreq_control	(inst_memreq0_control),
		.memreq_data	(inst_memreq0_data),
		.memreq_domain	(inst_memreq0_domain),

		.memresp_val	(inst_memresp0_val),
		.memresp_rdy	(inst_memresp0_rdy),
		.memresp_control(inst_memresp0_control),
		.memresp_data	(inst_memresp0_data),
		.memresp_domain	(inst_memresp0_domain)
	);

	// shared data  main memory
	
	plab5_mcore_MainMem
	#(
		.p_mem_nbytes	(p_mem_nbytes/4),
		.p_opaque_nbits	(o),
		.p_addr_nbits	(a),
		.p_data_nbits	(l)
	)
	data_mem
	(
		.clk			(clk),
		.reset			(reset),

		.mode			(1),
		.mem_clear		(mem_clear),

		.memreq_val		(data_memreq0_val),
		.memreq_rdy		(data_memreq0_rdy),
		.memreq_control	(data_memreq0_control),
		.memreq_data	(data_memreq0_data),
		.memreq_domain	(data_memreq0_domain),

		.memresp_val	(data_memresp0_val),
		.memresp_rdy	(data_memresp0_rdy),
		.memresp_control(data_memresp0_control),
		.memresp_data	(data_memresp0_data),
		.memresp_domain	(data_memresp0_domain)
	);

endmodule
`endif /* PLAB5_MCORE_PROC_NET_CACHE_MEM_SEP_V */
