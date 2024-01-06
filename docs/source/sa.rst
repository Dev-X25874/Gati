.. _sa:

Operating the Systolic Array
############################

.. TODO

Regular Convolution on SA
*************************

Fully Connected Layers on SA
****************************

For fully connected (FC) layers, only one row of SA is used for computation.
The outputs at each column are accumulated to previous value. This can be
visualized as 1-D SA where the input moves horizontally and each column 
receives a weight. It can be noticed that, in FC layers a weight is only 
used once. Thus having 1-D (1-row x N-columns) SA is sufficient; as 
inputs are reused across weights, they are passed horizontally, 
while weights are not used more than once, they are passed vertically.

Upon finishing the computation of last convolution layer, the output of maxpool
layer is the valid data that is to be used as input to FC layer. This data is stored
in TDP RAM (via port B) such that first 8 channels data are stored in 8 TDP RAMs and 
next 8 channels data are stored in another subsequent 8 TDP RAMs and so on. This is 
repeated in round-robin fashion till all the layer ouputs gets stored.

After storing all the valid FC data inputs in TDP RAMs, each TDP RAM is read sequentially
and fed to SA (operating in 1-D mode as discussed in above sections) whose outputs are 
accumulated at the end of each SA column of 8 engines. This accumulated results are further
applied to a 256-bit register wherein, it provides 8 bytes in a cycle to the quantizer.
These results are again stored back in TDP RAMs which are read when next FC layer begins.
Finally, the last FC layer results are stored in DRAM as 32-byte bursts. 
