

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_gcd_380(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}, %arg1: tensor<i32> {tf_saved_model.index_path = [1]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$", "tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["gcd"]} {
    %0 = tf_executor.graph {
      %outputs, %control = tf_executor.island wraps "tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<0> : tensor<i32>} : () -> tensor<i32>
      %outputs_0, %control_1 = tf_executor.island wraps "tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<-1> : tensor<i32>} : () -> tensor<i32>
      %outputs_2:4, %control_3 = tf_executor.island wraps "tf.While"(%outputs, %outputs_0, %arg0, %arg1) {T = ["tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32", "tfdtype$DT_INT32"], _lower_using_switch_merge = true, _num_original_outputs = 4 : i64, _output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], _read_only_resource_inputs = [], body = @while_body_100, cond = @while_cond_90, device = "", is_stateless = true, output_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"], parallel_iterations = 10 : i64} : (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>)
      %outputs_4, %control_5 = tf_executor.island wraps "tf.Identity"(%outputs_2#2) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
      tf_executor.fetch %outputs_4 : tensor<i32>
    }
    return %0 : tensor<i32>
  }
  func @while_body_100(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> (tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>) attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0:4 = tf_executor.graph {
      %outputs, %control = tf_executor.island wraps "tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<1> : tensor<i32>} : () -> tensor<i32>
      %outputs_0, %control_1 = tf_executor.island wraps "tf.Identity"(%arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
      %outputs_2, %control_3 = tf_executor.island wraps "tf.FloorMod"(%arg2, %arg3) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i32>
      %outputs_4, %control_5 = tf_executor.island wraps "tf.Identity"(%outputs_2) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
      %outputs_6, %control_7 = tf_executor.island wraps "tf.AddV2"(%arg0, %outputs) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i32>
      %outputs_8, %control_9 = tf_executor.island wraps "tf.Identity"(%outputs_6) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
      %outputs_10, %control_11 = tf_executor.island wraps "tf.Identity"(%arg1) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>) -> tensor<i32>
      tf_executor.fetch %outputs_8, %outputs_10, %outputs_0, %outputs_4 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
    }
    return %0#0, %0#1, %0#2, %0#3 : tensor<i32>, tensor<i32>, tensor<i32>, tensor<i32>
  }
  func @while_cond_90(%arg0: tensor<i32>, %arg1: tensor<i32>, %arg2: tensor<i32>, %arg3: tensor<i32>) -> tensor<i1> attributes {tf._input_shapes = ["tfshape$", "tfshape$", "tfshape$", "tfshape$"]} {
    %0 = tf_executor.graph {
      %outputs, %control = tf_executor.island wraps "tf.Const"() {_output_shapes = ["tfshape$"], device = "", dtype = i32, value = dense<0> : tensor<i32>} : () -> tensor<i32>
      %outputs_0, %control_1 = tf_executor.island wraps "tf.Greater"(%arg3, %outputs) {T = i32, _output_shapes = ["tfshape$"], device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i1>
      %outputs_2, %control_3 = tf_executor.island wraps "tf.Identity"(%outputs_0) {T = i1, _output_shapes = ["tfshape$"], device = ""} : (tensor<i1>) -> tensor<i1>
      tf_executor.fetch %outputs_2 : tensor<i1>
    }
    return %0 : tensor<i1>
  }
}