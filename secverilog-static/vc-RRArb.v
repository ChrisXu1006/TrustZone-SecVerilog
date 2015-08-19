module vc_RRArb
#(
    parameter p_num_reqs = 3
)
(
    input   {L}  clk,
    input   {L}  reset,

    input  [p_num_reqs-1:0]  reqs,
    output [p_num_reqs-1:0]  grants
);

    reg [2:0]  {L} i;
    always @(*) begin
        case(reqs)
            3'b000: grants = 3'b000;
            3'b001: grants = 3'b001;
            3'b010: grants = 3'b010;
            3'b100: grants = 3'b100;
            3'b011: begin
                        i = $random % 2;
                        if ( i ) 
                            grants = 3'b001;
                        else
                            grants = 3'b010;
                    end
            3'b110: begin
                        i = $random % 2;
                        if ( i ) 
                            grants = 3'b010;
                        else
                            grants = 3'b100;
                    end
            3'b101: begin
                        i = $random % 2;
                        if ( i ) 
                            grants = 3'b001;
                        else
                            grants = 3'b100;
                    end
            3'b111: begin
                        i = $random % 3;
                        if ( i == 2'b00 )
                            grants = 3'b001;
                        else if ( i == 2'b01 )
                            grants = 3'b010;
                        else if ( i == 2'b10 )
                            grants = 3'b100;
                    end
        endcase
    end

endmodule
