//========================================================================
// Router Adaptive Input Terminal Ctrl
//========================================================================

`ifndef PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V
`define PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V

`include "plab4-net-AdaptiveRouteCompute.v"

module plab4_net_RouterAdaptiveInputTerminalCtrl
#(
  parameter p_router_id           = 0,
  parameter p_num_routers         = 8,
  parameter p_num_free_nbits      = 2,
  parameter p_num_free_chan_nbits = 2,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  [c_dest_nbits-1:0]         {L}	dest,

  input                             {L}	in_val,
  output                            {L}	in_rdy,

  input [p_num_free_nbits-1:0]      {L}	num_free0,
  input [p_num_free_nbits-1:0]      {L}	num_free2,

  input [p_num_free_chan_nbits-1:0] {L}	num_free_chan0,
  input [p_num_free_chan_nbits-1:0] {L}	num_free_chan2,

  output reg  [2:0]                 {L}	reqs,
  input       [2:0]                 {L}	grants,

  output							{L}	domain
);

  assign domain = p_router_id % 2;

  wire [1:0] {L}	route;

  //----------------------------------------------------------------------
  // Adaptive Route Compute
  //----------------------------------------------------------------------

  plab4_net_AdaptiveRouteCompute
  #(
    .p_router_id      (p_router_id),
    .p_num_routers    (p_num_routers),
    .p_num_free_nbits (p_num_free_chan_nbits)
  )
  route_compute
  (
    .dest           (dest),

    .num_free_chan0 (num_free_chan0),
    .num_free_chan2 (num_free_chan2),

    .route          (route)
  );

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // rdy is just a reductive OR of the AND of reqs and grants

  assign in_rdy = | (reqs & grants);

  always @(*) begin
    if (in_val) begin

      case (route)
        `ROUTE_PREV:  reqs = (num_free2 > 1) ? 3'b001 : 3'b000;
        `ROUTE_TERM:  reqs = 3'b010;
        `ROUTE_NEXT:  reqs = (num_free0 > 1) ? 3'b100 : 3'b000;
      endcase

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

endmodule

`endif  /* PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_V */
