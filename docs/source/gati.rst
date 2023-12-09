.. _end:

Get to know Gati.
#################

.. sectionauthor:: Yaswanth Tavva (@yswntht)

This is the an incremental document and is subjected to revisions. At
the point of reading this document, do check with @akshar001 if this
continues to be the latest interpretation of Gati architecture.

.. contents:: Table of Contents
   :local:
   :depth: 1


Common Definitions
******************

Row Major Ordering
------------------
Row-major ordering is a linear memory storage
approach where elements of a multidimensional array are stored in
consecutive memory locations row by row. In this arrangement, the first
row’s elements are stored contiguously, followed by the second row, and
so on. For example, in 224x224x3 (image with three channels), all rows of
channel 1 are followed by rows of channels 2 and so on. Consider a three
channel image as shown in the following figure (From :cite:`im2col_zhou2021`):

.. image:: _static/3channel-image.png
   :width: 50%
   :align: center

Row major ordering for this image would look something like this: 

.. image:: _static/chw.png
   :width: 50%
   :align: center

Following is the pattern:

.. code::

  (e1,1-c1),(e1,2-c1),…(e1,224-c1),…(e224,224-c1),
  (e1,1-c2),(e1,2-c2),…(e1,224-c2),…(e224,224-c2),
  (e1,1-c3),(e1,2-c3),…(e1,224-c3),…(e224,224-c3)

Channel First Layout
--------------------
Channel-first layout, often referred to as
“NHWC” (Number of images, Height, Width, Channels), is a data
arrangement format commonly used in deep learning frameworks,
particularly for convolution neural networks (CNNs). In this layout, the
channels (e.g., color channels in an image) are the innermost dimension,
followed by width and height. For example, 224x224x3 (image with three
channels), element1 of all channels are next to each other, till last
element of row of all channels. Likewise for all rows. 

Channel first for the image from the above section is arranged as shown
in the following figure:

.. image:: _static/hwc.png
   :width: 50%
   :align: center

Following is the pattern:

.. code::

  (e1,1-c1), (e1,1-c2), (e1,1-c3), … (e1,224-c1), (e1,224-c2),
  (e1,224-c3), (e2,1-c1), (e2,1-c2), (e2,1-c3), ………(e224,224-c1),
  (e224,224-c2), (e224,224-c3).

IFMaps, OFMaps and Kernels
--------------------------

A 2D Convolution is a repeated application of a relatively smaller matrix (a
kernel) over a larger input feature map (IFMap or Image). 

The kernel is *slid* across the input in a manner shown below:

.. image:: _static/no_padding_no_strides.gif
   :width: 50%
   :align: center

The kernel in the above diagram is 3x3 in size and its being slid on an input
the size of 4x4. The output (or OFMap), thus generated, is 2x2 in size. 

Thus, an IFMap (input filter map) is the matrix on which a Kernel is being
applied and an OFMap (output filter map) is the result of that operation.

A 1D array is called an array, vector or a list. If its 2D, its called a Matrix
and its its N-Dimensional, its called a tensor. 

IFMaps, OFMaps and Kernels, all three are tensors. Therefore, convolution is an
operation on tensors. 

.. _nchw:

NCHW and friends 
----------------

A 1D array is stored in memory in a linear fashion, how should a 2D array be stored?  

The C language stores a 2D array in row-major order i.e. all rows stored one-after another.

Take VGG16 :cite:`simonyan2015deep` for example. The size of the input (image
in this case, with three channels) to the first layer is (224,224,3). To
convolve with a tensor of this size, we use a (3x3x3). Thus,::

    (224x224x3) X (3x3x3) = (OHxOWx1)

Here, OH and OW are given by:::

    OH = (IH - KH + 2*P)/S + 1
    OW = (OW - KW + 2*P)/S + 1

If we had 64 different 3x3x3 kernels, the output would be (224x224x64).

.. image:: _static/channel-first.svg
   :width: 70%
   :align: center


Systolic Array
---------------
A `systolic array <https://en.wikipedia.org/wiki/Systolic_array>`_ is a parallel
computing architecture that organizes processing units in a regular grid,
resembling a matrix. Data flows through the array in a systolic fashion, where
computations are performed in a pipeline manner. This design enhances throughput
and efficiency, commonly applied in tasks like matrix multiplication and signal
processing in parallel computing systems. In version1, we consider 9x8 arrays of
8 units. Each of 9x8 is referred as an **engine**.

Partial Sums
---------------
A partial sum refers to the accumulated total of a subset of a series or
sequence. It represents the sum of a specific range or portion of elements
within a larger set.

Weight Stationary Data Flow
----------------------------
Weight stationary data flow is a computing paradigm in neural network
accelerators where weights are stored in a stationary manner, allowing parallel
processing of data across multiple computing units. This architecture enhances
efficiency by minimizing data movement during neural network inference,
optimizing for tasks like convolution operations in deep learning.

