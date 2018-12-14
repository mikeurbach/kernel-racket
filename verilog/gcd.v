module gcd(clk, rst, a_in, b_in, ret_out, done_out);
   input        clk;
   input        rst;
   input [7:0]  a_in;
   input [7:0]  b_in;
   output [7:0] ret_out;
   output       done_out;

   localparam START      = 3'b001;
   localparam COMPUTE    = 3'b010;
   localparam DONE       = 3'b100;

   localparam START_IDX      = 0;
   localparam COMPUTE_IDX    = 1;
   localparam DONE_IDX       = 2;

   reg [2:0] state, state_next;
   reg [7:0] a;
   reg [7:0] b;
   reg [7:0] ret_out;
   reg       done_out;

   reg [7:0] a_next;
   reg [7:0] b_next;
   reg [7:0] ret_out_next;
   wire       done;

   assign done = b == 0;

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
             done_out <= done;
          end
     end

   always @(*)
     begin
        state_next = state;
        a_next = a;
        b_next = b;
        ret_out_next = ret_out;

        case(1'b1)
          state[START_IDX]: begin
             state_next = COMPUTE;
          end
          state[COMPUTE_IDX]: begin
             if (done)
               begin
                  state_next = DONE;
                  ret_out_next = a;
               end

             a_next = b;
             b_next = a % b;
          end
          state[DONE_IDX]: begin
          end
        endcase
     end
endmodule
