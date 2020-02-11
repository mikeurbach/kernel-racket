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
  localparam STATE_PAIR_WAIT_BUSY = 2;
  localparam STATE_PAIR_WAIT_DONE = 3;
  localparam STATE_NEW_ALLOC = 4;
  localparam STATE_NEW_DONE = 5;
  localparam STATE_BIND_ALLOC_TUPLE = 6;
  localparam STATE_BIND_LOAD_CAR = 7;
  localparam STATE_BIND_ALLOC_LIST = 8;
  localparam STATE_BIND_UPDATE_CAR = 9;
  localparam STATE_BIND_DONE = 10;
  localparam STATE_LOOKUP_STORE_ENV_REF = 11;
  localparam STATE_LOOKUP_LOAD_REF_CAR = 12;
  localparam STATE_LOOKUP_UPDATE_LIST_REF = 13;
  localparam STATE_LOOKUP_LIST_REF_CHECK = 14;
  localparam STATE_LOOKUP_LOAD_LIST_CAR = 15;
  localparam STATE_LOOKUP_UPDATE_TUPLE_REF = 16;
  localparam STATE_LOOKUP_LOAD_TUPLE_CAR = 17;
  localparam STATE_LOOKUP_SYMBOL_CHECK = 18;
  localparam STATE_LOOKUP_LOAD_LIST_CDR = 19;
  localparam STATE_LOOKUP_LOAD_TUPLE_CDR = 20;
  localparam STATE_LOOKUP_LOAD_REF_CDR = 21;
  localparam STATE_LOOKUP_UPDATE_ENV_REF = 22;
  localparam STATE_LOOKUP_REF_CHECK = 23;
  localparam STATE_LOOKUP_DONE = 24;

  localparam OP_NEW = 0;
  localparam OP_BIND = 1;
  localparam OP_LOOKUP = 2;

  reg [5:0] state, next_state, pair_continuation;
  
  reg [TYPE_WIDTH+DATA_WIDTH-1:0] env_ref, list_ref, tuple_ref;
  
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
    env_ref <= env_ref;
    list_ref <= list_ref;
    tuple_ref <= tuple_ref;
    pair_start <= pair_start;
    pair_operation <= pair_operation;
    pair_car <= pair_car;
    pair_cdr <= pair_cdr;
    pair_ref_in <= pair_ref_in;
    pair_continuation <= pair_continuation;
 
    case (next_state)
      STATE_INIT: begin
        busy <= 1'b0;
      end
      STATE_OP_CASE: begin
        busy <= 1'b1;
      end        
      STATE_PAIR_WAIT_BUSY: begin
        pair_start <= 1'b0;
      end
      STATE_PAIR_WAIT_DONE: begin
      end
      STATE_NEW_ALLOC: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= {1'b1, 8'd0};
        pair_cdr <= ref_in;
      end
      STATE_NEW_DONE: begin
        ref_out <= pair_ref_out;
      end
      STATE_BIND_ALLOC_TUPLE: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= symbol;
        pair_cdr <= value;
      end
      STATE_BIND_LOAD_CAR: begin
        tuple_ref <= pair_ref_out;
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CAR;
        pair_ref_in <= ref_in;
      end
      STATE_BIND_ALLOC_LIST: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_NEW;
        pair_car <= tuple_ref;
        pair_cdr <= pair_ref_out;
      end
      STATE_BIND_UPDATE_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_SET_CAR;
        pair_ref_in <= ref_in;
        pair_car <= pair_ref_out;
      end
      STATE_BIND_DONE: begin
      end
      STATE_LOOKUP_STORE_ENV_REF: begin
        env_ref <= ref_in;
      end
      STATE_LOOKUP_LOAD_REF_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CAR;
        pair_ref_in <= env_ref;
      end
      STATE_LOOKUP_UPDATE_LIST_REF: begin
        list_ref <= pair_ref_out;
      end
      STATE_LOOKUP_LIST_REF_CHECK: begin
      end
      STATE_LOOKUP_LOAD_LIST_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CAR;
        pair_ref_in <= list_ref;
      end
      STATE_LOOKUP_UPDATE_TUPLE_REF: begin
        tuple_ref <= pair_ref_out;
      end
      STATE_LOOKUP_LOAD_TUPLE_CAR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CAR;
        pair_ref_in <= tuple_ref;
      end
      STATE_LOOKUP_SYMBOL_CHECK: begin
      end
      STATE_LOOKUP_LOAD_LIST_CDR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CDR;
        pair_ref_in <= list_ref;
      end
      STATE_LOOKUP_LOAD_TUPLE_CDR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CDR;
        pair_ref_in <= tuple_ref;
      end
      STATE_LOOKUP_LOAD_REF_CDR: begin
        pair_start <= 1'b1;
        pair_operation <= pair_instance.OP_CDR;
        pair_ref_in <= env_ref;
      end
      STATE_LOOKUP_UPDATE_ENV_REF: begin
        env_ref <= pair_ref_out;
      end
      STATE_LOOKUP_REF_CHECK: begin
      end
      STATE_LOOKUP_DONE: begin
        ref_out <= pair_ref_out;
      end
      default: begin
      end
    endcase 
  end

  always @(state or start or operation or pair_busy) begin
    // next state logic
    case (state)
      STATE_INIT: begin
        if (start)
          next_state = STATE_OP_CASE;
        else
          next_state = STATE_INIT;
      end 
      STATE_OP_CASE: begin
        case (operation)
          OP_NEW:
            next_state = STATE_NEW_ALLOC;
          OP_BIND:
            next_state = STATE_BIND_ALLOC_TUPLE;
          OP_LOOKUP:
            next_state = STATE_LOOKUP_STORE_ENV_REF;
          default:
            next_state = STATE_INIT;
        endcase
      end
      STATE_PAIR_WAIT_BUSY: begin
        if (!pair_busy)
          next_state = STATE_PAIR_WAIT_BUSY;
        else
          next_state = STATE_PAIR_WAIT_DONE;
      end
      STATE_PAIR_WAIT_DONE: begin
        if (pair_busy)
          next_state = STATE_PAIR_WAIT_DONE;
        else
          next_state = pair_continuation;
      end
      STATE_NEW_ALLOC: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_NEW_DONE;
      end
      STATE_NEW_DONE: begin
        next_state = STATE_INIT;
      end
      STATE_BIND_ALLOC_TUPLE: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_BIND_LOAD_CAR;
      end
      STATE_BIND_LOAD_CAR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_BIND_ALLOC_LIST;
      end
      STATE_BIND_ALLOC_LIST: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_BIND_UPDATE_CAR;
      end
      STATE_BIND_UPDATE_CAR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_BIND_DONE;
      end
      STATE_BIND_DONE: begin
        next_state = STATE_INIT;
      end
      STATE_LOOKUP_STORE_ENV_REF: begin
        next_state = STATE_LOOKUP_LOAD_REF_CAR;
      end
      STATE_LOOKUP_LOAD_REF_CAR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_UPDATE_LIST_REF;
      end
      STATE_LOOKUP_UPDATE_LIST_REF: begin
        next_state = STATE_LOOKUP_LIST_REF_CHECK;
      end
      STATE_LOOKUP_LIST_REF_CHECK: begin
        if (list_ref == {1'b1, 8'd0})
          next_state = STATE_LOOKUP_LOAD_REF_CDR;
        else
          next_state = STATE_LOOKUP_LOAD_LIST_CAR;
      end
      STATE_LOOKUP_LOAD_LIST_CAR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_UPDATE_TUPLE_REF;
      end
      STATE_LOOKUP_UPDATE_TUPLE_REF: begin
        next_state = STATE_LOOKUP_LOAD_TUPLE_CAR;
      end
      STATE_LOOKUP_LOAD_TUPLE_CAR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_SYMBOL_CHECK;
      end
      STATE_LOOKUP_SYMBOL_CHECK: begin
        if (pair_ref_out == symbol)
          next_state = STATE_LOOKUP_LOAD_TUPLE_CDR;
        else
          next_state = STATE_LOOKUP_LOAD_LIST_CDR;
      end
      STATE_LOOKUP_LOAD_LIST_CDR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_UPDATE_LIST_REF;
      end
      STATE_LOOKUP_LOAD_TUPLE_CDR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_DONE;
      end
      STATE_LOOKUP_LOAD_REF_CDR: begin
        next_state = STATE_PAIR_WAIT_BUSY;
        pair_continuation = STATE_LOOKUP_UPDATE_ENV_REF;
      end
      STATE_LOOKUP_UPDATE_ENV_REF: begin
        next_state = STATE_LOOKUP_REF_CHECK;
      end
      STATE_LOOKUP_REF_CHECK: begin
        if (env_ref == {1'b1, 8'd0})
          next_state = STATE_LOOKUP_DONE;
        else
          next_state = STATE_LOOKUP_LOAD_REF_CAR;
      end
      STATE_LOOKUP_DONE: begin
        next_state = STATE_INIT;
      end
      default:
        next_state = STATE_INIT;
    endcase
  end
endmodule