Systolic Dataflow
-----------------
Systolic dataflow and weight-stationary dataflow are related but distinct
concepts. In systolic dataflow. processing units arranged in a grid perform
computations in a pipeline manner. Data is “pumped” through the array
bidirectionally (top-to-down and left-to-right), and each processing unit
processes a portion of the data as it passes through. In case of weight
stationary, weights are pre-loaded to the systolic array first and during
operation, data is only “pumped” left-to-right. In both cases, partial sums are
moved vertically down and final sum is available at the lower most processing
unit. **In other words**, in weight stationary, inputs are shared, while in
systolic dataflow, both inputs and weights are shared. Chapter 5 of
:cite:`sze2020` contains in-depth explanations of different dataflows.

INT8 quantization
------------------
Integer 8 (INT8) quantization is a data compression technique that represents
numerical values using 8-bit integers. This reduces the precision of the
original data but significantly decreases storage requirements and computational
complexity. *Gati currently assumes that activations and weights are INT8
quantized*. See :ref:`quantization` for more information.

Clipping
--------
If the output surpasses this limit, the function replaces
it with the predefined maximum value. we see this operator in MobileNet.
Thus be sure to revisit in future.

.. seealso::

  `Efficient Processing of Deep Neural Networks - Sze
  <https://link.springer.com/book/10.1007/978-3-031-01766-7>`_

  `Digital Design: Principles and Practices - Wakerly
  <https://www.amazon.com/Digital-Design-Principles-Practices-Book/dp/0131863894>`_


Neural Networks Prerequisites
**************************************

“Thoroughly” read (i.e. spend time reading, studying, digging deep into a text)
book-chapters 1 and 2 from :cite:`sze2020`. So, these are must-read before
moving to next chapters of this document.

VGG16
-----

VGG16 :cite:`simonyan2015deep`, short for Visual Geometry Group 16-layer, is a
convolution neural network (CNN) architecture designed for image classification.
Developed by the Visual Geometry Group at the University of Oxford, VGG16 is
known for its simplicity and effectiveness. It gained prominence as a
participant in the ImageNet Large Scale Visual Recognition Challenge (ILSVRC) in
2014.

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

Memory Layout Of DRAM
*********************

.. TODO
   write more about this

When finalizing the memory layout factor in all the values that are to
be stored in the DRAM.

1. configurations
2. biases
3. values of batch normalization (not required for VGG16)
4. input feature maps for N images
5. weights for convolution layers and fully connected layers
6. intermediate channel outputs
7. layer outputs

(shreeyash: add few examples formats for 4,5,6,7. images from your book
also would do.)

for other queries: shreeyash

Configuration Block
*******************

.. sectionauthor:: Shreeyash Pandey (@bojle)

.. TODO
   write more about this

.. csv-table:: Configuration For Convolution Block
  :header: "Conv", "Opcode", "IW", "IH", "OW", "OH", "IC", "KN", "KW", "KH", "Stride", "Padding", "Dram Address", "Total"

  "Bits","4","10","10","10","10","10","10","4","4","3","3","32","110"


.. csv-table:: Configuration For Tail Block
  :header: "TailBlock","Opcode","BNChannels","BNAddress","ReluClip","QuantScale","QuantShift","PoolType","PoolParam", "Width","Height","Stride","Padding","Total"

  "Bits","4","10","10","10","10","10","10","4","4","3","3","32","110"

.. csv-table:: Configuration For Fully Connected Block
  :header: "FC","Opcode","WeightRows","WeightCols","InputRows","DropoutConstant","Address","Total"

  "Bits","4","16","16","16","8","32","92"

Configuration block stores required configurations for each layers and
programs input, output, and tail blocks ahead of time so that they can
immediately switch to new settings after completion of the current layer
and start processing next layer. 

Each table above shows a config packet of 128 bits. Understand these
packets as instructions where the instruction width is 128. None of the
above configs currently take all 128 bits, this is not a problem, these
least significant remaining bits can be assumed to be reserved.

Gati Architecture
*****************

.. sectionauthor:: Shreeyash Pandey (@bojle)

.. TODO:
   add images here

At this point we believe that you have covered sufficient background on
CNNs and various assumptions we made throughout. we thus freely use the
technical keywords without elaborating them in detail.

Gati currently assumes to have 8 units 9x8 weight stationary systolic
array. Each of these units is called a compute engine. A compute engine
is a 2D grid of processing elements arranged in 9 rows and 8 columns.
our choice of 9 rows is because of filter size of VGG16, i.e., 3x3 -
having a compute engine that is coherent in size with filter size
simplifies the dataflow design; however this could be extended to other
filter sizes. each 3x3 filter here can be visualized as a column of 9
elements. Thus all 9 weights of a filter can be exactly fit to compute
engine’s column. in 8 columns of compute engine 8 unique filters can be
pre-loaded. so, in each of 9x8, first 8 filters are loaded, respective
to the engine. After completion of loading weights, each compute engine
is set to accept inputs. 8 engines in-parallel accept first 8 channels.
partial-sums are collected (and added) before passing to the tail
blocks. Tail blocks apply activation functions (e.g. relu), dropout, and
perform operations like downsampling (e.g. maxpooling); in some cases
(transform to row-major format). Finally, the data is staged in FIFOs to
be written back to DRAM.

