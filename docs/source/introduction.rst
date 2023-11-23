.. _introduction:

Introduction
############
   
.. contents:: Table of Contents
    :local: 
    :depth: 1

.. _iok:

IFMaps, OFMaps and Kernels
**************************

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
****************

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

Quantization
************

.. TODO
   contents:
    intro
    calibrated s (how to pick scales)
    fast division/multiplication (on fpga)
    doing better (partial/ QAT)

Introduction
============

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
==============================

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
===================

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
=================

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
===============================================

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

Im2Col
******

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

.. bibliography::
