#!/home/mikeurbach/tensorflow/.venv/bin/python

import tensorflow as tf

@tf.function(input_signature=[tf.TensorSpec([], tf.int32)], experimental_compile=True)
def increment(a):
    return a + 1

if __name__ == '__main__':
    module = tf.Module()
    module.increment = increment
    tf.saved_model.save(module, '.')