Input Blocks 
------------

The input block includes the blocks that read from (in most cases) from the DRAM
and bring data to the Systolic array. This includes:

1. Inputs
2. Weights
3. Biases
4. Partial Sums (Accumulants)


Inputs (im2col) 
===============

.. _bounding_squares:

**Bounding Squares Algorithm**
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. sectionauthor:: Yaswanth Tavva (@yswntht)

When using systolic array to accelerate CNNs, we cannot operate on image
directly. Instead we need to perform a transformation first called image
to column or commonly called im2col.

The bounding squares algorithm is thus:

1. Index to co-ordinate conversion: The first sub-block of im2col where
   the input data will be getting its respective coordinate (i.e. rows
   and column).

2. valid_sqaures_param: Index to coordinate conversion block is followed
   by valid squares block, here if the below nine conditions are
   satisfied valid bits will go high and that gives the number of
   squares in which an element would be part of. The size of the kernel
   is 3*3 so we can expect each patch of the image to have 9
   blocks/coordinates enclosed within it and so the 9 various
   conditions. The square is considered to be a valid one if the filter
   that is covering that patch of the image is within the image boundary
   i.e. 224x224-matrix size.

   -  Check If (x,y) is greater than 1 and if the input co-ordinate is
      bounded between (x,y) and (x+2,y+2). If so valid[0] goes high.
   -  Now from (x,y), go one row above i.e. (x-1,y) and check if input
      co-ordinate is bounded between (x-1,y) and (x+1,y+2). if so
      valid[1] goes high.
   -  Now from (x,y) we go two rows above i.e. (x-2,y) and check if
      input co-ordinate is bounded between (x-2,y) and (x,y+2). if so
      valid[2] goes high.
   -  Then from (x,y) we go one column behind i.e. (x,y-1) and check if
      input co-ordinate is bounded between (x,y-1) and (x+2,y+1). if so
      valid[3] goes high.
   -  Then from (x,y-1) we go one row above i.e. (x-1,y-1) and check if
      input co-ordinate is bounded between (x-1,y-1) and (x+1,y+1). if
      so valid[4] goes high.
   -  Then from (x,y-1) we go two rows above i.e. (x-2,y-1) and check if
      input co-ordinate is bounded between (x-2,y-1) and (x,y+1). if so
      valid[5] goes high.
   -  Now from (x,y) we go two columns behind i.e. (x,y-2) and check if
      input co-ordinate is bounded between (x,y-2) and (x+2,y). if so
      valid[6] goes high.
   -  Then from (x,y-2) we go one row above i.e. (x-1,y-2) and check if
      input co-ordinate is bounded between (x-1,y-2) and (x+1,y). if so
      valid[7] goes high.
   -  Then from (x,y-2) we go two rows above i.e. (x-2,y-2) and check if
      input co-ordinate is bounded between (x-2,y-2) and (x,y). if so
      valid[8] goes high.

3. Valid Rows: The last sub-block of the module, here the nine rows are
   assigned with constant values form 1 to 9 when the patch of the image
   is converted into its corresponding column, it’d yield us 9 rows,
   hence 9 rows are driven. Of these 9 rows few can be valid which is
   given by the valid_sq_o.

Note that incoming data to im2col is in row-major format. Following the
above three steps, data is then staged in input FIFOs of each engine.
Input FIFOs are required to stage the *ready* data temporarily till all
FIFOs have at least one element; only then input FIFOset at each engine
will be issued a read. The data is then pushed into the engine for
convolution operation.

for other queries: chaya, praveen, shreeyash

**Coordgen Algorithm**
^^^^^^^^^^^^^^^^^^^^^^

.. sectionauthor:: Shreeyash Pandey (@bojle)

.. TODO
   reorganize

Systolic arrays arranged in a regular square (or rectangular) grid are matmul
(or gemm) machines. I.e. they can perform matrix multiplications. Convolution on
the other hand is a dot-product based operation. Ergo, it is not possible to
take a 3x3 kernel, for example, and a 3x3 section of a input (as one would in
convolution), feed it to the systolic array and expect the correct result. 

**There is a need for a transformation that would allow us to carry out a
convolution operation on a matmul engine. This transformation is im2col**

.. image:: _static/Im2Col_cs231n.png
   :width: 100%
   :align: center

The above image shows the im2col operation for a input of 3 channels, size 4x4
with a 2x2 kernel to the left. The expanded matrix is made of columns of 4
(2*2), and are the elements from the input matrix where the 2x2 kernel lands and
slides. Thus, the expanded matrix has 9 columns as the kernel has 9 unique
sliding locations. The number of rows is decided by the size of the kernel and
the number of channels. In this case, `2 * 2 * 3`, gives 12 which is the total
number of rows in the complete expanded matrix for all channels.

Explicit im2col
===============

