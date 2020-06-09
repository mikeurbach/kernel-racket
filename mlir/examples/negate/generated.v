  module unit_rate_94412886489792 (
    input signed [31:0] arg0,
    input arg1,
    input arg2,
    output ret0,
    output signed [31:0] ret1,
    output ret2
  );
    wire signed [31:0] tmp0 = -arg0;
    wire tmp1 = arg2 & arg1;
    assign ret0 = tmp1;
    assign ret1 = tmp0;
    assign ret2 = arg1;
  endmodule

  module main (
    input signed [31:0] arg0,
    input arg1,
    input arg2,
    output ret0,
    output signed [31:0] ret1,
    output ret2
  );
    wire main_in_2_to_unit_rate_94412886489792_in_2;
    wire unit_rate_94412886489792_out_2_to_main_out_2;
    wire signed [31:0] main_in_0_to_unit_rate_94412886489792_in_0;
    wire unit_rate_94412886489792_out_0_to_main_out_0;
    wire main_in_1_to_unit_rate_94412886489792_in_1;
    wire signed [31:0] unit_rate_94412886489792_out_1_to_main_out_1;
    unit_rate_94412886489792 instance_1 (
      .arg0(main_in_0_to_unit_rate_94412886489792_in_0),
      .arg1(main_in_1_to_unit_rate_94412886489792_in_1),
      .arg2(main_in_2_to_unit_rate_94412886489792_in_2),
      .ret0(unit_rate_94412886489792_out_0_to_main_out_0),
      .ret1(unit_rate_94412886489792_out_1_to_main_out_1),
      .ret2(unit_rate_94412886489792_out_2_to_main_out_2)
    );
    assign main_in_0_to_unit_rate_94412886489792_in_0 = arg0;
    assign main_in_1_to_unit_rate_94412886489792_in_1 = arg1;
    assign main_in_2_to_unit_rate_94412886489792_in_2 = arg2;
    assign ret0 = unit_rate_94412886489792_out_0_to_main_out_0;
    assign ret1 = unit_rate_94412886489792_out_1_to_main_out_1;
    assign ret2 = unit_rate_94412886489792_out_2_to_main_out_2;
  endmodule

