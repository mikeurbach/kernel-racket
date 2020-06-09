  module unit_rate_94159770261856 (
    input arg0,
    output signed [31:0] ret0,
    output ret1
  );
    wire signed [31:0] tmp0 = 32'd1;
    wire tmp1 = 1'b1;
    assign ret0 = tmp0;
    assign ret1 = tmp1;
  endmodule

  module unit_rate_94159770264240 (
    input signed [31:0] arg0,
    input arg1,
    input signed [31:0] arg2,
    input arg3,
    input arg4,
    output ret0,
    output ret1,
    output signed [31:0] ret2,
    output ret3
  );
    wire signed [31:0] tmp0 = arg0 + arg2;
    wire tmp1 = arg1 & arg3;
    wire tmp2 = arg4 & tmp1;
    assign ret0 = tmp2;
    assign ret1 = tmp2;
    assign ret2 = tmp0;
    assign ret3 = tmp1;
  endmodule

  module main (
    input signed [31:0] arg0,
    input arg1,
    input arg2,
    output ret0,
    output signed [31:0] ret1,
    output ret2
  );
    wire unit_rate_94159770264240_out_1_to_unit_rate_94159770261856_in_0;
    wire signed [31:0] unit_rate_94159770261856_out_0_to_unit_rate_94159770264240_in_2;
    wire signed [31:0] main_in_0_to_unit_rate_94159770264240_in_0;
    wire unit_rate_94159770261856_out_1_to_unit_rate_94159770264240_in_3;
    wire unit_rate_94159770264240_out_0_to_main_out_0;
    wire main_in_1_to_unit_rate_94159770264240_in_1;
    wire signed [31:0] unit_rate_94159770264240_out_2_to_main_out_1;
    wire main_in_2_to_unit_rate_94159770264240_in_4;
    wire unit_rate_94159770264240_out_3_to_main_out_2;
    unit_rate_94159770261856 instance_1 (
      .arg0(unit_rate_94159770264240_out_1_to_unit_rate_94159770261856_in_0),
      .ret0(unit_rate_94159770261856_out_0_to_unit_rate_94159770264240_in_2),
      .ret1(unit_rate_94159770261856_out_1_to_unit_rate_94159770264240_in_3)
    );
    unit_rate_94159770264240 instance_2 (
      .arg0(main_in_0_to_unit_rate_94159770264240_in_0),
      .arg1(main_in_1_to_unit_rate_94159770264240_in_1),
      .arg2(unit_rate_94159770261856_out_0_to_unit_rate_94159770264240_in_2),
      .arg3(unit_rate_94159770261856_out_1_to_unit_rate_94159770264240_in_3),
      .arg4(main_in_2_to_unit_rate_94159770264240_in_4),
      .ret0(unit_rate_94159770264240_out_0_to_main_out_0),
      .ret1(unit_rate_94159770264240_out_1_to_unit_rate_94159770261856_in_0),
      .ret2(unit_rate_94159770264240_out_2_to_main_out_1),
      .ret3(unit_rate_94159770264240_out_3_to_main_out_2)
    );
    assign main_in_0_to_unit_rate_94159770264240_in_0 = arg0;
    assign main_in_1_to_unit_rate_94159770264240_in_1 = arg1;
    assign main_in_2_to_unit_rate_94159770264240_in_4 = arg2;
    assign ret0 = unit_rate_94159770264240_out_0_to_main_out_0;
    assign ret1 = unit_rate_94159770264240_out_2_to_main_out_1;
    assign ret2 = unit_rate_94159770264240_out_3_to_main_out_2;
  endmodule