There are two glaring problems with im2col:

1. It requires time (increasing the latency of computation)
2. It requires space (which implies the use of secondary storage, DRAM, for
   example)

Since, systolic arrays cannot be used directly to carry out convolution, im2col
is a necessary evil.

The naïve way to carry out im2col is design a block on the FPGA that does it
explitcy, stores the entire expanded matrix somewhere and feed it back to the
array. This design can be made slightly more optimal than it sounds by
pipelining the process. The biggest drawback here is that the entire input has
been expanded even though the systolic array can only consume some of it at a
time. 

This leads us to want an algorithm that dynamically expands its inputs.
It shall only expand as much data as needed. This tackles both the time and
space problem that explicit algorithm creates. This is the so-called implicit
im2col algorithm.

Implicit im2col
===============

Consider a convolution of 4x4 input with a 2x2 kernel. We require 4 inputs to be
generated at a timestep. For the first timestep, the inputs required are values 
at at co-ordinates
.. code::

     (0,0)       0       0       0

the zeros are padded as the SA only consumes 1 element in the fist timestep. This
is followed by the arrays made of:
.. code::

     (0,1)     (0,1)     0       0
     (0,2)     (0,2)   (1,0)     0

and so on. The numbers inside the brackets are co-ordinates indexing a matrix and are
replaced by their values. 

**Definitions**:

.. TODO
    better representation for these definitions

.. code::

    lsfe: last slide first element.  
    the first element of the last sliding position of a kernel.  
    for a 2x2 kernel on 4x4 input, all the co-ordinates with 
    co-ordinates of the second last column are lsfe.  
    
    lsme: last slide middle element all the elements b/w first 
    element and last of the last sliding position of a kernel 
    for 4x4 kernel on 6x6 input, co-ordinates with y values = 4,5 
    
    lsle: last slide last element all elements of the last column

**The Algorithm**:

.. code::

     int previous[4];
     int current[4];
     while (1) {
         for (i = 0 to 4) {
             if (is_lsfe(previous[i]) && first_lsfe)
                 current[i] = (previous[i].x + 1, 1) 
             else if (is_lsme(previous[i]) && first_lsme)
                 current[i] = previous[i]
             else if (is_lsle(previous[i]))
                 current[i] = previous[i]
             else
                 current[i] = (previous[i].x, previous[i].y + 1)
         }
     }

**Explanation**:

1. Start with two buffers 'previous' and 'current' of co-ordinates (x,y)
2. iterate over current buffer.
3. during each iteration, compare current buffer's co-ordinates to previous buffer's  
   at the same index
4. if its lsfe, increment the x value of previous buffer and set y to 1 and 
   only do this once for a buffer.
5. if its lsme, copy the value to the left of the current buffer and only do 
   this once for a buffer.
6. if its lsle, copy the value to the left of the current buffer
7. after iteration, replace co-ordinates in current buf to their corresponding values
8. copy current buf's contents of previous buf.

Here's a complete set of vectors as generated by this algorithm for 2x2 kernel on a 4x4
input:

.. code::

      0,0 0,0 0,0 0,0
      0,1 0,1 0,0 0,0
      0,2 0,2 1,0 0,0
      0,3 0,3 1,1 1,1
      0,4 0,4 1,2 1,2
      1,0 0,5 1,3 1,3
      1,1 1,1 1,4 1,4
      1,2 1,2 2,0 1,5
      1,3 1,3 2,1 2,1
      1,4 1,4 2,2 2,2
      2,0 1,5 2,3 2,3
      2,1 2,1 2,4 2,4
      2,2 2,2 3,0 2,5
      0,0 2,3 3,1 3,1
      0,0 0,0 3,2 3,2
      0,0 0,0 0,0 3,3


Weights
========

.. TODO
   more details

Request weights from DRAM in the available bandwidth of DRAM. weight
FIFOset has 64 FIFOs.On a DRAM read request, the incoming 32 bytes are
evenly distributed amoung first 32 FIFOs, one byte for one FIFO. second
read request is distributed among rest 32 FIFOs.

for other queries: shreeyash

Systolic Array
--------------

**Systolic Array** here is combination of one or many compute engines.
current version of SA assumes a weight stationary Processing element for
convolution layers and output stationary for fully connected layers.
configuration block instructs to switch weight stationary to output
stationary. exploring other dataflows (e.g. row stationary) for
convolution layers is a future work.

For fully connected layers we use only one row of all available rows.
outputs at each column are accumulated to previous value. This can be
visualized as 1-D systolic array where the input are moved horizontally
and each column receives a weight. you may notice from fully connected
layers that a weight is only used once. Thus having 1-D (1-row x
N-columns) systolic array is sufficient; as inputs are reused across
weights, they are passed horizontally, while weights are not used more
than once, they are passed vertically.

for other queries: roshni, shwet, shreeyash.

Output Block
------------

1. opFIFO set1: FIFOs at immediate output of SA.
2. Adder **trees** between compute engines
3. opFIFO set2: FIFOs to stage DRAM reads (these are the partial sums of
   previous layers)
