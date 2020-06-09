#!/home/mikeurbach/tensorflow/.venv/bin/python

import tensorflow as tf

@tf.function(input_signature=[tf.TensorSpec([], tf.int32)], experimental_compile=True)
def negate(a):
    return -a

if __name__ == '__main__':
    module = tf.Module()
    module.negate = negate
    tf.saved_model.save(module, '.')
