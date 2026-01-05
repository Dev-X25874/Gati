.. _mega_pool:

Mega Pool Module
================

This module is designed to perform pooling operations (e.g., max pooling, average pooling) on input data arrays. 

Mega Pool Architecture
----------------------
The `mega_pool` module consists of the following files:

1. **Top Pool Engine**
   - The top-level module that integrates all submodules and orchestrates the pooling operation.
   - It instantiates multiple pool PE array modules to process data in parallel.

2. **Pool PE Array**
   - Manages an array of PEs for pooling.
   - Chains multiple Pool PE block instances to perform the pooling operation row by row.

3. **Pool PE**
   - The basic processing element for pooling.
   - Similar to SA PEs, just without weights. Elements are loaded with different delays and are compared/added based on the selected operation.
   - Performs the actual pooling operation (e.g., max or sum) on two input data values.

4. **Image FIFO Array RDEN Pool**
   - Controls the read enable signals for the image FIFO array based on the availability of data and other conditions.
   - Ensures that data is read from the FIFOs only when all FIFOs have valid data.


Data Flow
---------

1. **Input Data Preparation:**
   - Input data is fed into the image FIFO array, where it is staged for processing.
   - The `image_fifo_array_rden_pool` module generates read enable signals to ensure that data is read from the FIFOs only when all FIFOs have valid data.

2. **Pooling Operation:**
   - The `top_pool_engine` module orchestrates the pooling operation by instantiating multiple `top_pool_PE_array` modules.
   - Each `top_pool_PE_array` module processes a subset of the input data using its internal `Pool_PE_array` and `Pool_PE_block` modules.
   - The `Pool_PE_block` modules perform the actual pooling operation (e.g., max or sum) on pairs of input data values.

3. **Output Data Generation:**
   - The results of the pooling operation are collected and output by the `top_pool_engine` module.
   - Data-valid signals are generated to indicate when the output data is valid.

Block Diagram
-------------

.. image:: /_static/mega_pool.svg
