module gcd(clk, rst, a_in, b_in, ret_out, done_out);
   input        clk;
   input        rst;
   input [7:0]  a_in;
   input [7:0]  b_in;
   output [7:0] ret_out;
   output       done_out;

   localparam START      = 5'b00001;
   localparam CHECK_DONE = 5'b00010;
   localparam COMPUTE    = 5'b00100;
   localparam REGISTER   = 5'b01000;
   localparam DONE       = 5'b10000;

   localparam START_IDX      = 0;
   localparam CHECK_DONE_IDX = 1;
   localparam COMPUTE_IDX    = 2;
   localparam REGISTER_IDX   = 3;
   localparam DONE_IDX       = 4;

   reg [4:0] state, state_next;
   reg [7:0] a, a_next;
   reg [7:0] b, b_next;
   reg [7:0] ret_out, ret_out_next;
   reg       done_out, done_out_next;
   wire      finished;

   assign finished = b == 0;

   always @(posedge clk)
     begin
        if (rst)
          begin
             state <= START;
             a <= a_in;
             b <= b_in;
             ret_out <= 0;
             done_out <= 1'b0;
          end
        else
          begin
             state <= state_next;
             a <= a_next;
             b <= b_next;
             ret_out <= ret_out_next;
             done_out <= done_out_next;
          end
     end

   always @(*)
     begin
        state_next = state;
        a_next = a;
        b_next = b;
        ret_out_next = ret_out;
        done_out_next = done_out;

        case(1'b1)
          state[START_IDX]: begin
             state_next = CHECK_DONE;
             a_next = a_in;
             b_next = b_in;
          end
          state[CHECK_DONE_IDX]: begin
             if (finished)
               state_next = REGISTER;
             else
               state_next = COMPUTE;
          end
          state[COMPUTE_IDX]: begin
             state_next = CHECK_DONE;
             a_next = b;
             b_next = a % b;
          end
          state[REGISTER_IDX]: begin
             state_next = DONE;
             ret_out_next = a;
             done_out_next = 1'b1;
          end
          state[DONE_IDX]: begin
          end
        endcase
     end
endmodule
