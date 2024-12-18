

Adder Tree
################

This  mini Block implements an adder tree structure with N adder blocks to compute the sum of 20-bit inputs. The adder tree consists of multiple layers where each layer performs addition operations on inputs from the previous layer until a final output is obtained.

.. image:: /_static/adder_tree.svg
    :width: 100%
    :align: center

Functionality
********************

The adder tree block receives inputs from N engines and produces a single 20-bit output. The inputs are fed into the adder blocks in a tree-like fashion:

1. The first layer consists of N/2 adder blocks, each receiving 2 inputs from respective engines and producing 1 output, each.
2. The second layer has N/2 adder blocks, each receiving inputs from 2 adder blocks in the previous layer and producing 1 output, each.
3. The third layer contains a N/2/2 adder block, which takes inputs from the 2 adder blocks in the second layer and produces the final output.
4. In a similar fashion we will have 2logN layers of adder.
