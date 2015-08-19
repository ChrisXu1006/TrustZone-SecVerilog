//========================================================================
// Memory Request/Response Network
//========================================================================

`ifndef PLAB5_MCORE_MEM_NET_V
`define PLAB5_MCORE_MEM_NET_V

`include "vc-mem-msgs.v"
//`include "vc-net-msgs.v"
`include "vc-net-msgsunpack.v"
`include "plab5-mcore-mem-net-req.v"
`include "plab5-mcore-mem-net-resp.v"
`include "plab4-net-RingNet.v"

module plab5_mcore_MemNet
#(
  parameter p_mem_opaque_nbits  = 8,
  parameter p_mem_addr_nbits    = 32,
  parameter p_mem_data_nbits    = 32,

  parameter p_num_ports         = 4,

  parameter p_single_bank       = 0,

  parameter o = p_mem_opaque_nbits,
  parameter a = p_mem_addr_nbits,
  parameter d = p_mem_data_nbits,

  parameter c_net_srcdest_nbits = $clog2(p_num_ports),
  parameter c_net_opaque_nbits  = 4,

  parameter ns = c_net_srcdest_nbits,
  parameter no = c_net_opaque_nbits,

  parameter c_req_nbits   = `VC_MEM_REQ_MSG_NBITS(o,a,d),
  parameter c_req_cnbits  = c_req_nbits - d,
  parameter c_req_dnbits  = d,
  parameter c_resp_nbits  = `VC_MEM_RESP_MSG_NBITS(o,d),
  parameter c_resp_cnbits = c_resp_nbits - d,
  parameter c_resp_dnbits = d,

  parameter rq  = c_req_nbits,
  parameter rqc = c_req_cnbits,
  parameter rqd = c_req_dnbits, 
  parameter rs	= c_resp_nbits,
  parameter rsc = c_resp_cnbits,
  parameter rsd = c_resp_dnbits,

  parameter c_req_net_msg_cnbits  = `VC_NET_MSG_NBITS(rqc,no,ns),
  parameter c_req_net_msg_dnbits  = rqd,
  parameter c_resp_net_msg_cnbits = `VC_NET_MSG_NBITS(rsc,no,ns),
  parameter c_resp_net_msg_dnbits = rsd,

  parameter nrqc = c_req_net_msg_cnbits,
  parameter nrqd = c_req_net_msg_dnbits,
  parameter nrsc = c_resp_net_msg_cnbits,
  parameter nrsd = c_resp_net_msg_dnbits

)
(
	
	input				{L} clk,
	input				{L} reset,

	input				{L} mode,

	input	[rq-1:0]	{D1} req_in_msg_p0,
    input               {L}  req_in_domain_p0,
	input				{L}  req_in_val_p0,
	output				{L}  req_in_rdy_p0,
	
	output	[rs-1:0]	{Data resp_out_domain_p0} resp_out_msg_p0,
	output				{L}                       resp_out_domain_p0,
	output				{Ctrl resp_out_domain_p0} resp_out_val_p0,
	input				{Ctrl resp_out_domain_p0} resp_out_rdy_p0,
    output              {Ctrl resp_out_domain_p0} resp_out_fail_p0,

	output	[rqc-1:0]	{Ctrl req_out_domain_p0} req_out_msg_control_p0,
	output  [rqd-1:0]	{Data req_out_domain_p0} req_out_msg_data_p0,
	output				{L}                      req_out_domain_p0,
	output				{Ctrl req_out_domain_p0} req_out_val_p0,
	input				{Ctrl req_out_domain_p0} req_out_rdy_p0,

	input	[rsc-1:0]	{Ctrl resp_in_domain_p0}  resp_in_msg_control_p0,
	input	[rsd-1:0]	{Data resp_in_domain_p0}  resp_in_msg_data_p0,
	input				{L}                       resp_in_domain_p0,
	input				{Ctrl resp_in_domain_p0}  resp_in_val_p0,
	output				{Ctrl resp_in_domain_p0}  resp_in_rdy_p0,
    input               {Ctrl resp_in_domain_p0}  resp_in_fail_p0,

	input	[rq-1:0]	{D2} req_in_msg_p1,
    input               {L}  req_in_domain_p1,
	input				{L}  req_in_val_p1,
	output				{L}  req_in_rdy_p1,
	
	output	[rs-1:0]	{Data resp_out_domain_p1} resp_out_msg_p1,
	output				{L}                       resp_out_domain_p1,
	output				{Ctrl resp_out_domain_p1} resp_out_val_p1,
	input				{Ctrl resp_out_domain_p1} resp_out_rdy_p1,
    output              {Ctrl resp_out_domain_p1} resp_out_fail_p1,

	output	[rqc-1:0]	{Ctrl req_out_domain_p1}  req_out_msg_control_p1,
	output  [rqd-1:0]	{Data req_out_domain_p1}  req_out_msg_data_p1,
	output				{L}                       req_out_domain_p1,
	output				{Ctrl req_out_domain_p1}  req_out_val_p1,
	input				{Ctrl req_out_domain_p1}  req_out_rdy_p1,

	input	[rsc-1:0]	{Ctrl resp_in_domain_p1}  resp_in_msg_control_p1,
	input	[rsd-1:0]	{Data resp_in_domain_p1}  resp_in_msg_data_p1,
	input				{L}                       resp_in_domain_p1,
	input				{Ctrl resp_in_domain_p1}  resp_in_val_p1,
	output				{Ctrl resp_in_domain_p1}  resp_in_rdy_p1,
    input               {Ctrl resp_in_domain_p1}  resp_in_fail_p1

);

    wire    [rqc-1:0]   {L}  req_in_msg_control_p0;
    wire    [rqd-1:0]   {D1} req_in_msg_data_p0; 
    assign {req_in_msg_control_p0, req_in_msg_data_p0} = req_in_msg_p0;

	wire	[nrqc:0]	{L}  req_net_in_msg_control_p0;
	wire	[nrqd-1:0]	{D1} req_net_in_msg_data_p0;
	wire	[nrqc:0]	{Ctrl req_out_domain_p0} req_net_out_msg_control_p0;
	wire	[nrqd-1:0]	{Data  req_out_domain_p0} req_net_out_msg_data_p0;

	wire	[nrsc+1:0]	{Ctrl resp_in_domain_p0} resp_net_in_msg_control_p0;
	wire	[nrsd-1:0]	{Data resp_in_domain_p0} resp_net_in_msg_data_p0;
	wire	[nrsc+1:0]	{Ctrl resp_out_domain_p0}resp_net_out_msg_control_p0;
	wire	[nrsd-1:0]	{Data resp_out_domain_p0}resp_net_out_msg_data_p0;

	wire	[rqc:0]		{Ctrl req_out_domain_p0}  req_out_msg_control_M_p0;
	wire	[rsc+1:0]	{Ctrl resp_out_domain_p0} resp_out_msg_control_M_p0;
	wire	[rsc-1:0]	{Ctrl resp_out_domain_p0} resp_out_msg_control_p0;
	wire	[rsd-1:0]	{Data resp_out_domain_p0} resp_out_msg_data_p0;

    wire    [rqc-1:0]   {L}  req_in_msg_control_p1;
    wire    [rqd-1:0]   {D2} req_in_msg_data_p1;
    assign {req_in_msg_control_p1, req_in_msg_data_p1} = req_in_msg_p1; 

	wire	[nrqc:0]	{L}  req_net_in_msg_control_p1;
	wire	[nrqd-1:0]	{D2} req_net_in_msg_data_p1;
	wire	[nrqc:0]	{Ctrl req_out_domain_p1} req_net_out_msg_control_p1;
	wire	[nrqd-1:0]	{Data req_out_domain_p1} req_net_out_msg_data_p1;

	wire	[nrsc+1:0]	{Ctrl resp_in_domain_p1} resp_net_in_msg_control_p1;
	wire	[nrsd-1:0]	{Data resp_in_domain_p1} resp_net_in_msg_data_p1;
	wire	[nrsc+1:0]	{Ctrl resp_out_domain_p1}resp_net_out_msg_control_p1;
	wire	[nrsd-1:0]	{Data resp_out_domain_p1}resp_net_out_msg_data_p1;

	wire	[rqc:0]		{Ctrl req_out_domain_p1} req_out_msg_control_M_p1;
	wire	[rsc+1:0]	{Ctrl resp_out_domain_p1}resp_out_msg_control_M_p1;
	wire	[rsc-1:0]	{Ctrl resp_out_domain_p1}resp_out_msg_control_p1;
	wire	[rsd-1:0]	{Data resp_out_domain_p1} resp_out_msg_data_p1;
	

	// proc req mem msg to net msg adapter

	plab5_mcore_MemReqMsgToNetMsg
    #(
        .p_net_src            (0),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_addr_nbits     (p_mem_addr_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits),

        .p_single_bank        (p_single_bank)
      )
      proc_mem_msg_to_net_msg_p0
      (
		.mode				(mode),
        .domain             (1'b0),
        .mem_msg_control	(req_in_msg_control_p0),
        .mem_msg_data       (req_in_msg_data_p0),
        .net_msg_control	(req_net_in_msg_control_p0),
        .net_msg_data		(req_net_in_msg_data_p0)
      );

	plab5_mcore_MemReqMsgToNetMsg
    #(
        .p_net_src            (1),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_addr_nbits     (p_mem_addr_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits),

        .p_single_bank        (p_single_bank)
      )
      proc_mem_msg_to_net_msg_p1
      (
		.mode				(mode),
        .domain             (1'b1),
        .mem_msg_control	(req_in_msg_control_p1),
        .mem_msg_data       (req_in_msg_data_p1),
        .net_msg_control	(req_net_in_msg_control_p1),
        .net_msg_data		(req_net_in_msg_data_p1)
      );

	  // extract the cache req mem msg from net msg payload

	  vc_NetMsgUnpack #(rqc+1,no,ns) req_net_msg_control_unpack_p0
      (
        .domain   (req_out_domain_p0),
        .msg      (req_net_out_msg_control_p0),
        .payload  (req_out_msg_control_M_p0)
      );

      wire {Ctrl req_out_domain_p0} req_out_domain_p0_M;

	  assign {req_out_domain_p0_M, req_out_msg_control_p0} 
		= req_out_msg_control_M_p0;

	  vc_NetMsgUnpack #(rqc+1,no,ns) req_net_msg_control_unpack_p1
      (
        .domain   (req_out_domain_p1),
        .msg      (req_net_out_msg_control_p1),
        .payload  (req_out_msg_control_M_p1)
      );
 
      wire {Ctrl req_out_domain_p1} req_out_domain_p1_M;

	  assign {req_out_domain_p1_M, req_out_msg_control_p1} 
		 = req_out_msg_control_M_p1;


	  // extract the cache req mem msg from net msg payload
	  assign req_out_msg_data_p0 = req_net_out_msg_data_p0;
	  assign req_out_msg_data_p1 = req_net_out_msg_data_p1;

	  // cache resp mem msg to net msg adapter

	  plab5_mcore_MemRespMsgToNetMsg
      #(
        .p_net_src            (0),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits)
      )
      cache_mem_msg_to_net_msg_p0
      (
        .mode           (mode),
	    .mem_msg_control(resp_in_msg_control_p0),
		.mem_msg_data	(resp_in_msg_data_p0),
		.domain         (resp_in_domain_p0),
        .mem_msg_fail   (resp_in_fail_p0),
        .net_msg_control(resp_net_in_msg_control_p0),
		.net_msg_data	(resp_net_in_msg_data_p0)
      );

	  plab5_mcore_MemRespMsgToNetMsg
      #(
        .p_net_src            (1),
        .p_num_ports          (p_num_ports),

        .p_mem_opaque_nbits   (p_mem_opaque_nbits),
        .p_mem_data_nbits     (p_mem_data_nbits),

        .p_net_opaque_nbits   (c_net_opaque_nbits),
        .p_net_srcdest_nbits  (c_net_srcdest_nbits)
      )
      cache_mem_msg_to_net_msg_p1
      (
        .mode           (mode),
	    .mem_msg_control(resp_in_msg_control_p1),
		.mem_msg_data	(resp_in_msg_data_p1),
		.domain         (resp_in_domain_p1),
        .mem_msg_fail   (resp_in_fail_p1),
        .net_msg_control(resp_net_in_msg_control_p1),
		.net_msg_data	(resp_net_in_msg_data_p1)
      );

	  // extract the proc resp mem msg from net msg payload

	  vc_NetMsgUnpack #(rsc+1,no,ns) resp_net_msg_control_unpack_p0
      (
        .domain   (resp_out_domain_p0),
        .msg      (resp_net_out_msg_control_p0),
        .payload  (resp_out_msg_control_M_p0)
      );

      wire {Ctrl resp_out_domain_p0} resp_out_domain_p0_M;

	  assign {resp_out_domain_p0_M, resp_out_fail_p0, resp_out_msg_control_p0}
		= resp_out_msg_control_M_p0;

	  assign resp_out_msg_data_p0 = resp_net_out_msg_data_p0;

	  assign resp_out_msg_p0 = { resp_out_msg_control_p0, resp_out_msg_data_p0 };

	  vc_NetMsgUnpack #(rsc+1,no,ns) resp_net_msg_control_unpack_p1
      (
        .domain   (resp_out_domain_p1),
        .msg      (resp_net_out_msg_control_p1),
        .payload  (resp_out_msg_control_M_p1)
      );

      wire {Ctrl resp_out_domain_p1} resp_out_domain_p1_M;

	  assign {resp_out_domain_p1_M, resp_out_fail_p1, resp_out_msg_control_p1}
		= resp_out_msg_control_M_p1;

	  assign resp_out_msg_data_p1 = resp_net_out_msg_data_p1;

	  assign resp_out_msg_p1 = { resp_out_msg_control_p1, resp_out_msg_data_p1 };

	// request network
	
	`define PLAB4_NET_NUM_PORTS_4

	wire		{L} req_net_in_val_p0;
	wire		{Ctrl req_out_domain_p0} req_net_out_rdy_p0;
	wire		{Ctrl resp_in_domain_p0} resp_net_in_val_p0;
	wire		{Ctrl resp_out_domain_p0} resp_net_out_rdy_p0;

	wire		{L} req_net_in_val_p1;
	wire		{Ctrl req_out_domain_p1} req_net_out_rdy_p1;
	wire		{Ctrl resp_in_domain_p1} resp_net_in_val_p1;
	wire		{Ctrl resp_out_domain_p1} resp_net_out_rdy_p1;

	// for single back mode, the cache side of things are padded to 0 other
	// than cache/mem 
	
    assign req_net_in_val_p0   = req_in_val_p0;
	assign req_net_out_rdy_p0  = p_single_bank ? { 32'h0, req_out_rdy_p0[0] } :
												req_out_rdy_p0;
	assign resp_net_in_val_p0  = p_single_bank ? { 32'h0, resp_in_val_p0[0] } :
												resp_in_val_p0;
	assign resp_net_out_rdy_p0 = resp_out_rdy_p0;	

	assign req_net_in_val_p1   = req_in_val_p1;
	assign req_net_out_rdy_p1  = p_single_bank ? { 32'h0, req_out_rdy_p1[0] } :
												req_out_rdy_p1;
	assign resp_net_in_val_p1  = p_single_bank ? { 32'h0, resp_in_val_p1[0] } :
												resp_in_val_p1;
	assign resp_net_out_rdy_p1 = resp_out_rdy_p1;	

	plab4_net_RingNet #(rqc+1, rqd, no, ns, 2) req_net
	(
		.clk				(clk),
		.reset				(reset),

        .req                (1),

		.in_val_p0			(req_net_in_val_p0),
		.in_rdy_p0			(req_in_rdy_p0),
        .in_domain_p0       (0),
		.in_msg_control_p0	(req_net_in_msg_control_p0),
		.in_msg_data_p0		(req_net_in_msg_data_p0),

		.out_val_p0			(req_out_val_p0),
		.out_rdy_p0			(req_net_out_rdy_p0),
		.out_msg_control_p0	(req_net_out_msg_control_p0),
		.out_msg_data_p0	(req_net_out_msg_data_p0),
        .out1_domain_p0     (req_out_domain_p0),

		.in_val_p1			(req_net_in_val_p1),
		.in_rdy_p1			(req_in_rdy_p1),
        .in_domain_p1       (1),
		.in_msg_control_p1	(req_net_in_msg_control_p1),
		.in_msg_data_p1		(req_net_in_msg_data_p1),

		.out_val_p1			(req_out_val_p1),
		.out_rdy_p1			(req_net_out_rdy_p1),
		.out_msg_control_p1	(req_net_out_msg_control_p1),
		.out_msg_data_p1	(req_net_out_msg_data_p1),
        .out1_domain_p1     (req_out_domain_p1)
	);

	// response network

	plab4_net_RingNet #(rsc+2,rsd,no,ns,2) resp_net
	(
		.clk				(clk),
		.reset				(reset),

        .req                (0),

		.in_val_p0			(resp_net_in_val_p0),
		.in_rdy_p0			(resp_in_rdy_p0),
        .in_domain_p0       (resp_in_domain_p0),
		.in_msg_control_p0	(resp_net_in_msg_control_p0),
		.in_msg_data_p0		(resp_net_in_msg_data_p0),

		.out_val_p0			(resp_out_val_p0),
		.out_rdy_p0			(resp_net_out_rdy_p0),
		.out_msg_control_p0	(resp_net_out_msg_control_p0),
		.out_msg_data_p0	(resp_net_out_msg_data_p0),
        .out1_domain_p0     (resp_out_domain_p0),

		.in_val_p1			(resp_net_in_val_p1),
		.in_rdy_p1			(resp_in_rdy_p1),
        .in_domain_p1       (resp_in_domain_p1),
		.in_msg_control_p1	(resp_net_in_msg_control_p1),
		.in_msg_data_p1		(resp_net_in_msg_data_p1),

		.out_val_p1			(resp_out_val_p1),
		.out_rdy_p1			(resp_net_out_rdy_p1),
		.out_msg_control_p1	(resp_net_out_msg_control_p1),
		.out_msg_data_p1	(resp_net_out_msg_data_p1),
        .out1_domain_p1     (resp_out_domain_p1)
	);

endmodule

`endif /* PLAB5_MCORE_MEM_NET_V */
	