4. adder tree between results of previous adder tree and staged data in
   set2.
5. delay registers
6. crossbar and configuration design.
7. opFIFO set3: FIFOs at the output of the crossbar.

**opFIFO set1**: these FIFOs are present at the output of systolic array
to collect the partial sums from each column of systolic array. thus,
set1 has 64 FIFOs. one FIFO for each column.

**Adder Tree Set1**: the number of adder tree in set1 is equal to number
of columns in each compute engine. adder tree is log N complexity, where
N is number of inputs. stage 1 of each adder tree is capable of
``ceil (compute engines / 2)`` additions. in our case with 8 compute
engines, each adder tree in stage 1 has 4 addition operations. in total
set1 has 56 addition operators.

**opFIFO set2**: these FIFOS stage the accumulations of partial sums
(previous 8 channels) reads from DRAM to be added with accumulations of
current 8 channels. opFIFO set2 has 32 FIFOs to accommodate DRAM read.

**Adder Tree Set2**: is responsible for add **opFIFO set2** data with
results from **adder tree set1** before forwarding to the delay
registers block. size of adder tree set2 is similar to adder tree set1.
adder tree set2 accepts input from opFIFO set2 (8 elements at a time)
and output of adder tree set1 (also 8 elements).

**Delay Registers Block**: these registers align incoming data so that
crossbar enables transformation of data into row-major format required
for next layer. thus is only enabled after adder tree set2 after
accumulating all the channels. Moreover, implementation need not be dead
on as described. You may realize very soon that it is not practical to
add many registers because adding many registers physically is not a
scalable solution. *An alternative approach is to use counters to create
the delay without the registers*.


+--------+--------+--------+--------+--------+--------+--------+--------+
| S      | S      | S      | S      | S      | S      | S      | S      |
| A-col1 | A-col2 | A-col3 | A-col4 | A-col5 | A-col6 | A-col7 | A-col8 |
+========+========+========+========+========+========+========+========+
| -      | -      | -      | -      | -      | -      | reg    | reg    |
+--------+--------+--------+--------+--------+--------+--------+--------+
| -      | -      | -      | -      | reg    | reg    | reg    | reg    |
+--------+--------+--------+--------+--------+--------+--------+--------+
| -      | -      | reg    | reg    | reg    | reg    | reg    | reg    |
+--------+--------+--------+--------+--------+--------+--------+--------+
| reg    | reg    | reg    | reg    | reg    | reg    | reg    | reg    |
+--------+--------+--------+--------+--------+--------+--------+--------+
| x      | x      | x      | x      | x      | x      | x      | x      |
| bar-I1 | bar-I2 | bar-I3 | bar-I4 | bar-I5 | bar-I6 | bar-I7 | bar-I8 |
+--------+--------+--------+--------+--------+--------+--------+--------+

.. note::
    
  `reg` here is an 8 bit register.

**Crossbar And Configuration Design**: Each NN layer expects data to be
in row-major format. But the way that systolic array operates cripples
the data format. To arrange back to row-major order, we use Delay
Registers and crossbar pair. (first Delay Registers, followed by
crossbar).

crossbar is N input and N output switch. Depending on the configuration
there is one-to-one mapping of input to output ports. using the
**crossbar alone** will not provide row-major formatting. However, with
a sequence of correct configuration settings to crossbar and Delay
Registers, we can achieve the required format that next layer expects.
So configurations are to be such that when a read is issued on this (in
future), first 4 bytes of 32 bytes DRAM read should consist of engine 1
data; byte 5 to byte 8 should have engine 2 data and likewise bytes for
other engines are available in above manner. This data rearrangement is
enabled by crossbar and Delay Registers.

.. note::

  PS: Our current version with 9x8 x8 assumes that all im2cols are
  synchronously feed from the incoming DRAM data. For a DRAM read (32
  bytes), each compute engine is delivered with 4 bytes. To accommodate 4
  byte at each engine, it is also assumed that few registers (e.g. 256bit)
  are available. you may notice that the number registers available limits
  the burst-read length.

**opFIFO set3**: is available at the of crossbar to collect and stage
the output before issuing a write to DRAM. note that due to delay
registers it takes 7 cycles to collect 32 bytes of data, 11 cycles to
collect 64 bytes of data. so only after 7 cycles (11 cycles) a DRAM
write (burst 2) can be issued.

for other queries: shreeyash

Timeline and burst analysis
---------------------------

Number of buffer registers available at each compute engine decides the
dram bandwidth. With 16 buffers (128 registers) at each engine we have
16 cycles. With 32 buffers we have 32 cycles dram available. however,
these available cycles (16 or 32) has to be smartly distributed between
blocks that access the dram. Our current version considers a
**fixed-weighted** distribution on DRAM allotment to each of the above
blocks that accesses the DRAM. However, in future revisions this could
be extended to **on-demand-dynamic** allotment of DRAM access to these
blocks.

