//========================================================================
// Hub module responsible for connection between processor and network
//========================================================================

`ifndef PLAB5_MCORE_PROCNET_HUB_V
`define PLAB5_MCORE_PROCNET_HUB_V
`include "vc-param-utils.v"

module plab5_mcore_procnet_hub
#(
	parameter p_num_cores  = 2,

	parameter memreq_nbits = 128,
    parameter memreq_cnbits = 32,
	parameter memreq_dnbits = 128,

	parameter memresp_nbits	= 128,
	parameter memresp_cnbits = 32,
	parameter memresp_dnbits = 128,

	//short name for params
	parameter mrq = memreq_nbits,
	parameter mrs = memresp_nbits
)
(
	// requests from processor
	
	// instruction requests

	input	[mrq-1:0]	proc_inst_req_data_d0,
	input				proc_inst_req_val_d0,
	output				proc_inst_req_rdy_d0,
	
	input	[mrq-1:0]	proc_inst_req_data_d1,
	input				proc_inst_req_val_d1,
	output				proc_inst_req_rdy_d1,
	
	// data requests
		
	input	[mrq-1:0]	proc_data_req_data_d0,
	input				proc_data_req_val_d0,
	output				proc_data_req_rdy_d0,
	
	input	[mrq-1:0]	proc_data_req_data_d1,
	input				proc_data_req_val_d1,
	output				proc_data_req_rdy_d1,

	// responses to proc_instessor side

	// instruction response
	
	output	[mrs-1:0]	proc_inst_resp_data_d0,
	output				proc_inst_resp_val_d0,
	input				proc_inst_resp_rdy_d0,

	output	[mrs-1:0]	proc_inst_resp_data_d1,
	output				proc_inst_resp_val_d1,
	input				proc_inst_resp_rdy_d1,	

	// data response
	
	output	[mrs-1:0]	proc_data_resp_data_d0,
	output				proc_data_resp_val_d0,
	input				proc_data_resp_rdy_d0,

	output	[mrs-1:0]	proc_data_resp_data_d1,
	output				proc_data_resp_val_d1,
	input				proc_data_resp_rdy_d1,	

	// vectors to the onchip-network
	
	output	[`VC_PORT_PICK_NBITS(mrq, p_num_cores)-1:0]	inst_net_req_in_msg,
	output	[`VC_PORT_PICK_NBITS(1,	p_num_cores)-1:0]	inst_net_req_in_val,
	input	[`VC_PORT_PICK_NBITS(1, p_num_cores)-1:0]	inst_net_req_in_rdy,

	input	[`VC_PORT_PICK_NBITS(mrs, p_num_cores)-1:0] inst_net_resp_out_msg,
	input	[`VC_PORT_PICK_NBITS(1,	p_num_cores)-1:0]	inst_net_resp_out_val,
	output	[`VC_PORT_PICK_NBITS(1, p_num_cores)-1:0]	inst_net_resp_out_rdy,	

	output	[`VC_PORT_PICK_NBITS(mrq, p_num_cores)-1:0]	data_net_req_in_msg,
	output	[`VC_PORT_PICK_NBITS(1,	p_num_cores)-1:0]	data_net_req_in_val,
	input	[`VC_PORT_PICK_NBITS(1, p_num_cores)-1:0]	data_net_req_in_rdy,

	input	[`VC_PORT_PICK_NBITS(mrs, p_num_cores)-1:0] data_net_resp_out_msg,
	input	[`VC_PORT_PICK_NBITS(1,	p_num_cores)-1:0]	data_net_resp_out_val,
	output	[`VC_PORT_PICK_NBITS(1, p_num_cores)-1:0]	data_net_resp_out_rdy
);

	assign inst_net_req_in_msg[`VC_PORT_PICK_FIELD(mrq,0)] = proc_inst_req_data_d0;
	assign inst_net_req_in_msg[`VC_PORT_PICK_FIELD(mrq,1)] = proc_inst_req_data_d1;
	assign inst_net_req_in_val[`VC_PORT_PICK_FIELD(1,0)]   = proc_inst_req_val_d0;
	assign inst_net_req_in_val[`VC_PORT_PICK_FIELD(1,1)]   = proc_inst_req_val_d1;
	assign proc_inst_req_rdy_d0 = inst_net_req_in_rdy[`VC_PORT_PICK_FIELD(1,0)];
	assign proc_inst_req_rdy_d1 = inst_net_req_in_rdy[`VC_PORT_PICK_FIELD(1,1)];

	assign data_net_req_in_msg[`VC_PORT_PICK_FIELD(mrq,0)] = proc_data_req_data_d0;
	assign data_net_req_in_msg[`VC_PORT_PICK_FIELD(mrq,1)] = proc_data_req_data_d1;
	assign data_net_req_in_val[`VC_PORT_PICK_FIELD(1,0)]   = proc_data_req_val_d0;
	assign data_net_req_in_val[`VC_PORT_PICK_FIELD(1,1)]   = proc_data_req_val_d1;
	assign proc_data_req_rdy_d0 = data_net_req_in_rdy[`VC_PORT_PICK_FIELD(1,0)];
	assign proc_data_req_rdy_d1 = data_net_req_in_rdy[`VC_PORT_PICK_FIELD(1,1)];

	assign proc_inst_resp_data_d0 = inst_net_resp_out_msg[`VC_PORT_PICK_FIELD(mrs,0)];
	assign proc_inst_resp_data_d1 = inst_net_resp_out_msg[`VC_PORT_PICK_FIELD(mrs,1)];
	assign proc_inst_resp_val_d0  = inst_net_resp_out_val[`VC_PORT_PICK_FIELD(1,0)];
	assign proc_inst_resp_val_d1  = inst_net_resp_out_val[`VC_PORT_PICK_FIELD(1,1)];
	assign inst_net_resp_out_rdy[`VC_PORT_PICK_FIELD(1,0)] = proc_inst_resp_rdy_d0;
	assign inst_net_resp_out_rdy[`VC_PORT_PICK_FIELD(1,1)] = proc_inst_resp_rdy_d1;

	assign proc_data_resp_data_d0 = data_net_resp_out_msg[`VC_PORT_PICK_FIELD(mrs,0)];
	assign proc_data_resp_data_d1 = data_net_resp_out_msg[`VC_PORT_PICK_FIELD(mrs,1)];
	assign proc_data_resp_val_d0  = data_net_resp_out_val[`VC_PORT_PICK_FIELD(1,0)];
	assign proc_data_resp_val_d1  = data_net_resp_out_val[`VC_PORT_PICK_FIELD(1,1)];
	assign data_net_resp_out_rdy[`VC_PORT_PICK_FIELD(1,0)] = proc_data_resp_rdy_d0;
	assign data_net_resp_out_rdy[`VC_PORT_PICK_FIELD(1,1)] = proc_data_resp_rdy_d1;

endmodule
`endif/*PLAB5_MCORE_PROC_NET_HUB_V*/
