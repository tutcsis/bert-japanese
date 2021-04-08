import tensorflow as tf
if tf.test.is_gpu_available():
    exit(0)
else:
    exit(1)
