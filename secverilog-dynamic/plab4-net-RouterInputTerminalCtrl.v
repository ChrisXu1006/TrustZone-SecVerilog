//========================================================================
// Router Input Terminal Ctrl
//========================================================================

`ifndef PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V
`define PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
`include "plab4-net-GreedyRouteCompute.v"
//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

module plab4_net_RouterInputTerminalCtrl
#(
  parameter p_router_id      = 0,
  parameter p_num_routers    = 8,
  parameter p_num_free_nbits = 2,

  // parameter not meant to be set outside this module

  parameter c_dest_nbits = $clog2( p_num_routers )

)
(
  input  [c_dest_nbits-1:0]    dest,

  input                        in_val,
  output                       in_rdy,

  input [p_num_free_nbits-1:0] num_free_west,
  input [p_num_free_nbits-1:0] num_free_east,

  output [2:0]                 reqs,
  input  [2:0]                 grants
);

  //+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++
// 
//   // add logic here
// 
//   assign in_rdy = 0;
//   assign reqs = 0;
// 
  //+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  wire [1:0] route;

  //----------------------------------------------------------------------
  // Greedy Route Compute
  //----------------------------------------------------------------------

  plab4_net_GreedyRouteCompute
  #(
    .p_router_id    (p_router_id),
    .p_num_routers  (p_num_routers)
  )
  route_compute
  (
    .dest           (dest),
    .route          (route)
  );

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // rdy is just a reductive OR of the AND of reqs and grants

  assign in_rdy = | (reqs & grants);

  reg [2:0] reqs;

  always @(*) begin
    if (in_val) begin

      case (route)
        // the following implements bubble flow control:
        `ROUTE_PREV:  reqs = (num_free_east > 1) ? 3'b001 : 3'b000;
        `ROUTE_TERM:  reqs = 3'b010;
        `ROUTE_NEXT:  reqs = (num_free_west > 1) ? 3'b100 : 3'b000;

        // the following doesn't implement bubble flow control:
        // `ROUTE_PREV:  reqs = 3'b001;
        // `ROUTE_TERM:  reqs = 3'b010;
        // `ROUTE_NEXT:  reqs = 3'b100;
      endcase

    end else begin
      // if !val, we don't request any output ports
      reqs = 3'b000;
    end
  end

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

endmodule

`endif  /* PLAB4_NET_ROUTER_INPUT_TERMINAL_CTRL_V */
