//=========================================================================
// Programmable Interrupt Controller
//=========================================================================

`ifndef PLAB2_MCORE_PIC_V
`define PLAB2_MCORE_PIC_V

module plab2_proc_PIC#(
	parameter req_nums = 2,
	parameter data_len = 8
)
(
	input					{L}  clk,			// Clock
	input					{L}  reset,			// Reset

	input					{D1} intr_rq_p0,	// Interrupt request from processor0
	input					{D2} intr_rq_p1,	// Interrupt request from processor1
	input					{D1} intr_set_p0,	// Interrupt priority request from processor0
	input					{D2} intr_set_p1,	// Interrupt priority reqeust from processor1

	output	reg				{D1} intr_ack_p0,	// interrupt acknowledgement to processor0
	output  reg				{D2} intr_ack_p1,	// interrupt acknowledgement to processor1
	output	reg				{D1} intr_val_p0,	// interrupt request to processor0
	output	reg				{D2} intr_val_p1		// interrupt request to processor1
);
	
	//----------------------------------------------------------------------
	// State Definitions
	//----------------------------------------------------------------------
	
	localparam STATE_RESET				= 4'd0;
	localparam STATE_SETPRIORITY		= 4'd1;
	localparam STATE_STARTPRIORITY		= 4'd2;
	localparam STATE_PRIORITYREQ		= 4'd3;
	localparam STATE_PRIORITYACK		= 4'd4;
	localparam STATE_PRIORITYRESP		= 4'd5;

	// intermediate parameters
	reg	[3:0]	state_reg, state_next;			// state_register
	reg			intr_domain;					// intrreupt security domain
	reg			prior_reg;						// interrupt priorty register
	reg			intrPtr_reg, intrPtr_next;		// interrupt pointer
	reg	[3:0]	counter_reg, counter_next;

	// Main FSM of the controller. The state machine is clocked. The output
	// and next state logic are purely combinational
	always @(posedge clk) begin
		
		if ( reset ) begin
			state_reg	<= STATE_RESET;
		end

		else begin
			state_reg	<= state_next;
			counter_reg <= counter_next;
		end

	end

	// The next state logic and the output functions
	always @(*) begin

		state_next	= state_reg;
		intr_val_p0	= 1'b0;
		intr_val_p1 = 1'b0;

		case (state_reg)
			STATE_RESET: begin
				state_next  = STATE_SETPRIORITY;
				counter_next = 4'd0;
				intr_ack_p0	= 1'b0;
				intr_ack_p1 = 1'b0;
				intr_val_p0 = 1'b0;
				intr_val_p1 = 1'b0;
			end

			STATE_SETPRIORITY: begin
				if ( intr_set_p0 || intr_set_p1 ) begin 
					state_next = STATE_STARTPRIORITY;
					if ( intr_set_p0 )
						prior_reg = 1'b0;
					else if ( intr_set_p1 )
						prior_reg = 1'b1;
				end
			end

			STATE_STARTPRIORITY: begin
				if ( prior_reg == 1'b0 && counter_reg == 4'd0 ) begin
					if ( intr_rq_p0 ) begin
						intr_domain = 1'b0;
						state_next = STATE_PRIORITYACK;
					end
					else if ( intr_rq_p1 ) begin
						intr_domain = 1'b1;
						state_next = STATE_PRIORITYACK;
					end
				end
				
				else if ( counter_reg == 4'd0) begin
					if ( intr_rq_p1 ) begin
						intr_domain = 1'b1;
						state_next = STATE_PRIORITYACK;
					end
					else if ( intr_rq_p0 ) begin
						intr_domain = 1'b0;
						state_next = STATE_PRIORITYACK;
					end	
				end
				counter_next = counter_reg + 1;
				intr_val_p0 = 1'b0;
				intr_val_p1 = 1'b0;
			end

			STATE_PRIORITYACK: begin
				counter_next = 4'd0;
				state_next = STATE_PRIORITYRESP;
				if ( intr_domain == 1'b0 )
					intr_ack_p0 = 1'b1;
				else
					intr_ack_p1 = 1'b1;
			end

			STATE_PRIORITYRESP: begin
				intr_ack_p0	= 1'b0;
				intr_ack_p1 = 1'b0;
				if ( intr_domain == 1'b0 )
					intr_val_p0 = 1'b1;
				else
					intr_val_p1 = 1'b1;
				state_next = STATE_STARTPRIORITY;
			end
		endcase
	end

endmodule

`endif /*PLAB2_PROC_PIC*/
