//========================================================================
// plab4-net-Demux
//========================================================================

`ifndef PLAB4_NET_DEMUX_V
`define PLAB4_NET_DEMUX_V

module plab4_net_demux
#(
	parameter p_msg_cnbits = 32,
	parameter p_msg_dnbits = 32
)
(
	input						{L}	domain,

	input						{Ctrl domain}	out_val,
    output	reg					{D1}           in_val_d1,
	output	reg					{L}	            in_val_d2,

    input						{D1}            in_rdy_d1,
	input						{L}	            in_rdy_d2,
	output	reg					{Ctrl domain}	out_rdy,

	input [p_msg_cnbits-1:0]	{Ctrl domain}   out_msg_control,
	output[p_msg_cnbits-1:0]	{D1}            in_msg_control_d1,
	output[p_msg_cnbits-1:0]	{L}	            in_msg_control_d2,

	input [p_msg_dnbits-1:0]	{Data domain}	out_msg_data,
	output[p_msg_dnbits-1:0]	{D1}		    in_msg_data_d1,
	output[p_msg_dnbits-1:0]	{L}			    in_msg_data_d2
);
    reg	[p_msg_cnbits-1:0]		{D1}		    in_msg_control_d1;
    reg	[p_msg_cnbits-1:0]		{L}				in_msg_control_d2;

	reg [p_msg_dnbits-1:0]		{D1}			in_msg_data_d1;
	reg [p_msg_dnbits-1:0]		{D2}			in_msg_data_d2;

	// based on the domain signal passing correpsonding signal, the other
	// domain's related signals are set as zero
	
	always @(*) begin
	
		if ( domain == 1'b0 ) begin	
			in_val_d1 = out_val;
			in_val_d2 = 1'b0;

			out_rdy	  = in_rdy_d1;

			in_msg_control_d1 = out_msg_control;
			in_msg_data_d1	  = out_msg_data;

		end

		else if ( domain == 1'b1 ) begin
			in_val_d1 = 1'b0;
			in_val_d2 = out_val;

			out_rdy	  = in_rdy_d2;

			in_msg_control_d2 = out_msg_control;
			in_msg_data_d2	  = out_msg_data;
		end

		else if ( domain === 1'hx ) begin
			in_val_d1 = 1'b0;
			in_val_d2 = 1'b0;

			out_rdy = 1'b1;
		end

	end

endmodule

`endif /* PLAB4_NET_DEMUX_V */
