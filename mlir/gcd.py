import tensorflow as tf

from tensorflow.python.ops import array_ops
from tensorflow.python.ops import control_flow_ops
from tensorflow.python.ops import math_ops

@tf.function(input_signature=[tf.TensorSpec([], tf.int32), tf.TensorSpec([], tf.int32)])
def gcd(a, b):
    cond = lambda _, b: math_ops.greater(b, array_ops.zeros_like(b))
    body = lambda a, b: [b, math_ops.mod(a, b)]
    a, b = control_flow_ops.while_loop(cond, body, [a, b], back_prop=False)
    return a

if __name__ == '__main__':
    module = tf.Module()
    module.gcd = gcd
    tf.saved_model.save(module, '/tmp/gcd/1')
