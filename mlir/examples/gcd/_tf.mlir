

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_380(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$", "tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["gcd"]} {
    %0:2 = "_tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<0> : tensor<i32>} : () -> (tensor<i32>, !_tf.control)
    %1:2 = "_tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<-1> : tensor<i32>} : () -> (tensor<i32>, !_tf.control)
    %2:5 = "_tf.While"(%0#0, %1#0, %arg0, %arg1) {T = ["tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32"], _lower_using_switch_merge = true, _num_original_outputs = 4 : i64, _output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], _read_only_resource_inputs = [], body = @while_body_100, cond = @while_cond_90, device = "", is_stateless = true, output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], parallel_iterations = 10 : i64} : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>, !_tf.control)
    %3:2 = "_tf.Identity"(%2#2) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> (tensor<i32>, !_tf.control)
    return %3#0 : tensor<i32>
  }
  func @while_body_100(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0:2 = "_tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<1> : tensor<i32>} : () -> (tensor<i32>, !_tf.control)
    %1:2 = "_tf.Identity"(%arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> (tensor<i32>, !_tf.control)
    %2:2 = "_tf.FloorMod"(%arg2, %arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> (tensor<i32>, !_tf.control)
    %3:2 = "_tf.Identity"(%2#0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> (tensor<i32>, !_tf.control)
    %4:2 = "_tf.AddV2"(%arg0, %0#0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> (tensor<i32>, !_tf.control)
    %5:2 = "_tf.Identity"(%4#0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> (tensor<i32>, !_tf.control)
    %6:2 = "_tf.Identity"(%arg1) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> (tensor<i32>, !_tf.control)
    return %5#0, %6#0, %1#0, %3#0 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
  }
  func @while_cond_90(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> tensor<i1> attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0:2 = "_tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<0> : tensor<i32>} : () -> (tensor<i32>, !_tf.control)
    %1:2 = "_tf.Greater"(%arg3, %0#0) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> (tensor<i1>, !_tf.control)
    %2:2 = "_tf.Identity"(%1#0) {T = i1, _output_shapes = ["tfshape$"], device = ""} : (tensor<i1>) -> (tensor<i1>, !_tf.control)
    return %2#0 : tensor<i1>
  }
}