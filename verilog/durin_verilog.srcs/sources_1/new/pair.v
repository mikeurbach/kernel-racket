`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2019 03:08:48 PM
// Design Name: 
// Module Name: pair
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


module pair #(parameter TYPE_WIDTH = 1, DATA_WIDTH = 8) ( 
  input clk,
  input start,
  input [2:0] operation,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] car,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] cdr,
  input [TYPE_WIDTH+DATA_WIDTH-1:0] ref_in,
  output reg busy,
  output reg [TYPE_WIDTH+DATA_WIDTH-1:0] ref_out
);
  localparam STATE_INIT = 0;
  localparam STATE_OP_CASE = 1;
  localparam STATE_NEW = 2;
  localparam STATE_CAR = 3;
  localparam STATE_CDR = 4;
  localparam STATE_SET_CAR = 5;
  localparam STATE_SET_CDR = 6;
 
  localparam OP_NEW = 0;
  localparam OP_CAR = 1;
  localparam OP_CDR = 2;
  localparam OP_SET_CAR = 3;
  localparam OP_SET_CDR = 4;
 
  reg [2:0] state = STATE_INIT, next_state;
  reg [TYPE_WIDTH+DATA_WIDTH-1:0] cars [2**DATA_WIDTH-1:0];
  reg [TYPE_WIDTH+DATA_WIDTH-1:0] cdrs [2**DATA_WIDTH-1:0];
  reg [DATA_WIDTH-1:0] next_addr = 8'd1;
   
  always @(posedge clk) begin
    // state register
    state <= next_state;
  
    // register and output assignments
    next_addr <= next_addr;
    busy <= busy;
    ref_out <= ref_out;
    
    case (next_state)
      STATE_INIT: begin
        busy <= 1'b0;
      end
      STATE_OP_CASE: begin
        busy <= 1'b1;
      end
      STATE_NEW: begin
        next_addr <= next_addr + 1;
        ref_out <= {1'b1,next_addr};
        cars[next_addr] <= car;
        cdrs[next_addr] <= cdr;
      end
      STATE_CAR: begin
        ref_out <= cars[ref_in[DATA_WIDTH-1:0]];
      end
      STATE_CDR: begin
        ref_out <= cdrs[ref_in[DATA_WIDTH-1:0]];
      end
      STATE_SET_CAR: begin
        ref_out <= ref_in;
        cars[ref_in[DATA_WIDTH-1:0]] <= car;
      end
      STATE_SET_CDR: begin
        ref_out <= ref_in;
        cdrs[ref_in[DATA_WIDTH-1:0]] <= cdr;
      end
      default: begin
      end
    endcase
  end
  
  always @(state or start or operation) begin
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
            next_state = STATE_NEW;
          OP_CAR:
            next_state = STATE_CAR;
          OP_CDR:
            next_state = STATE_CDR;
          OP_SET_CAR:
            next_state = STATE_SET_CAR;
          OP_SET_CDR:
            next_state = STATE_SET_CDR;
          default: begin
            next_state = STATE_INIT;
          end
        endcase
      STATE_NEW:
        next_state = STATE_INIT;
      STATE_CAR:
        next_state = STATE_INIT;
      STATE_CDR:
        next_state = STATE_INIT;
      STATE_SET_CAR:
        next_state = STATE_INIT;
      STATE_SET_CDR:
        next_state = STATE_INIT;
      default:
        next_state = state;
    endcase
  end
endmodule
