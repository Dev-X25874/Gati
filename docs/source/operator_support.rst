Operator Support
################

.. list-table::
   :widths: 20 75
   :header-rows: 1

   * - Status
     - Meaning
   * - Full
     - Fully covered under design, with implementation underway
   * - Partial
     - Under active design

   * - Undone
     - Not under design as yet but important enough to be considered soon.

.. list-table:: 
   :widths: 50 25 25
   :header-rows: 1

   * - Operator Name
     - Status
     - Type
   * - conv
     - Full
     - Compute
   * - gemm
     - Full
     - Compute
   * - add 
     - Partial
     - Eltwise
   * - mul 
     - Partial
     - Eltwise
   * - div (by 2ⁿ) 
     - Partial
     - Eltwise
   * - pow (of 2ⁿ) 
     - Partial
     - Eltwise
   * - and 
     - Partial
     - Eltwise
   * - or 
     - Partial
     - Eltwise
   * - xor 
     - Partial
     - Eltwise
   * - max
     - Full
     - Pool
   * - avg
     - Full
     - Pool
   * - relu
     - Full
     - Tail
   * - sigmoid
     - Undone
     - Tail
   * - tanh
     - Undone
     - Tail
   * - softmax
     - Undone
     - Tail
   * - reshape
     - Partial
     - Tensor Invisible
   * - squeeze
     - Partial
     - Tensor Invisible
   * - split
     - Partial
     - Tensor Invisible
   * - transpose
     - Partial
     - Tensor Visible
   * - concat
     - Partial
     - Tensor Visible
   * - gather
     - Partial
     - Tensor Visible
   * - scatter
     - Partial
     - Tensor Visible
   * - slice
     - Partial
     - Tensor Visible
   * - cast
     - Partial
     - Tensor Visible
