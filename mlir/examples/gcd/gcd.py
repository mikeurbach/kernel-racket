#!/home/mikeurbach/tensorflow/.venv/bin/python

import tensorflow as tf

@tf.function(input_signature=[tf.TensorSpec([], tf.int32), tf.TensorSpec([], tf.int32)], experimental_compile=True)
def gcd(a, b):
    while b > 0:
        a, b = b, a % b

    return a

if __name__ == '__main__':
    module = tf.Module()
    module.gcd = gcd
    tf.saved_model.save(module, '.')
    # gcd(35, 14)

# TF_DUMP_GRAPH_PREFIX=/tmp/generated TF_XLA_FLAGS="--tf_xla_clustering_debug --tf_xla_auto_jit=2" XLA_FLAGS="--xla_dump_hlo_as_text --xla_dump_to=/tmp/generated" python gcd.py
