//========================================================================
// plab1-imul-CountZeros
//========================================================================
// This module is an 8 bit priority encoder that takes an input of 8 bits
// counts the number of trailing 0s and returns that number (is_zero will
// be 0). It is completely combinational. If the input == 0, the count
// will be 8

`ifndef PLAB1_IMUL_COUNT_ZEROS_V
`define PLAB1_IMUL_COUNT_ZEROS_V

module plab1_imul_CountZeros
(
 input      [7:0] to_be_counted,
 output reg [3:0] count
);

  always @ (*) begin
    if (to_be_counted[0])
      count = 0;
    else if (to_be_counted[1])
      count = 1;
    else if (to_be_counted[2])
      count = 2;
    else if (to_be_counted[3])
      count = 3;
    else if (to_be_counted[4])
      count = 4;
    else if (to_be_counted[5])
      count = 5;
    else if (to_be_counted[6])
      count = 6;
    else if (to_be_counted[7])
      count = 7;
    else if (to_be_counted == 0)
      count = 8;
  end

endmodule

`endif /* PLAB1_IMUL_COUNT_ZEROS_V */

