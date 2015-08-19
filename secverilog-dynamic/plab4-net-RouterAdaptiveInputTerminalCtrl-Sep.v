//========================================================================
// Router Adaptive Input Terminal Ctrl
//========================================================================

`ifndef PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_SEP_V
`define PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_SEP_V

`include "plab4-net-AdaptiveRouteCompute.v"

module plab4_net_RouterAdaptiveInputTerminalCtrl_Sep
#(
  parameter p_router_id           = 0,
  parameter p_num_routers         = 8,
  parameter p_num_free_nbits      = 2,
  parameter p_num_free_chan_nbits = 2,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  [c_dest_nbits-1:0]         {Ctrl domain} dest,

  input                             {Ctrl domain} in_val,
  output                            {Ctrl domain} in_rdy,

  input [p_num_free_nbits-1:0]      {Ctrl domain} num_free0,
  input [p_num_free_nbits-1:0]      {Ctrl domain} num_free2,

  input [p_num_free_chan_nbits-1:0] {Ctrl domain} num_free_chan0,
  input [p_num_free_chan_nbits-1:0] {Ctrl domain} num_free_chan2,

  output							{Ctrl domain} reqs_p0,
  output							{Ctrl domain} reqs_p1,
  output							{Ctrl domain} reqs_p2,
  input			                    {Ctrl domain} grants_p0,
  input			                    {Ctrl domain} grants_p1,
  input			                    {Ctrl domain} grants_p2,

  input							    {L} domain
);


  wire [1:0] {Ctrl domain} route;

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
    .domain         (domain), 
    .dest           (dest),

    .num_free_chan0 (num_free_chan0),
    .num_free_chan2 (num_free_chan2),

    .route          (route)
  );

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  reg  [2:0] {Ctrl domain} reqs;
  wire [2:0] {Ctrl domain} grants;

  assign {reqs_p2, reqs_p1, reqs_p0} = reqs;
  assign grants = {grants_p2, grants_p1, grants_p0};
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

`endif  /* PLAB4_NET_ROUTER_ADAPTIVE_INPUT_TERMINAL_CTRL_SEP_V */

