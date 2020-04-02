

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_360(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._input_shapes = ["tfshape$", "tfshape$"], tf_saved_model.exported_names = ["gcd"]} {
    %0 = "tf.Const"() {value = dense<-1> : tensor<i32>} : () -> tensor<i32>
    %1 = "tf.Const"() {value = dense<0> : tensor<i32>} : () -> tensor<i32>
    %2:4 = "tf.While"(%1, %0, %arg0, %arg1) {T = ["tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32"], _lower_using_switch_merge = true, _num_original_outputs = 4 : i64, _output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], _read_only_resource_inputs = [], body = @while_body_60, cond = @while_cond_50, device = "", is_stateless = true, output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], parallel_iterations = 10 : i64} : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>)
    %3 = "tf.StopGradient"(%2#2) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    %4 = "tf.Identity"(%3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    return %4 : tensor<i32>
  }
  func @while_body_60(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0 = "tf.Const"() {value = dense<1> : tensor<i32>} : () -> tensor<i32>
    %1 = "tf.FloorMod"(%arg2, %arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i32>
    %2 = "tf.Identity"(%1) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    %3 = "tf.Identity"(%arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    %4 = "tf.AddV2"(%arg0, %0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i32>
    %5 = "tf.Identity"(%4) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    %6 = "tf.Identity"(%arg1) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
    return %5, %6, %3, %2 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
  }
  func @while_cond_50(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> tensor<i1> attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0 = "tf.Const"() {value = dense<0> : tensor<i32>} : () -> tensor<i32>
    %1 = "tf.Greater"(%arg3, %0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %2 = "tf.Identity"(%1) {T = i1, _output_shapes = ["tfshape$"], device = ""} : (tensor<i1>) -> tensor<i1>
    return %2 : tensor<i1>
  }
}