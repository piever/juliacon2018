# Load and minibatch

using Knet, Images

include(Knet.dir("data", "minst.jl"))

# 28x28 pixel + n channels + number of images and reply

# minibatch in SGC: 100 images at a time, minibatch

# Loss function is negative log likelihood
using Knet
M = KnetArray{Float32}([1.2, 2.3])

# avoid overfitting with dropout...
# - overfitting => coordination, destroyed by dropout
# - ensemble of networks

# cnn: sparsely connected, weight sharing. Faster training, less overfitting
