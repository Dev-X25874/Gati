DNN Networks
############

Image Classification
********************

An architecture for :term:`Image Classification` requires consideration for
how to carry out convolutions, where to store partial sums and how to move
data in, out and around the FPGA.

Some popular networks used for image classification include: VGG16, ResNet
and Mobilenet.

VGG16
=====

VGG16 :cite:`simonyan2015deep`, short for Visual Geometry Group 16-layer, is a
convolution neural network (CNN) architecture designed for image classification.
Developed by the Visual Geometry Group at the University of Oxford, VGG16 is
known for its simplicity and effectiveness. It gained prominence as a
participant in the :term:`ILSVRC` in 2014.

The architecture comprises of 16 layers, including 13 **convolution layers** and
3 **fully connected layers**. The convolution layers have small 3x3 filters, and
the network’s depth stems from stacking multiple convolution layers. 2x2
Max-pooling layers are utilized for down-sampling and introducing translation
in-variance. VGG16’s architecture remains consistent in terms of filter size
(3x3 stride 1) and max-pooling spatial resolution (2x2 stride 2) until the fully
connected layers.

Here’s a breakdown of VGG16’s architecture:

1. Input Layer:Accepts input images of size 224x224 pixels with three
   color channels (RGB). Note the only the first layer input is
   mentioned in terms of RGB. As as we go deeper in the network, we
   simply refer as channels. For examples layer two’s input is
   224x224x64. i.e., input has a 64 dimension channel.

2. Convolutional Blocks (Block 1 to Block 5): VGG16 has five convolution
   blocks. Each block comprises one or more convolution layers, followed
   by a max-pooling layer.

   The convolution layers use 3x3 filters, and the number of filters
   increases with the depth of the network. The max-pooling layers have
   2x2 filters and a stride of 2, reducing spatial dimensions.

3. Fully Connected Layers: After the convolution blocks, VGG16 has three
   fully connected layers for high-level feature representation. The
   fully connected layers have 4096 neurons each, leading to a large
   number of parameters.

4. Activation Function: Rectified Linear Unit (ReLU) activation
   functions are applied after each convolution and fully connected
   layer, introducing non-linearity.

5. Softmax Output Layer: The last layer is a softmax output layer with
   1000 neurons, corresponding to the 1000 classes in the ImageNet
   dataset.

VGG16’s architecture (our focus) has inspired subsequent CNN designs,
including deeper variants like VGG19. While VGG16 achieved strong
performance in image classification, it has limitations such as a large
number of parameters, which can lead to overfitting, and computational
demands. Nevertheless, it remains valuable for benchmarking and as a
pre-trained model for transfer learning in various computer vision
applications.

.. TODO
   describe mobilenets and resnets
