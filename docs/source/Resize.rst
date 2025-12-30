
.. _Resize:

Resize Upsample Operator
###########################

Concept
******
The Resize block is responsible for upsampling the input Image/feature map to 2x scale, i.e,
an image of ``8x8`` dimension will be upsampled ot ``16x16``, a ``20x20`` image would be upsampled to ``40x40`` and so on.

``TODO:`` The resize operator as of now only supports 2x upsampling, as most of the running models require this alone. The controllers
and whole architecture has been designed to support this, and has to be parameterized in future to support upsampling of multiple scales.

Module Architecture
*******************

Gen top Upsample 
================
This wrapper module instantiates the dram_fifo controller and generates N_SA number of top_resize_block modules.
Each module upsamples data from individual channels, i.e, ``MOD2*DATA_WIDTH`` bits individually.

Here, 

     :math:`MOD2 = \frac{AXI\_DATA\_BYTES}{N\_SA}.`

DRAM FIFO Controller 
===================
The fifo controller is responsible for feeding read enable signals to the DRAM FIFO. 
The Image fifos have been reused for the resize operator to reduce resource utilization. 
Appropriate multiplexing of the control signals have been put in place depending on the current value of ``opcode`` register.


Top Resize Block 
================
This is the core upsampling module, and instantiates one BRAM (``simple_dpram``) of depth ``log2(DRAM_IMG_FIFO_DEPTH)``, ``bram_wr_ctrl`` and  ``bram_rd_ctrl`` modules. 
Signal delaying of ``o_valid`` and ``o_done`` signals are performed here, to ensure BRAM latency is taken care of.

BRAM Write Controller
=====================
The data from DRAM FIFO are fed into N\_SA top_resize_block instances by the wrapper module by slicing exactly one channel's data per instance. 
Hence, N\_SA BRAMs (one in each top_resize_block instance) store exactly one channel's data from DRAM FIFOs, i.e, ``MOD2*DATA_WIDTH`` bits. 
Input data from the FIFO is directly written into the BRAMs with one element (``DATA_WIDTH`` bits) in each address location. 
Depth of each BRAM ensures the input image doesn't wrap up to reuse address spaces before upsampling is performed. 
The Controller asserts a start signal for the read controller when exactly one row has been written into the BRAM.

BRAM Read Controller
====================
The read controller performs the main upsampling logic by simply reading the same data multiple times, smartly adjusting the repetitive function to align with the row-major format for the Systollic Array.
Each address location (one element) is read twice before proceeding to the next element. 

The row_counter and col_counter keeps track of the elements being read, and the controller resets the address to the initial element of the row, upon reaching the final element, thus repeating the same row again.

The controller assers the ``o_done`` signal when the last element of the last row has been read.

Resize Operator's Block Diagram
*******************************

.. image:: /_static/resize.svg
