Alignment and Reordering of data for computation
################################################

DRAM can only be accessed in fixed bitwidths. Moreover, designing computation
engines (SA/FC) etc. to take fixed sizes/bitwidth of elements keeps the
controllers simple. In real world, we may not always get data aligned to our
expected bitwidths. For example, an SA of configuration 9x4x4 expects atleast 4
channels and 4 kernels for correct computation. This problem in Gati, has been
deferred to the software. The software will make sure all weights and first
inputs are aligned to the underlying engines. Therefore, in case of 9x4x4 SA, to
carry out a 3 channel convolution, an extra 4th channel of only zeros will be
appended to the weight tensor by the software.

Alignment can be thought of as a way to make data fit the underlying computation
engines. It is done in multiple dimensions: 

The first dimension of alignment is for the engines namely: SA, VA, BiasAdd,
FCBiasAdd.

The second dimension of alignment is for the DRAM's address width. For vaaman,
it is 32B. So all data must be aligned to 32B.

The third dimension of alignment is for the channel width of the CPU to 
FPGA communication link. This may vary, or even be out of control of 
Gati—be done by low level libraries meant for communicating with the 
FPGA. 

First Dimension (Engine Based Alignment)
========================================

TODO

Second Dimension (DRAM Based Alignment)
========================================

TODO

Third Dimension (Engine Based Alignment)
========================================

TODO
