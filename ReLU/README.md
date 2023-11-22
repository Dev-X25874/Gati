**ReLU Block**

*Overview*

This folder contains the design and implementation of a ReLU (Rectified Linear Unit) activation block with three variants: standard ReLU, ReLU-6, and ReLU-8.

*ReLU variants and their implementation*
1. ReLU
   The ReLU activation function checks if the input data is greater than or equal to zero. If true, the output is set to the input value. If false (i.e., the input 
   is negative), the output is set to zero. This mirrors the fundamental behavior of the ReLU activation, where negative values are replaced with zeros, and positive values remain unchanged.

2. ReLU-6
   For the ReLU-6 variant, the implementation builds upon the ReLU logic. First, it checks if the input is greater than or equal to 6. If true, the output is clipped to 6. If false, it falls back to the ReLU logic, ensuring that negative values are set to zero, and positive values are forwarded. This variant introduces a maximum threshold, limiting the output to 6.

3. ReLU-8
   The ReLU-8 variant extends the concept of ReLU-6 by setting a higher threshold at 8. Similar to the ReLU-6 implementation, it first checks if the input is greater than or equal to 8. If true, the output is clipped to 8. If false, it falls back to the ReLU logic, ensuring that negative values are set to zero, and positive values are forwarded.
   

   
   




owner of the block is Chaya
