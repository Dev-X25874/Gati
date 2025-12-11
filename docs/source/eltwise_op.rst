.. _eltwise_op:

Element-Wise Processing Block
=============================

Overview
--------
The Element-Wise (EW) block performs arithmetic or activation operations between two
input feature-map streams after convolution. It consists of:

* Input reordering modules
* FIFO buffering subsystem
* EltWise controller that performs scheduling, read enable generation, and valid timing
* An array of ``element_wise_op`` compute units (N parallel lanes)
* Optional LUT-based activation compute blocks
* Output aggregation and validity signalling

This block supports:

* Addition
* Subtraction
* Multiplication
* Activation functions (Sigmoid / Tanh)

and automatically manages fp-cast quantization for output precision adjustment.

System Architecture
-------------------

The EW processing pipeline includes the following stages:

1. **Input Reordering**
2. **Operand FIFO Buffering**
3. **EltWise Controller**
4. **Parallel Element-Wise Compute Array**
5. **Output Formatting**


.. _eltwise_reorder:

Input Reordering (conv_output_reorder_EW)
-----------------------------------------
The input operands arrive in convolution output order. ``conv_output_reorder_EW`` maps
the incoming tensor fragments into a lane-major ordering expected by the EW block.

For each FIFO column and row pair, input indices are remapped according to:

.. math::
    out\_idx = (col \times N) + row

.. math::
    in\_idx = (row \times FIFO\_NO) + col

This ensures that each of the :math:`N` lanes of the element-wise processing block receives
the correct per-pixel elements.


FIFO Subsystem
--------------
Each operand stream passes through an array of ``dram_fifo`` instances.
These FIFOs perform:

* Burst-based buffering
* Multi-port read-out using demultiplexed ``element_rd_en`` control
* Empty/full flag generation
* Per-FIFO valid signalling

The FIFOs output:

* ``LeftOperand_data_out``
* ``RightOperand_data_out``
* FIFO status flags used by the controller for scheduling


.. _eltwise_controller:

EltWise Controller
------------------
The controller orchestrates lane-wise reads from both operand FIFOs, and ensures correct
alignment of values forwarded into the ``element_wise_op`` compute lanes.

The main controller responsibilities include:

* Maintaining read-cycle index (:math:`cycle\_idx`)
* Handling image-size driven termination (:math:`EW\_done`)
* Applying modulo padding when feature-map dimensions do not match
* Managing state transitions through four phases:
  
  **State 0:** Normal read and operand forwarding  
  **State 1:** Wait state after full image region read  
  **State 2:** Flush cycles for modulo padding  
  **State 3:** Stall until output FIFOs drain

* Generating ``element_rd_en`` using ``demux_param1``
* Handling activation-only cases where RightOperand is unused
* Producing ``data_valid`` that enables the compute lanes

The controller also detects activation mode (Sigmoid/Tanh) via:

.. math::
    tanh\_switch = (EltWise\_type == ELTWISE\_SIG) \lor (EltWise\_type == ELTWISE\_TANH)


.. _eltwise_array:

Parallel Element-Wise Compute Array
-----------------------------------
The EW block instantiates :math:`N` parallel element-wise compute lanes. Lanes
``0``–``7`` use the standard ``element_wise_op`` implementation,
while lanes ``8`` to ``N-1`` use a LUT-based variant ``element_wise_op_lut``.

Each lane receives:

* :math:`DATA\_WIDTH`-wide LeftOperand
* :math:`DATA\_WIDTH`-wide RightOperand or zero (activation mode)
* ``data_valid`` gating
* EltWise_type
* Scaling and zero-point metadata

Each lane produces:

* :math:`DATA\_WIDTH\_OB`-wide output
* A per-lane ``EltWise_valid`` pulse


.. _element_wise_op_detail:

Element-Wise Operation (element_wise_op)
========================================

Overview
--------
The ``element_wise_op`` module performs the final arithmetic or activation function
processing on a per-pixel basis. This includes:

* Zero-point shifting
* Scaling
* Operation selection (Add/Sub/Mul/Activation)
* Activation functions (Sigmoid / Tanh)
* fp-cast quantization


Input Preprocessing
-------------------

Zero-Point Shifting
^^^^^^^^^^^^^^^^^^^
Each operand is first shifted by its respective zero-point:

.. math::
   LeftOperand\_shifted = LeftOperand - zp_L

.. math::
   RightOperand\_shifted = RightOperand - zp_R

Scaling
^^^^^^^
The shifted operands are scaled:

.. math::
   LeftOperand\_scaled = LeftOperand\_shifted \times LeftOperand\_Scale

.. math::
   RightOperand\_scaled = RightOperand\_shifted \times RightOperand\_Scale

This produces extended-width intermediate values that retain numerical precision.


Operation Selection
-------------------
Depending on ``EltWise_type``, one of the following is applied:

* **Addition**
* **Subtraction**
* **Multiplication**
* **Tanh / Sigmoid Activation** (Refer :ref:`Sigmoid`)

Quantization
------------
The final result is quantized using ``fp_cast`` in the Tail Block:

.. math::
    output = \frac{result \times quant\_scale}{2^{fp\_cast}}

``fp_cast`` is mode-dependent:

* 10 bits for Add/Sub/Mul
* 16 bits for Sigmoid/Tanh

Element-Wise Block diagram:

.. image:: /_static/eltwise_op.svg
   :width: 100%
   :align: center
