module unit_rate_1 (
  input arg0,
  output [31:0] return0,
  output return1
);
  assign return0 = 32'd1;
  assign return1 = 1'b1;
endmodule // unit_rate_1

module unit_rate_2 (
  input [31:0] arg0,
  input arg1,
  input [31:0] arg2,
  input arg3,
  input arg4
  output return0,
  output return1,
  output [31:0] return2,
  output return3
);
  wire wire0;
  wire wire1;
  wire wire2;
  assign wire0 = arg0 + arg2;
  assign wire1 = arg1 && arg3;
  assign wire2 = arg4 && wire1;
  assign return0 = wire2;
  assign return1 = wire2;
  assign return2 = wire0;
  assign return3 = wire1;
endmodule // unit_rate_2
