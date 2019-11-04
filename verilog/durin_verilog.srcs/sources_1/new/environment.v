`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2019 11:05:01 AM
// Design Name: 
// Module Name: environment
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


module environment #(parameter TYPE_WIDTH = 1, DATA_WIDTH = 8) (
  input clk,
  input start,
  input [1:0] operation,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] ref_in,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] symbol,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] value,
  output reg busy,
  output reg [TYPE_WIDTH+DATA_WIDTH-1:0] ref_out
);
  localparam STATE_INIT = 0;
  localparam STATE_OP_CASE = 1;
  localparam STATE_NEW_ALLOC = 2;
  localparam STATE_NEW_WAIT_BUSY = 3;
  localparam STATE_NEW_WAIT_DONE = 4;
  localparam STATE_BIND_ALLOC_TUPLE = 5;
  localparam STATE_BIND_ALLOC_TUPLE_WAIT_BUSY = 6;
  localparam STATE_BIND_ALLOC_TUPLE_WAIT_DONE = 7;
  localparam STATE_BIND_LOAD_CAR = 8;
  localparam STATE_BIND_LOAD_CAR_WAIT_BUSY = 9;
  localparam STATE_BIND_LOAD_CAR_WAIT_DONE = 10;
  localparam STATE_BIND_ALLOC_LIST = 11;
  localparam STATE_BIND_ALLOC_LIST_WAIT_BUSY = 12;
  localparam STATE_BIND_ALLOC_LIST_WAIT_DONE = 13;
  localparam STATE_BIND_UPDATE_CAR = 14;
  localparam STATE_BIND_UPDATE_CAR_WAIT_BUSY = 15;
  localparam STATE_BIND_UPDATE_CAR_WAIT_DONE = 16;

  localparam OP_NEW = 0;
  localparam OP_BIND = 1;
  localparam OP_LOOKUP = 2;

  reg [4:0] state, next_state;
  
  reg [TYPE_WIDTH+DATA_WIDTH-1:0] tuple_ref;
  
  // instantiate pair module
  reg pair_start;
  reg [2:0] pair_operation;
  reg [TYPE_WIDTH+DATA_WIDTH-1:0] pair_car, pair_cdr, pair_ref_in;
  wire [TYPE_WIDTH+DATA_WIDTH-1:0] pair_ref_out;
  wire pair_busy;
  
  pair #(.TYPE_WIDTH(TYPE_WIDTH), .DATA_WIDTH(DATA_WIDTH)) pair_instance(
    .clk(clk),
    .start(pair_start),
    .operation(pair_operation),
    .car(pair_car),
    .cdr(pair_cdr),
    .ref_in(pair_ref_in),
    .busy(pair_busy),
    .ref_out(pair_ref_out)
  );
  
  always @(posedge clk) begin
    // state register
    state <= next_state;
  
    // register and output assignments
    busy <= busy;
    ref_out <= ref_out;
    pair_start <= pair_start;
    pair_operation <= pair_operation;
    pair_car <= pair_car;
    pair_cdr <= pair_cdr;
    pair_ref_in <= pair_ref_in;
 
    case (next_state)
      STATE_INIT: begin
        busy <= 1'b0;
      end
      STATE_OP_CASE: begin
        busy <= 1'b1;
      end        
      STATE_NEW_ALLOC: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= {1'b1, 8'd0};
        pair_cdr <= {1'b1, 8'd0};
      end
      STATE_NEW_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_NEW_WAIT_DONE: begin
        ref_out <= pair_ref_out;
      end
      STATE_BIND_ALLOC_TUPLE: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= symbol;
        pair_cdr <= value;
      end
      STATE_BIND_ALLOC_TUPLE_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_BIND_ALLOC_TUPLE_WAIT_DONE: begin
        tuple_ref <= pair_ref_out;
      end
      STATE_BIND_LOAD_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CAR;
        pair_ref_in <= ref_in;
      end
      STATE_BIND_LOAD_CAR_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_BIND_LOAD_CAR_WAIT_DONE: begin
      end
      STATE_BIND_ALLOC_LIST: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= tuple_ref;
        pair_cdr <= pair_ref_out;
      end
      STATE_BIND_ALLOC_LIST_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_BIND_ALLOC_LIST_WAIT_DONE: begin
      end
      STATE_BIND_UPDATE_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_SET_CAR;
        pair_ref_in <= ref_in;
        pair_car <= pair_ref_out;
      end
      STATE_BIND_UPDATE_CAR_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_BIND_UPDATE_CAR_WAIT_DONE: begin
      end
      default: begin
      end
    endcase 
  end

  always @(state or start or operation or pair_busy) begin
    // next state logic
    case (state)
      STATE_INIT:
        if (start)
          next_state = STATE_OP_CASE;
        else
          next_state = STATE_INIT;
      STATE_OP_CASE:
        case (operation)
          OP_NEW:
            next_state = STATE_NEW_ALLOC;
          OP_BIND:
            next_state = STATE_BIND_ALLOC_TUPLE;
          default:
            next_state = STATE_INIT;
        endcase
      STATE_NEW_ALLOC:
        next_state = STATE_NEW_WAIT_BUSY;
      STATE_NEW_WAIT_BUSY:
        if (!pair_busy)
          next_state = STATE_NEW_WAIT_BUSY;
        else
          next_state = STATE_NEW_WAIT_DONE;
      STATE_NEW_WAIT_DONE:
        if (pair_busy)
          next_state = STATE_NEW_WAIT_DONE;
        else
          next_state = STATE_INIT;
      STATE_BIND_ALLOC_TUPLE:
        next_state = STATE_BIND_ALLOC_TUPLE_WAIT_BUSY;
      STATE_BIND_ALLOC_TUPLE_WAIT_BUSY:
        if (!pair_busy)
          next_state = STATE_BIND_ALLOC_TUPLE_WAIT_BUSY;
        else
          next_state = STATE_BIND_ALLOC_TUPLE_WAIT_DONE;
      STATE_BIND_ALLOC_TUPLE_WAIT_DONE:
        if (pair_busy)
          next_state = STATE_BIND_ALLOC_TUPLE_WAIT_DONE;
        else
          next_state = STATE_BIND_LOAD_CAR;
      STATE_BIND_LOAD_CAR:
        next_state = STATE_BIND_LOAD_CAR_WAIT_BUSY;
      STATE_BIND_LOAD_CAR_WAIT_BUSY:
         if (!pair_busy)
          next_state = STATE_BIND_LOAD_CAR_WAIT_BUSY;
        else
          next_state = STATE_BIND_LOAD_CAR_WAIT_DONE;
      STATE_BIND_LOAD_CAR_WAIT_DONE:
        if (pair_busy)
          next_state = STATE_BIND_LOAD_CAR_WAIT_DONE;
        else
          next_state = STATE_BIND_ALLOC_LIST;
      STATE_BIND_ALLOC_LIST:
        next_state = STATE_BIND_ALLOC_LIST_WAIT_BUSY;
      STATE_BIND_ALLOC_LIST_WAIT_BUSY:
        if (!pair_busy)
          next_state = STATE_BIND_ALLOC_LIST_WAIT_BUSY;
        else
          next_state = STATE_BIND_ALLOC_LIST_WAIT_DONE;
      STATE_BIND_ALLOC_LIST_WAIT_DONE:
        if (pair_busy)
          next_state = STATE_BIND_ALLOC_LIST_WAIT_DONE;
        else
          next_state = STATE_BIND_UPDATE_CAR;
      STATE_BIND_UPDATE_CAR:
        next_state = STATE_BIND_UPDATE_CAR_WAIT_BUSY;
      STATE_BIND_UPDATE_CAR_WAIT_BUSY:
        if (!pair_busy)
          next_state = STATE_BIND_UPDATE_CAR_WAIT_BUSY;
        else
          next_state = STATE_BIND_UPDATE_CAR_WAIT_DONE;
      STATE_BIND_UPDATE_CAR_WAIT_DONE:
        if (pair_busy)
          next_state = STATE_BIND_UPDATE_CAR_WAIT_DONE;
        else
          next_state = STATE_INIT;
      default:
        next_state = STATE_INIT;
    endcase
  end
endmodule