//========================================================================
// Hub module responsible for connection between network and memory
//========================================================================

`ifndef PLAB5_MCORE_NETMEM_HUB_V
`define PLAB5_MCORE_NETMEM_HUB_V
`include "vc-param-utils.v"

module plab5_mcore_netmem_hub
#(
	parameter p_num_cores  = 2,

	parameter memreq_nbits = 128,
    parameter memreq_cnbits = 32,
	parameter memreq_dnbits = 128,

	parameter memresp_nbits	= 128,
	parameter memresp_cnbits = 32,
	parameter memresp_dnbits = 128,

	//short name for params
	parameter p = p_num_cores,
	
	parameter mrq  = memreq_nbits,
	parameter mrqc = memreq_cnbits,
	parameter mrqd = memreq_dnbits,

	parameter mrs  = memresp_nbits,
	parameter mrsc = memresp_cnbits,
	parameter mrsd = memresp_dnbits
)
(
	// requests from network sides
	
	input	[`VC_PORT_PICK_NBITS(mrqc, p)-1:0]	inst_net_req_out_control,
	input	[`VC_PORT_PICK_NBITS(mrqd, p)-1:0]	inst_net_req_out_data,
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_req_out_val,
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_req_out_rdy,	
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_req_out_domain,

	input	[`VC_PORT_PICK_NBITS(mrqc, p)-1:0]	data_net_req_out_control,
	input	[`VC_PORT_PICK_NBITS(mrqd, p)-1:0]	data_net_req_out_data,
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_req_out_val,
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_req_out_rdy,	
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_req_out_domain,

	// responses to network sides
	
	output	[`VC_PORT_PICK_NBITS(mrsc, p)-1:0]	inst_net_resp_in_control,
	output	[`VC_PORT_PICK_NBITS(mrsd, p)-1:0]	inst_net_resp_in_data,
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_resp_in_val,
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_resp_in_rdy,	
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		inst_net_resp_in_domain,

	output	[`VC_PORT_PICK_NBITS(mrsc, p)-1:0]	data_net_resp_in_control,
	output	[`VC_PORT_PICK_NBITS(mrsd, p)-1:0]	data_net_resp_in_data,
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_resp_in_val,
	input	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_resp_in_rdy,	
	output	[`VC_PORT_PICK_NBITS(1, p)-1:0]		data_net_resp_in_domain,

	// requests to memory side
	
	output	[mrqc-1:0]	inst_memreq0_control,
	output	[mrqd-1:0]	inst_memreq0_data,
	output				inst_memreq0_val,
	input				inst_memreq0_rdy,
	output				inst_memreq0_domain,
	
	output	[mrqc-1:0]	inst_memreq1_control,
	output	[mrqd-1:0]	inst_memreq1_data,
	output				inst_memreq1_val,
	input				inst_memreq1_rdy,
	output				inst_memreq1_domain,

	output	[mrqc-1:0]	data_memreq0_control,
	output	[mrqd-1:0]	data_memreq0_data,
	output				data_memreq0_val,
	input				data_memreq0_rdy,
	output				data_memreq0_domain,
	
	output	[mrqc-1:0]	data_memreq1_control,
	output	[mrqd-1:0]	data_memreq1_data,
	output				data_memreq1_val,
	input				data_memreq1_rdy,
	output				data_memreq1_domain,

	// responses from memory side
	
	input	[mrsc-1:0]	inst_memresp0_control,
	input	[mrsd-1:0]	inst_memresp0_data,
	input				inst_memresp0_val,
	output				inst_memresp0_rdy,
	input				inst_memresp0_domain,

	input	[mrsc-1:0]	inst_memresp1_control,
	input	[mrsd-1:0]	inst_memresp1_data,
	input				inst_memresp1_val,
	output				inst_memresp1_rdy,
	input				inst_memresp1_domain,

	input	[mrsc-1:0]	data_memresp0_control,
	input	[mrsd-1:0]	data_memresp0_data,
	input				data_memresp0_val,
	output				data_memresp0_rdy,
	input				data_memresp0_domain,

	input	[mrsc-1:0]	data_memresp1_control,
	input	[mrsd-1:0]	data_memresp1_data,
	input				data_memresp1_val,
	output				data_memresp1_rdy,
	input				data_memresp1_domain
);

	assign inst_memreq0_control = inst_net_req_out_control[`VC_PORT_PICK_FIELD(mrqc,0)];
	assign inst_memreq0_data	= inst_net_req_out_data[`VC_PORT_PICK_FIELD(mrqd,0)];
	assign inst_memreq0_val		= inst_net_req_out_val[`VC_PORT_PICK_FIELD(1,0)];
	assign inst_net_req_out_rdy[`VC_PORT_PICK_FIELD(1,0)] = inst_memreq0_rdy;
	assign inst_memreq0_domain	= inst_net_req_out_domain[`VC_PORT_PICK_FIELD(1,0)];

	assign inst_memreq1_control = inst_net_req_out_control[`VC_PORT_PICK_FIELD(mrqc,1)];
	assign inst_memreq1_data	= inst_net_req_out_data[`VC_PORT_PICK_FIELD(mrqd,1)];
	assign inst_memreq1_val		= inst_net_req_out_val[`VC_PORT_PICK_FIELD(1,1)];
	assign inst_net_req_out_rdy[`VC_PORT_PICK_FIELD(1,1)] = inst_memreq1_rdy;
	assign inst_memreq1_domain	= inst_net_req_out_domain[`VC_PORT_PICK_FIELD(1,1)];

	assign data_memreq0_control = data_net_req_out_control[`VC_PORT_PICK_FIELD(mrqc,0)];
	assign data_memreq0_data	= data_net_req_out_data[`VC_PORT_PICK_FIELD(mrqd,0)];
	assign data_memreq0_val		= data_net_req_out_val[`VC_PORT_PICK_FIELD(1,0)];
	assign data_net_req_out_rdy[`VC_PORT_PICK_FIELD(1,0)] = data_memreq0_rdy;
	assign data_memreq0_domain	= data_net_req_out_domain[`VC_PORT_PICK_FIELD(1,0)];

	assign data_memreq1_control = data_net_req_out_control[`VC_PORT_PICK_FIELD(mrqc,1)];
	assign data_memreq1_data	= data_net_req_out_data[`VC_PORT_PICK_FIELD(mrqd,1)];
	assign data_memreq1_val		= data_net_req_out_val[`VC_PORT_PICK_FIELD(1,1)];
	assign data_net_req_out_rdy[`VC_PORT_PICK_FIELD(1,1)] = data_memreq1_rdy;
	assign data_memreq1_domain	= data_net_req_out_domain[`VC_PORT_PICK_FIELD(1,1)];

	assign inst_net_resp_in_control[`VC_PORT_PICK_FIELD(mrsc,0)] = inst_memresp0_control;
	assign inst_net_resp_in_data[`VC_PORT_PICK_FIELD(mrsd,0)] = inst_memresp0_data;
	assign inst_net_resp_in_val[`VC_PORT_PICK_FIELD(1,0)] = inst_memresp0_val;
	assign inst_memresp0_rdy = inst_net_resp_in_rdy[`VC_PORT_PICK_FIELD(1,0)];
	assign inst_net_resp_in_domain[`VC_PORT_PICK_FIELD(1,0)] = inst_memresp0_domain;

	assign inst_net_resp_in_control[`VC_PORT_PICK_FIELD(mrsc,1)] = inst_memresp1_control;
	assign inst_net_resp_in_data[`VC_PORT_PICK_FIELD(mrsd,1)] = inst_memresp1_data;
	assign inst_net_resp_in_val[`VC_PORT_PICK_FIELD(1,1)] = inst_memresp1_val;
	assign inst_memresp1_rdy = inst_net_resp_in_rdy[`VC_PORT_PICK_FIELD(1,1)];
	assign inst_net_resp_in_domain[`VC_PORT_PICK_FIELD(1,1)] = inst_memresp1_domain;

	assign data_net_resp_in_control[`VC_PORT_PICK_FIELD(mrsc,0)] = data_memresp0_control;
	assign data_net_resp_in_data[`VC_PORT_PICK_FIELD(mrsd,0)] = data_memresp0_data;
	assign data_net_resp_in_val[`VC_PORT_PICK_FIELD(1,0)] = data_memresp0_val;
	assign data_memresp0_rdy = data_net_resp_in_rdy[`VC_PORT_PICK_FIELD(1,0)];
	assign data_net_resp_in_domain[`VC_PORT_PICK_FIELD(1,0)] = data_memresp0_domain;

	assign data_net_resp_in_control[`VC_PORT_PICK_FIELD(mrsc,1)] = data_memresp1_control;
	assign data_net_resp_in_data[`VC_PORT_PICK_FIELD(mrsd,1)] = data_memresp1_data;
	assign data_net_resp_in_val[`VC_PORT_PICK_FIELD(1,1)] = data_memresp1_val;
	assign data_memresp1_rdy = data_net_resp_in_rdy[`VC_PORT_PICK_FIELD(1,1)];
	assign data_net_resp_in_domain[`VC_PORT_PICK_FIELD(1,1)] = data_memresp1_domain;

endmodule
`endif /* PLAB5_MCORE_NETMEM_HUB_V */
