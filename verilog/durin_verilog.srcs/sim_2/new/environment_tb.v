`define call_module \
   start = 1'b1; \
   wait(busy) \
   start = 1'b0; \
   wait(!busy)

`define assert(signal, value) \
  if(!(signal == value)) begin \
    $display("assertion failed! expected: %d, got: %d", value, signal); \
    $finish; \
  end

module environment_tb;
  reg clk = 1'b0;
  reg start = 1'b0;
  reg [1:0] operation;
  reg [8:0] ref_in;
  reg [8:0] symbol;
  reg [8:0] value;
  wire busy;
  wire [8:0] ref_out;

  environment environment_instance(
    .clk(clk),
    .start(start),
    .operation(operation),
    .ref_in(ref_in),
    .symbol(symbol),
    .value(value),
    .busy(busy),
    .ref_out(ref_out)
  );

  always #10 clk = ~clk;

  initial begin
    // create empty environment
    #10
    operation = environment_instance.OP_NEW;
    
    `call_module;
    
    // bind some symbols 
    operation = environment_instance.OP_BIND;
    ref_in = ref_out;
    
    symbol = {1'b0, 8'd1};
    value = {1'b0, 8'd42};
    
    `call_module;
    
    symbol = {1'b0, 8'd2};
    value = {1'b0, 8'd69};
    
    `call_module;
        
    $finish;
  end
endmodule