1. In the current version, with 16 buffer variant, for every 16 cycles:
   im2col block accesses 4 cycle burst, an equal number of cycles to
   dram read by opFIFO set2 - 4 cycle burst, 2 cycle burst write of
   opFIFO set3 to DRAM. Left 6 cycles can be allocated to weight block
   or other block that requires DRAM access.

2. In the current version, with 32 buffer variant, for every 32 cycles:
   im2col block accesses 8 cycle burst, an equal number of cycles to
   dram read by opFIFO set2 - 8 cycle burst, 4 cycle burst write of
   opFIFO set3 to DRAM. Left 12 cycles can be allocated to weight block
   or other block (mipi) that requires DRAM access.

for other queries: shreeyash

Performance
-----------

Our latest performance estimates of imagenet on VGG16 achieve approx
300ms/frame for 9x8 x8 considering 100 MHz. 260ms is spent on first 13
convolution layers and 30ms of rest 40ms is spent on first fully
connected layer with 100MB of weights. our baseline jetson nano 2GB
achieves 130ms operating at 900 MHz.

for other queries: shreeyash

Tail Blocks
-----------

.. TODO:
   These sections

ReLU
====

.. _quantization:

Quantization
============

.. TODO
   contents:
    intro
    calibrated s (how to pick scales)
    fast division/multiplication (on fpga)
    doing better (partial/ QAT)

Quantization is a techinique of re-encoding information, albeit in a smaller
bit-width. It substantially reduces the size and bandwidth requirements of a NN
model by ~4x. As floating point operations are expensive in general, it is
desirable to have integers, especially 8bit integers that encode the same
information as their traditional Float32 counterparts. As it turns out, neural
networks are resilient to minor turbulence in activations and give similar
accuracies in smaller bit-widths as they would with greater range of precision.
The only decidable variable here then is how we quantize our numbers.

To quantize a Float32 number :code:`x`, we need to *scale* it down to what Int8
can fit. This is achieved by calculating a **scale** variable. The scale
can be calculated thusly:

.. math::
   :label: scale_simple
   
   s = \frac{2^b-1}{\beta-\alpha}

Where, :math:`\beta` and :math:`\alpha` are the upper and lower limits of source
bit-field—in our case, Float32. :math:`b` is the number of bits in the
destination bit-field, which is 8 for Int8.

Equation :eq:`scale_simple` now becomes:

.. math::
   :label: scale_final
   
   s = \frac{255}{\beta-\alpha}

Now, the quantization function can be defined as:

.. TODO
   introduce affine quantization and why it has been left out

.. math::
   :label: quantize_simple

    x_q = quantize(x, s) = clip(round(x * s), -127, 127)

:math:`round` is a round-to-nearest function, and :math:`clip` clamps its inputs
between -127 and 127. Rounding can affect quantization, this can be
explored further (See Section 3, :cite:`gupta2015`).

Similarly, the de-quantize function becomes:

.. math::
   :label: dequantize_simple

    x = dequantize(x_q, s) = x_q / s

What remains now is calculating :math:`s`, which in-turn requires :math:`\beta`
and :math:`\alpha`. This is explained in the following sections.

Heuristics for scale selection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

From the previous sections, :math:`\alpha` and :math:`\beta` need not be
approximated from the entire Float32 space, as activations and weights tend not
to encompass the entire Float32 space, as demostrated by this plot:

.. TODO
   add plot for weight distribution

Therefore, the min and max values need to be ascertained dynamically from the
set of values that we have at hand.

The *granularity* at which this is done is described. :cite:`Wu et. al.<wu2020>`,  recommends
the following: 

* Use *symmetric per-channel scale quantization* for weights
* Use *per-tensor* scale quantization for activations/inputs.

Here, per-channel and per-tensor imply the granularity of quantization. Former
means that each channel (in a n-channel convolution) has a unique scale value
and the latter, each tensor (made of many channels) has one unique scale value.
Intuitively, per-tensor is coarser than per-channel granularity.

Efficiency Concerns
^^^^^^^^^^^^^^^^^^^

Calculating max and min values dynamically is computationally expensive. They
need to be computed statically or *offline*. For weigths, this is
straightforward, as they are computed once during trained and used statically
during inference. Moreover, we know a-priori, what their values will be. 

For activations/inputs, for which, the min-max values can be anything, there is
a need for approximation through *calibration*. Calibration is the techinique of
taking a sample dataset, and calculating scale values for it. These new-found
scale values are fixed just like the weights of neural networks when they are
deployed.

To improve the efficiency further, instead of defering scale-compute to compile
time from runtime, we can take it further and compute scale-values for popular
datasets in advance and store them at a server or distribute along with other
fixed-parameter files.

Relative Entropy
^^^^^^^^^^^^^^^^^

Quantization is re-encoding of information. The ideal scale-values have the
least loss of informationwhen converting from one size to other. A metric to
measure loss of information is *Relative Entropy* or `KL Divergence
<https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence>`_.

KL Divergence measures how one probability distribution is differnce from a
second, reference distribution. It is describes as such:

