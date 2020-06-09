

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_increment_70(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["increment"]} {
    %0 = tf_executor.graph {
      %outputs, %control = tf_executor.island wraps "tf.Const"() {device = "", value = dense<1> : tensor<i32>} : () -> tensor<i32>
      %outputs_0, %control_1 = tf_executor.island wraps "tf.AddV2"(%arg0, %outputs) {device = ""} : (tensor<i32>, tensor<i32>) -> tensor<i32>
      %outputs_2, %control_3 = tf_executor.island wraps "tf.Identity"(%outputs_0) {device = ""} : (tensor<i32>) -> tensor<i32>
      tf_executor.fetch %outputs_2 : tensor<i32>
    }
    return %0 : tensor<i32>
  }
}