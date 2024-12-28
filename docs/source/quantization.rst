.. _quantization:

A Deeper Look Into Quantization
###############################

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

.. image:: _static/Quantization.png
   :width: 40%
   :align: center

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
******************************

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
*******************

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
*****************

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
***********************************************

The scale value is a floating-point number, ergo, the quantization operation is
a multiplication of a floating point number with a Int32 (with dequantization being a float division).

.. image:: _static/Quantization1.png
   :width: 60%
   :align: center

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
