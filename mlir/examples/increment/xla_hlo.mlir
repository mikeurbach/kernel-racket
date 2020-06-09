

module attributes {tf.versions = {bad_consumers = [], min_consumer = 12 : i32, producer = 175 : i32}, tf_saved_model.semantics} {
  func @__inference_increment_70(%arg0: tensor<i32> {tf_saved_model.index_path = [0]}) -> (tensor<i32> {tf_saved_model.index_path = []}) attributes {tf._XlaMustCompile = true, tf._input_shapes = ["tfshape$"], tf._noinline = true, tf_saved_model.exported_names = ["increment"]} {
    %0 = xla_hlo.constant dense<1> : tensor<i32>
    %1 = xla_hlo.add %arg0, %0 : tensor<i32>
    return %1 : tensor<i32>
  }
}
