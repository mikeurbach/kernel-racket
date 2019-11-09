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
  reg [8:0] ref_in, parent_ref;
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
    ref_in = {1'b1, 8'd0};
    
    `call_module;
    
    ref_in = ref_out;
    parent_ref = ref_out;
        
    // bind some symbols 
    operation = environment_instance.OP_BIND;
    
    symbol = {1'b0, 8'd1};
    value = {1'b0, 8'd42};
    
    `call_module;
    
    symbol = {1'b0, 8'd2};
    value = {1'b0, 8'd69};
    
    `call_module;
    
    // lookup some symbols
    operation = environment_instance.OP_LOOKUP;
    
    symbol = {1'b0, 8'd1};
    
    `call_module;
        
    `assert(ref_out, {1'b0, 8'd42});
    
    symbol = {1'b0, 8'd2};
    
    `call_module;
    
    `assert(ref_out, {1'b0, 8'd69});

    symbol = {1'b0, 8'd3};
    
    `call_module;
    
    `assert(ref_out, {1'b1, 8'd0});
    
    // create a child environment (ref_in still points to the parent at this point)
    operation = environment_instance.OP_NEW;
    
    `call_module;
    
    ref_in = ref_out;
    
    // lookup some symbols in the child environment
    operation = environment_instance.OP_LOOKUP;
    
    symbol = {1'b0, 8'd1};
    
    `call_module;
        
    `assert(ref_out, {1'b0, 8'd42});
    
    symbol = {1'b0, 8'd2};
    
    `call_module;
    
    `assert(ref_out, {1'b0, 8'd69});

    symbol = {1'b0, 8'd3};
    
    `call_module;
    
    `assert(ref_out, {1'b1, 8'd0});
    
    // bind a new symbol in the child environment
    operation = environment_instance.OP_BIND;
    
    symbol = {1'b0, 8'd3};
    value = {1'b0, 8'd88};
    
    `call_module;
    
    // lookup the new symbol in the child environment
    operation = environment_instance.OP_LOOKUP;
    
    symbol = {1'b0, 8'd3};
    
    `call_module;
        
    `assert(ref_out, {1'b0, 8'd88});
    
    // lookup the new symbol in the parent environment (should be null)
    ref_in = parent_ref;
    
    `call_module;
        
    `assert(ref_out, {1'b1, 8'd0});
    
    $finish;
  end
endmodule