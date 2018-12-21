module gcd_test;
   reg        clk;
   reg        start;
   reg [7:0]  a;
   reg [7:0]  b;
   wire [7:0] ret;
   wire       done;

   gcd dut(clk, start, a, b, done, ret);

   always #1 clk = ~clk;

   initial begin
      begin
         $dumpfile("gcd_test.vcd");
         $dumpvars(0, gcd_test);
      end

      clk = 0;
      start = 0;

      if (!$value$plusargs("a=%d", a)) begin
         $display("ERROR: please specify +a=<value> to start.");
         $finish;
      end
      if (!$value$plusargs("b=%d", b)) begin
         $display("ERROR: please specify +b=<value> to start.");
         $finish;
      end

      #2 start = 1;
      #3 start = 0;

      wait (done) $display("ret=%d", ret);
      $finish;
   end
endmodule