.. math::
   :label: eq:kl_divergence

    D_{KL}(P \Vert Q) = \sum_{i \in N}{P(i) * \log{\frac{P(i)}{Q(i)}}}

Here, :math:`N` is the total number of quantized distributions. :math:`P` is
Int8 distribution (or expected probabilities) and :math:`Q` is the reference
probabilities i.e. the Float32 space.

.. TODO
   better formatting for algorithm

**The Algorithm**:

For each Layer (per-tensor):

* Collect histograms of activations.
* Generate many quantized distributions with different saturation values
  (min/max)
* Pick the scale and min/max value which has minimum :math:`D_{KL}`.

See :cite:`nvidia_tensorrt2017` for a detailed exposition.

Floating Point Multiplication/Division on FPGA
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The scale value is a floating-point number, ergo, the quantization operation is
a multiplication of a floating point number with a Int32 (with dequantization being a float division).

Floating point operations are costly on the FPGA. There is a need for a
transformation of the numbers so that a :math:`Float32 x Int32` can be
approximated to a :math:`Int32 x Int32`. In other words, float operations need
to be converted to cheaper integer based operations such as integer
multiplication and bit shifting.  An intuition for the idea is in order.

If we were to multiply this with a significantly big integer, its
fractional part would become greater. If this is followed by a round operation,
what we would have is an integer which encapsulates many digits from the
original float. How many depends on the big number that we multiplied it with.

.. math::

   round(0.7653764212 * 10^6) = round(765376.4212) = 765376

The resulting integer is an encapsulation of our floating point number.
Multiplying this with the other integer results in an integer via integer
multiplication. As we had brought in a multiplication (of the big number), we
need to reverse this by a following division with the same big number. Whatever
is the result now, is our approximated :math:`Float32 x Int32` operation carried
out via a :math:`Int32 x Int32`.

Formally, Consider a float :math:`X_e` (:math:`e` stands for :math:`exact`) multiplied
with an integer :math:`I`. 

.. math::

   P = X_e * I

:math:`P` can also be written as:

.. math::

   P = \frac{X_e * B * I}{B}

Here, :math:`B` is a big integer (preferably a power of 2, for eg, :math:`2^{16}`).
:math:`X_e * B` is the fixed multiplied :math:`FM`. Intuitively, :math:`FM` can
be understood as new scaling value in our integer world. 

To cut the chase short, perform :math:`FM = X_e * B` on CPU, send (:math:`FM`,
:math:`B`) to the FPGA. On the FPGA, perform :math:`FM * I` as a
:math:`Int32xInt32` operation, followed by a right shift of :math:`2^B` to
reverse the multiplication.

The value of B impacts the precision of the final result. 

.. seealso::

    `Quantization - Intel Distiller Project <https://intellabs.github.io/distiller/quantization.html>`_

    `Gemmlowp - Google <https://github.com/google/gemmlowp/blob/master/doc/low-precision.md>`_

.. TODO
   B value and how it co-relates to overflowing.

Dropout
========

.. TODO:
   this

Maxpooling
==========

You may notice that maxpooling in VGG16 is with 2x2
kernel and stride 2. Consider a 224x224 matrix. First maxpooling is
operated on elements 1,2,225,226 - these are first two-elements of
rows 1 and 2. Second maxpool is on elements 3,4,227,228. however,
partial sum that are generated which eventually feed to maxpool are
in row-major order. thus 225,226 will not be present in immediate
next cycles of elements 1,2. This is a problem. so our first goal is
to solve maxpooling operation for incoming elements in row-major and
at the same time we should preserve pipelineing that enables high
throughput. To achieve this, maxpooling is done in three steps:

   -  Phase1 comparison. compares two elements at a time and outputs the
      greater element. e.g. cycle1 compares elements 1 and 2. cycle 2
      compares elements 3 and 4. *be sure not to compare elements 2 and
      3 in cycle 2*.
   -  FIFO1 to stage results from phase1. back to our example matrix,
      224x224. In row1, we have 112 comparisons. so, the FIFO stores 112
      values. so head of the FIFO points to greater value in elements 1
      and 2. second FIFO index points to greater value in elements 3 and
      4 and likewise till elements 223, 224.
   -  We then start row2. Here perform phase1 comparison. But now we do
      not push the result to FIFO instead push to phase2 comparison.
   -  phase2 comparison. compares two elements at a time and outputs the
      greater element. operand one is element that is read from FIFO1
      and operand two is result from phase1 comparision. the final
      result of maxpooling operation is obtained after phase2. you may
      visualize that odd rows are first pushed to FIFO while the even
      rows are directly forwarded to phase2 comparison.

   All the above three steps constitute hardware for maxpooling block.
   **total maxpooling blocks is equal to number of columns in one
   compute engine**.

Batch Normalization
====================

.. TODO:
   this

Bus
---

This block is work in progress and is lead by Praveen. Details will be
updated as they are available.

