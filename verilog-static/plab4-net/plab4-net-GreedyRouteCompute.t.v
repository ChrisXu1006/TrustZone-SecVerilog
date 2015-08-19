//========================================================================
// Greedy Route Compute Unit Tests
//========================================================================

`include "plab4-net-GreedyRouteCompute.v"
`include "vc-test.v"

module top;
  `VC_TEST_SUITE_BEGIN( "plab4-net-GreedyRouteCompute" )

  //----------------------------------------------------------------------
  // Test greedy routing computation
  //----------------------------------------------------------------------

  reg  [2:0]  t1_dest;
  wire [1:0]  t1_route;

  plab4_net_GreedyRouteCompute
  #(
    .p_router_id    (2),
    .p_num_routers  (8)
  )
  t1_route_compute
  (
    .dest   (t1_dest ),
    .route  (t1_route)
  );

  // Helper task

  task t1
  (
    input [2:0]  dest,
    input [1:0]  route
  );
  begin
    t1_dest   = dest;
    #1;
    `VC_TEST_NOTE_INPUTS_1( dest );
    `VC_TEST_NET( t1_route,  route );
  end
  endtask

  // Test case

  `VC_TEST_CASE_BEGIN( 1, "greedy routing" )
  begin

    //  dest  route
    t1( 3'h0, `ROUTE_PREV );
    t1( 3'h1, `ROUTE_PREV );
    t1( 3'h2, `ROUTE_TERM );
    t1( 3'h3, `ROUTE_NEXT );
    t1( 3'h4, `ROUTE_NEXT );
    t1( 3'h5, `ROUTE_NEXT );
    // the other way around can be either PREV or NEXT
    t1( 3'h6, 2'b0?       );
    t1( 3'h7, `ROUTE_PREV );

  end
  `VC_TEST_CASE_END


  `VC_TEST_SUITE_END
endmodule


