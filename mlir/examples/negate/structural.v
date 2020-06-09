module dataflow_unit_rate_94442178316576 (
  input signed [31:0]  arg0,
  input 	       arg1,
  input 	       arg2,
  output 	       ret0,
  output signed [31:0] ret1,
  output 	       ret2
  );
  wire signed [31:0]   wire0 = -arg0;
  wire 		       wire1 = arg2 & arg1;

  assign ret0 = wire1;
  assign ret1 = wire0;
  assign ret2 = arg1;
endmodule // dataflow_unit_rate_94442178316576

module main (
  input signed [31:0]  arg0,
  input 	       arg1,
  input 	       arg2,
  output 	       ret0,
  output signed [31:0] ret1,
  output 	       ret2
  );
  wire 		       main_in_1_to_dataflow_unit_rate_94442178316576_in_1;
  wire signed [31:0]   dataflow_unit_rate_94442178316576_out_1_to_main_out_1;
  wire 		       main_in_2_to_dataflow_unit_rate_94442178316576_in_2;
  wire 		       dataflow_unit_rate_94442178316576_out_2_to_main_out_2;
  wire signed [31:0]   main_in_0_to_dataflow_unit_rate_94442178316576_in_0;
  wire 		       dataflow_unit_rate_94442178316576_out_0_to_main_out_0;

  assign main_in_0_to_dataflow_unit_rate_94442178316576_in_0 = arg0;
  assign main_in_1_to_dataflow_unit_rate_94442178316576_in_1 = arg1;
  assign main_in_2_to_dataflow_unit_rate_94442178316576_in_2 = arg2;

  assign ret0 = dataflow_unit_rate_94442178316576_out_0_to_main_out_0;
  assign ret1 = dataflow_unit_rate_94442178316576_out_1_to_main_out_1;
  assign ret2 = dataflow_unit_rate_94442178316576_out_2_to_main_out_2;

  dataflow_unit_rate_94442178316576 dataflow_unit_rate_94442178316576_0(
    .arg0(main_in_0_to_dataflow_unit_rate_94442178316576_in_0),
    .arg1(main_in_1_to_dataflow_unit_rate_94442178316576_in_1),
    .arg2(main_in_2_to_dataflow_unit_rate_94442178316576_in_2),
    .ret0(dataflow_unit_rate_94442178316576_out_0_to_main_out_0),
    .ret1(dataflow_unit_rate_94442178316576_out_1_to_main_out_1),
    .ret2(dataflow_unit_rate_94442178316576_out_2_to_main_out_2)
  );
endmodule // main