Typically, a bus is a medium of communication between different hardware
blocks. The block that initiates a request is called *master*, and
*slave* responds. E.g. a compute engine that processes the data does one
read request to memory to bring the inputs and one write request to
writeback the processed data. memory here is the slave.

for other queries: praveen

End to end flow for a given layer 
---------------------------------

.. note::

  This flow abstracts microarchitecture details

T1 - Default State
==================

What is the default state?

The system is in its default state when it is idle and only the DRAM has
been initialized. i.e., DRAM contains the input images, weights, and
configurations required for input/ output, and tail blocks. The weight
and im2col FIFOs are both empty.

T2 Start im2col Block
=====================

Our im2col profile analysis revealed that it has a ~450 cycle cold start
time. So, this takes precedence over the weight block. However, this is
a one-time occurrence and is not a recurring tendency. Requests for
im2col and weights blocks are handled on a first-come, first-served
basis at a later stage. The idea is to understand the execution pattern
so that we can postpone few requests to a later point in time as all
requesting-blocks (e.g. im2col and weight blocks) might not need the
data right away.

.. note::

  1. The cycle difference between the first im2col column
  entering row FIFO and the cycle when the first column from FIFOs is
  pushed into SA is referred to as the “cold start time” in this context.
  We must acknowledge that the data is biased because of im2col’s design.
  Therefore, it takes 450 cycles for us to reach the point where every row
  is available, each containing at least one element, and is therefore
  prepared for pushing into the SA.
  
  2. See :ref:`bounding_squares` im2col architecture for more understanding on this 450 cycle latency.

T3 Start Weight Block
=====================

We handle requests from the weight block after the memory controller
responds to an im2col request. A burst read request can be sent at first
by weight blocks. DRAM can write up to (512x32 bytes of data) in this
scenario. The process is atomic for the first 288 bytes of data. (SA is
responsible for this. The first step is to pre-load the weights into
specific weight buffers in the SA PE. This corresponds to 288 bytes in a
9x32 SA grid.) It may be interrupted for later bytes if there are more
requests to handle by memory controller. At this point, weight block can
accept any external commands to push data to SA once 288 elements are
available.

T4 Message Passing Between Im2col And Weight Blocks
===================================================

Before delving into the explanation of message passing, it is important
to keep in mind that while all other blocks can initiate data requests,
only the dram block can initiate configuration requests. Message passing
between weight block and im2col makes sure that pushing input and
flashing SA (loading weights): (1) Properly pushed into SA to prevent
premature flashing and contaminating the current weights. (2) Before
adding the next channel or switching to a new layer, a given input
channel must only be iterated a set number of times. (The terms
“channels” here refer to the three original RGB channels or the layer N
output’s k channels, which serve as layer N+1’s input.)

The main questions we address here are: (1) How long must weights be
stationed in SA, or, alternatively, when should we flash SA with new
weights? (2) The number of iterations a channel must undergo on SA
before switching to a new channel is limited.

1. The number of times a channel needs to load? Every time SA is
   flashed.
2. How many flashes of SA are necessary? -> (a) Is dependent on the size
   of the SA column. (b) is dependent upon #unique kernels. For example,
   layer 1 in VGG16 contains 64 distinct kernels, whereas the column
   size in our SA is 32. Thus, ``(#kernels / SA col size)`` is the
   formula for the number of times SA needs to be flashed. In this case,
   64/32 = 2.
3. When must SA be flashed? -> after the final column of the expanded
   matrix that is pushed into SA, or at the end of im2col. Here, a
   counter is required to keep track of this. The expanded matrix for a
   224x224 input matrix has columns equal to 50176 columns, which is the
   same as 224 multiple times 224.
4. When does one need to load a new channel? Following the push of #SA
   flash times by the current channels.

This is one possible approach with decentralized control. Nevertheless,
we leave this to implementation on how to manage the im2col block,
weight block and incoming configurations from configuration block. Other
approach is to have a centralized control that decodes the configuration
and manages weight and im2col blocks.

T5 Accumulating the output partial sums.
========================================

For each SA flash, we iterate a channel once in our current data flow.
The output FIFO has the partial sums and convolution outputs, which are
then sent to DRAM. The partial sums of kernel<1> on all channels must be
added together in accordance with the NN algorithm. However, according
to our algorithm, these partial sums of other channels are neither
immediately accessible nor can previous channels be stored and
accumulated using on-FPGA BRAM due to their large sizes. We therefore
came up with this plan to control the accumulation of output partial
sums.

To do this: First, the DRAM controller receives the output partial sums
from SA, which are then written into DRAM. Second, the previous
channel’s output is read from DRAM and is currently awaiting the
addition of the subsequent channel’s partial sums. Third, a vector
addition unit (an adder tree) receives both incoming and just-from-DRAM
psums for the purpose of adding. Fourth, the total is written back. This
is a pipelined and iterative process. All of the accumulation has
already been completed by the time the final partial sums from SA
arrive. Final accumulation happens shortly after the DRAM controller
receives the output psum of the final channel from SA. These psum
deposits can now be used as input to the next layer.
