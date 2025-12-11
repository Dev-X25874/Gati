
.. _Sigmoid:

Sigmoid/Tanh Module
###################

Concept
*******
The idea is to have a Tanh/Sigmoid compute block as an ``EltWise_Type`` within the ``Element_Wise`` operators.  
The main logic computes Tanh first, and the Sigmoid output is derived using

.. math::
   sigmoid(x) = \frac{1 + tanh(x/2)}{2}

if ``Eltwise_type == ELTWISE_SIG``.

Module Descriptions
*******************

Top Tanh/Sigmoid
================
The input is fed from ``element_wise_op`` module after scaling it with ``Eltwise_Scale``.  
The top module checks the ``i_tanh_sigmoid`` signal and performs :math:`input / 2` if it's high  
(i.e., when ``Eltwise_Type == ELTWISE_SIG``).  

The input is then fed to the ``tanh_interpolator_engine`` after performing a 2’s complement  
if the MSB of the input data is high. The Tanh interpolator_engine inherently operates on unsigned integers, 
and a final 2's compliment is performed on the interpolator_engine's output, by checking the MSB bit of it's corresponding
input data. This works because the :math:`tanh(x)` is an odd function i.e, 
  
  .. math::
    tanh(-x) = -tanh(x)
        

Tanh Interpolator Engine
========================
This module combines the ``input_range_decoder`` and ``interpolator_engine``.  
It also ensures signal alignment through proper delaying to synchronize the interpolated output.

Input Range Decoder
===================
The range decoder compares the input value with ``DATA_SAMPLE_MAX`` and determines the compute region.  
It then generates the control signal for the interpolation region.  
If the input value is greater than ``DATA_SAMPLE_MAX``, the input is clamped to the ``DATA_SAMPLE_MAX`` value before being fed to the interpolator.

Interpolator Engine
===================
This is the core Tanh compute block. The compute methodology includes:

1. Reading precomputed values from:

   - ``interpolation_points.txt``
   - ``slope_values.txt``
   - ``tanh_values.txt``

   to enable faster approximation without computing ``tanh`` directly.

2. Index calculation depends on the input data and is performed as follows:

   - Determine the LUT segment using the difference between the input sample and ``data_sample_min``.
   - Multiply the segment offset with the step size  
     ``N / (DATA_SAMPLE_MAX - DATA_SAMPLE_MIN)``.
   - Compute the segment index using:

     .. math::
        \text{segment\_index} = \frac{x - x_{\min} + l/2}{l}

     where 

     :math:`l = \frac{x_{\max} - x_{\min}}{n}`.


     `x` = input to the interpolator_engine

     :math:`x_{\min}` = ``data_sample_min`` (32'd0 in this case)
     
     `n` = Number of interpolation points (128 in this case)

3. Compute the scaled value using

   .. math::
      \text{scaled\_data} = x_{\text{diff}} * slope\_value

   where :math:`x_{\text{diff}} = x - x_{\text{sample}}`.

4. The interpolated value is obtained by adding  
   :math:`\text{scaled\_data}` and the corresponding scaled ``tanh_value``.
   

5. This gives the Tanh output, which is converted to Sigmoid by:

   .. math::
      sigmoid(x) = \frac{1 + tanh(x/2)}{2}

   when ``EltWise_Type == ELTWISE_SIG``.

   *NOTE*: The Sigmoid/Tanh output is calculated using data scaled to fp16. Hence, the actual hardware compute becomes:

   .. math::
      sigmoid(x) = \frac{65535 + tanh(x/2)}{>>>1}

   when ``EltWise_Type == ELTWISE_SIG``.

6. The output is sent back to ``element_wise_op``, which proceeds to quantization.  
   ``Element_Wise`` operations use ``fp_cast``.  
   It is hardcoded to use **16 bits for Sigmoid/Tanh** and **10 bits for other operations**.

References
**********

[1] `Improving Neural Network Efficiency Using Piecewise Linear Approximation of Activation Functions`_

.. _Improving Neural Network Efficiency Using Piecewise Linear Approximation of Activation Functions:
   https://journals.flvc.org/FLAIRS/article/view/139005/144076

Instruction Integration
***********************
A macro has been added in ``arch_param.vh`` to enable dynamic hardware generation of the Sigmoid/Tanh  
``EltWise_Type``.  
``Instructions.vh`` has also been updated to include the new EltWise types.

Tanh/Sigmoid module's Block Diagram
***********************************

.. image:: /_static/Sigmoid.svg
   :width: 100%
   :align: center
