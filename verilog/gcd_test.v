module gcd_test;
   reg        clk;
   reg        rst;
   reg [7:0]  a;
   reg [7:0]  b;
   wire [7:0] ret;
   wire       done;

   gcd dut(clk, rst, a, b, ret, done);

   always #1 clk = ~clk;

   initial begin
      begin
         $dumpfile("gcd_test.vcd");
         $dumpvars(0, gcd_test);
      end

      clk = 0;
      rst = 1;

      if (!$value$plusargs("a=%d", a)) begin
         $display("ERROR: please specify +a=<value> to start.");
         $finish;
      end
      if (!$value$plusargs("b=%d", b)) begin
         $display("ERROR: please specify +b=<value> to start.");
         $finish;
      end

      #2 rst = 0;

      wait (done) $display("ret=%d", ret);
      $finish;
   end
endmodule
