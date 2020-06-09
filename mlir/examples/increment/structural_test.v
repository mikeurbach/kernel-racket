`define assert(signal, value) \
  if(!(signal == value)) begin \
    $display("assertion failed! expected: %d, got: %d", value, signal); \
    $finish; \
  end

module main_test();
  reg signed [31:0] in;
  wire 		    in_valid = 1'b1;
  wire 		    out_ready = 1'b1;
  wire 		    in_ready;
  wire signed [31:0] out;
  wire 		     out_valid;
  
  main main_0(
    .arg0(in),
    .arg1(in_valid),
    .arg2(out_ready),
    .ret0(in_ready),
    .ret1(out),
    .ret2(out_valid)
    );

  initial begin
    assign in = 32'd420;

    `assert(in_ready, 1'b1);
    `assert(out, 32'd421);
    `assert(out_valid, 1'b1);

    assign in = -32'd69;

    `assert(in_ready, 1'b1);
    `assert(out, -32'd68);
    `assert(out_valid, 1'b1);

    $finish;
  end
endmodule // main_test
