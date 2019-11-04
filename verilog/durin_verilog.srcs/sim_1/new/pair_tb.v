`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2019 03:24:50 PM
// Design Name: 
// Module Name: pair_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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

module pair_tb;
  reg clk = 1'b0;
  reg start = 1'b0;
  reg [2:0] operation = 3'd0;
  reg [8:0] car;
  reg [8:0] cdr;
  reg [8:0] ref_in;
  wire busy;
  wire [8:0] ref_out;

  reg [8:0] ref;
    
  pair pair_instance(
    .clk(clk),
    .start(start),
    .operation(operation),
    .car(car),
    .cdr(cdr),
    .ref_in(ref_in),
    .busy(busy), 
    .ref_out(ref_out)
    );
    
  always #10 clk = ~clk;
    
  initial begin
    // writing in the pairs
    #10
    operation = 3'd0;
    
    car = {1'b0,8'd3};
    cdr = {1'b1,8'd0};
    
    `call_module;
    
    car = {1'b0,8'd2};
    cdr = ref_out;
    
    `call_module;
    
    car = {1'b0,8'd1};
    cdr = ref_out;
    
    `call_module;

    // reading back the pairs
    ref = ref_out;
    
    operation = 3'd1;
    ref_in = ref;
    
    `call_module;    
    
    `assert(ref_out, {1'b0, 8'd1});
    
    operation = 3'd2;
    ref_in = ref;
    
    `call_module;   

    ref = ref_out;
    
    operation = 3'd1;
    ref_in = ref;
    
    `call_module;
    
    `assert(ref_out, {1'b0, 8'd2});
    
    operation = 3'd2;
    ref_in = ref;
    
    `call_module;

    ref = ref_out;
    
    operation = 3'd1;
    ref_in = ref;
    
    `call_module;
    
    `assert(ref_out, {1'b0, 8'd3});
    
    operation = 3'd2;
    ref_in = ref;
     
    `call_module;
    
    `assert(ref_out, {1'b1, 8'd0});

    // setting car and cdr    
    operation = 3'd3;
    ref_in = ref;
    car = {1'b1, 8'd69};
    
    `call_module;
    
    ref = ref_out;
    
    operation = 3'd1;
    ref_in = ref;
    
    `call_module;
    
    `assert(ref_out, {1'b1, 8'd69});

    operation = 3'd4;
    ref_in = ref;
    cdr = {1'b1, 8'd42};
    
    `call_module;
    
    ref = ref_out;
    
    operation = 3'd2;
    ref_in = ref;
    
    `call_module;
    
    `assert(ref_out, {1'b1, 8'd42});

    $finish;
  end
endmodule