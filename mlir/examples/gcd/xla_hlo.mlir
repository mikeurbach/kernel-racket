

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_380(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$", "tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["gcd"]} {
    %0 = xla_hlo.constant dense<-1> : tensor<i32>
    %1 = xla_hlo.constant dense<1> : tensor<i32>
    %2 = xla_hlo.constant dense<0> : tensor<i32>
    %3 = "xla_hlo.tuple"(%2, %0, %arg0, %arg1) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %4 = "xla_hlo.while"(%3) ( {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %6 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %7 = "xla_hlo.compare"(%6, %2) {comparison_direction = "GT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
      "xla_hlo.return"(%7) : (tensor<i1>) -> ()
    },  {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %6 = "xla_hlo.get_tuple_element"(%arg2) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %7 = "xla_hlo.get_tuple_element"(%arg2) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %8 = "xla_hlo.get_tuple_element"(%arg2) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %9 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %10 = xla_hlo.remainder %8, %9 : tensor<i32>
      %11 = "xla_hlo.compare"(%10, %2) {comparison_direction = "NE"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
      %12 = "xla_hlo.compare"(%9, %2) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
      %13 = "xla_hlo.compare"(%10, %2) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
      %14 = "xla_hlo.compare"(%12, %13) {comparison_direction = "NE"} : (tensor<i1>, tensor<i1>) -> tensor<i1>
      %15 = xla_hlo.and %11, %14 : tensor<i1>
      %16 = xla_hlo.add %9, %10 : tensor<i32>
      %17 = "xla_hlo.select"(%15, %16, %10) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
      %18 = xla_hlo.add %6, %1 : tensor<i32>
      %19 = "xla_hlo.tuple"(%18, %7, %9, %17) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      "xla_hlo.return"(%19) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
    }) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %5 = "xla_hlo.get_tuple_element"(%4) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    return %5 : tensor<i32>
  }
}
