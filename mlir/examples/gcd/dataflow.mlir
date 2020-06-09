

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_380(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$", "tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["gcd"]} {
    %0 = "dataflow.unit_rate"() ( {
      %8 = xla_hlo.constant dense<-1> : tensor<i32>
      "dataflow.return"(%8) : (tensor<i32>) -> ()
    }) : () -> tensor<i32>
    %1 = "dataflow.unit_rate"() ( {
      %8 = xla_hlo.constant dense<1> : tensor<i32>
      "dataflow.return"(%8) : (tensor<i32>) -> ()
    }) : () -> tensor<i32>
    %2 = "dataflow.unit_rate"() ( {
      %8 = xla_hlo.constant dense<0> : tensor<i32>
      "dataflow.return"(%8) : (tensor<i32>) -> ()
    }) : () -> tensor<i32>
    %3 = "dataflow.fork"(%2) : (tensor<i32>) -> tensor<i32>
    %4 = "dataflow.unit_rate"() ( {
      %8 = "xla_hlo.tuple"(%3, %0, %arg0, %arg1) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      "dataflow.return"(%8) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
    }) : () -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %5 = "dataflow.fork"(%4) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %6 = "dataflow.loop"(%5) ( {
    ^bb0(%arg2: tensor<i1>, %arg3: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %8 = "dataflow.initial"(%arg2) {value = 0 : i1} : (tensor<i1>) -> tensor<i1>
      %9 = "dataflow.mux"(%8, %5, %arg3) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      %10 = "dataflow.fork"(%9) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      %11 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.get_tuple_element"(%10) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %12 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.compare"(%11, %3) {comparison_direction = "GT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %13 = "dataflow.fork"(%12) : (tensor<i1>) -> tensor<i1>
      %14 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.get_tuple_element"(%10) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %15 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.get_tuple_element"(%10) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %16 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.get_tuple_element"(%10) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %17 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.get_tuple_element"(%10) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %18 = "dataflow.fork"(%17) : (tensor<i32>) -> tensor<i32>
      %19 = "dataflow.unit_rate"() ( {
        %34 = xla_hlo.remainder %16, %18 : tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %20 = "dataflow.fork"(%19) : (tensor<i32>) -> tensor<i32>
      %21 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.compare"(%20, %3) {comparison_direction = "NE"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %22 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.compare"(%18, %3) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %23 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.compare"(%20, %3) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %24 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.compare"(%22, %23) {comparison_direction = "NE"} : (tensor<i1>, tensor<i1>) -> tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %25 = "dataflow.unit_rate"() ( {
        %34 = xla_hlo.and %21, %24 : tensor<i1>
        "dataflow.return"(%34) : (tensor<i1>) -> ()
      }) : () -> tensor<i1>
      %26 = "dataflow.unit_rate"() ( {
        %34 = xla_hlo.add %18, %20 : tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %27 = "dataflow.mux"(%25, %20, %26) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
      %28 = "dataflow.unit_rate"() ( {
        %34 = xla_hlo.add %14, %1 : tensor<i32>
        "dataflow.return"(%34) : (tensor<i32>) -> ()
      }) : () -> tensor<i32>
      %29 = "dataflow.unit_rate"() ( {
        %34 = "xla_hlo.tuple"(%28, %15, %18, %27) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
        "dataflow.return"(%34) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
      }) : () -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      %30:2 = "dataflow.demux"(%13, %10) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>)
      "dataflow.void"(%30#1) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
      %31:2 = "dataflow.demux"(%13, %29) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>)
      "dataflow.void"(%31#0) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
      %32 = "dataflow.mux"(%13, %30#0, %31#1) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      %33:2 = "dataflow.demux"(%13, %32) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>)
      "dataflow.return"(%13, %33#1, %33#0) : (tensor<i1>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>, tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
    }) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %7 = "dataflow.unit_rate"() ( {
      %8 = "xla_hlo.get_tuple_element"(%6) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      "dataflow.return"(%8) : (tensor<i32>) -> ()
    }) : () -> tensor<i32>
    return %7 : tensor<i32>
  }
}
