//========================================================================
// Debug Interface
//========================================================================

`ifndef PLAB5_MCORE_DEBUG_V
`define PLAB5_MCORE_DEBUG_V

`include "vc-regs.v"

module plab5_mcore_Debug
#(
	parameter p_cmd_nbits = 6,
	parameter p_num_cmds  = 8,
	parameter p_msg_nbits = 32
)
(
	input						clk,
	input						reset,

	// Request message interface
	
	output						req_val,
	input						req_rdy,
	output	[p_cmd_nbits-1:0]	req_cmd,

	// Response message interface
	
	input						resp_val,
	output						resp_rdy,
	input	[p_msg_nbits-1:0]	resp_msg,

	output						done
);

	//----------------------------------------------------------------------
	// Local parameters
	//----------------------------------------------------------------------	
	
	// The different types of Command 
	
	localparam PROC_ID		= 3'd0;
    localparam INST_TYPE	= 3'd1;

	// Size of a physical address for the command memory in bits
	
	localparam c_index_nbits = $clog2(p_num_cmds); 

	//----------------------------------------------------------------------
	// State
	//----------------------------------------------------------------------
	
	// Memory which stores commands to send
	
	reg	[p_cmd_nbits-1:0]	cmds[p_num_cmds-1:0];

	// Memory which stores response messages
	
	reg [p_msg_nbits-1:0]	msgs[p_num_cmds-1:0];

	// Index register pointing to next cmd to send
	
	wire						cmd_en;
	wire [c_index_nbits-1:0]	cmd_next;
	wire [c_index_nbits-1:0]	cmd_cur;

	vc_EnResetReg#(c_index_nbits,{c_index_nbits{1'b0}}) cmd_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(cmd_en),
		.d		(cmd_next),
		.q		(cmd_cur)
	);

	// Index register pointing to next response message to store
	
	wire						msg_en;
	wire [c_index_nbits-1:0]	msg_next;
	wire [c_index_nbits-1:0]	msg_cur;

	vc_EnResetReg#(c_index_nbits,{c_index_nbits{1'b0}}) msg_reg
	(
		.clk	(clk),
		.reset	(reset),
		.en		(msg_en),
		.d		(msg_next),
		.q		(msg_cur)
	);

	// Register reset
	
	reg reset_reg;
	always @( posedge clk )
		reset_reg <= reset;
	
	//----------------------------------------------------------------------
	// Combinational logic
	//----------------------------------------------------------------------
	
	// We use a behavioral hack to easily detect when we have gone off the 
	// end of the valid messages in the memory
	
	assign done = !reset_reg && ( cmds[cmd_cur] == {p_cmd_nbits{1'bx}} );

	// Always let module is able to receive data
	
	assign resp_rdy = 1'b1;
	assign req_val  = 1'b1;

	// Set the source message appropriately
	
	assign req_cmd = cmds[cmd_cur];

	// Source message interface is valid as long as we are not done
	
	// assign req_val = !reset_reg && !done;

	// The go signal is high when a message is transferred 
	
	wire req_go  = req_val && req_rdy;
	wire resp_go = resp_val && resp_rdy;

	// We bump the index pointer every time we sucessfully send a message,
	// otherwise the index stays the same
	
	assign cmd_en	= req_go;
	assign cmd_next = cmd_cur + 1'b1;

	assign msg_en	= resp_go;
	assign msg_next = msg_cur + 1'b1;

endmodule
`endif /* PLAB5_MCORE_DEBUG_V */
