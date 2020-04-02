

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_360(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._input_shapes = ["tfshape$", "tfshape$"], tf_saved_model.exported_names = ["gcd"]} {
    %0 = xla_hlo.constant dense<-1> : tensor<i32>
    %1 = xla_hlo.constant dense<0> : tensor<i32>
    %2 = "xla_hlo.tuple"(%1, %0, %arg0, %arg1) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %3 = "xla_hlo.while"(%2) ( {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %8 = "xla_hlo.get_tuple_element"(%arg2) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %9 = "xla_hlo.get_tuple_element"(%arg2) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %10 = "xla_hlo.get_tuple_element"(%arg2) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %11 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %12 = call @while_cond_50(%8, %9, %10, %11) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tensor<i1>
      "xla_hlo.return"(%12) : (tensor<i1>) -> ()
    },  {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %8 = "xla_hlo.get_tuple_element"(%arg2) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %9 = "xla_hlo.get_tuple_element"(%arg2) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %10 = "xla_hlo.get_tuple_element"(%arg2) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %11 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %12:4 = call @while_body_60(%8, %9, %10, %11) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>)
      %13 = "xla_hlo.tuple"(%12#0, %12#1, %12#2, %12#3) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      "xla_hlo.return"(%13) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
    }) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %4 = "xla_hlo.get_tuple_element"(%3) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    %5 = "xla_hlo.get_tuple_element"(%3) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    %6 = "xla_hlo.get_tuple_element"(%3) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    %7 = "xla_hlo.get_tuple_element"(%3) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    return %6 : tensor<i32>
  }
  func @while_body_60(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0 = xla_hlo.constant dense<1> : tensor<i32>
    %1 = xla_hlo.remainder %arg2, %arg3 : tensor<i32>
    %2 = xla_hlo.constant dense<0> : tensor<i32>
    %3 = "xla_hlo.compare"(%1, %2) {comparison_direction = "NE"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %4 = xla_hlo.constant dense<0> : tensor<i32>
    %5 = "xla_hlo.compare"(%arg3, %4) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %6 = "xla_hlo.compare"(%1, %4) {comparison_direction = "LT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %7 = "xla_hlo.compare"(%5, %6) {comparison_direction = "NE"} : (tensor<i1>, tensor<i1>) -> tensor<i1>
    %8 = xla_hlo.and %3, %7 : tensor<i1>
    %9 = xla_hlo.add %arg3, %1 : tensor<i32>
    %10 = "xla_hlo.select"(%8, %9, %1) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
    %11 = xla_hlo.add %arg0, %0 : tensor<i32>
    return %11, %arg1, %arg3, %10 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
  }
  func @while_cond_50(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> tensor<i1> attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0 = xla_hlo.constant dense<0> : tensor<i32>
    %1 = "xla_hlo.compare"(%arg3, %0) {comparison_direction = "GT"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    return %1 : tensor<i1>
  }
}