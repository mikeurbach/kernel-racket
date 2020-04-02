

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_360(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._input_shapes = ["tfshape$", "tfshape$"], tf_saved_model.exported_names = ["gcd"]} {
    %cst = constant dense<-1> : tensor<i32>
    %cst_0 = constant dense<0> : tensor<i32>
    %0 = "xla_hlo.tuple"(%cst_0, %cst, %arg0, %arg1) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %1 = "xla_hlo.while"(%0) ( {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %3 = "xla_hlo.get_tuple_element"(%arg2) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %4 = "xla_hlo.get_tuple_element"(%arg2) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %5 = "xla_hlo.get_tuple_element"(%arg2) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %6 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %7 = call @while_cond_50(%3, %4, %5, %6) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tensor<i1>
      "xla_hlo.return"(%7) : (tensor<i1>) -> ()
    },  {
    ^bb0(%arg2: tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>):	// no predecessors
      %3 = "xla_hlo.get_tuple_element"(%arg2) {index = 0 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %4 = "xla_hlo.get_tuple_element"(%arg2) {index = 1 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %5 = "xla_hlo.get_tuple_element"(%arg2) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %6 = "xla_hlo.get_tuple_element"(%arg2) {index = 3 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
      %7:4 = call @while_body_60(%3, %4, %5, %6) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>)
      %8 = "xla_hlo.tuple"(%7#0, %7#1, %7#2, %7#3) : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
      "xla_hlo.return"(%8) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> ()
    }) : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>
    %2 = "xla_hlo.get_tuple_element"(%1) {index = 2 : i32} : (tuple<tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>>) -> tensor<i32>
    return %2 : tensor<i32>
  }
  func @while_body_60(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %cst = constant dense<1> : tensor<i32>
    %cst_0 = constant dense<0> : tensor<i32>
    %0 = remi_signed %arg2, %arg3 : tensor<i32>
    %1 = cmpi "ne", %0, %cst_0 : tensor<i32>
    %2 = cmpi "slt", %arg3, %cst_0 : tensor<i32>
    %3 = cmpi "slt", %0, %cst_0 : tensor<i32>
    %4 = cmpi "ne", %2, %3 : tensor<i1>
    %5 = and %1, %4 : tensor<i1>
    %6 = addi %arg3, %0 : tensor<i32>
    %7 = "xla_hlo.select"(%5, %6, %0) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
    %8 = addi %arg0, %cst : tensor<i32>
    return %8, %arg1, %arg3, %7 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
  }
  func @while_cond_50(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> tensor<i1> attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %cst = constant dense<0> : tensor<i32>
    %0 = cmpi "sgt", %arg3, %cst : tensor<i32>
    return %0 : tensor<i1>
  }
}