# Up_Sample

Pooling layers is a common standard convolution process in CNNs used to minimize image size. Even though pooling aids in the capturing 
of higher-level data, some of the original image's specific spatial information—such as location details—is lost in the process. 
To compensate for this loss of spatial information, upsampling is used. It enables the network to perhaps produce outputs that are more 
accurate by raising the resolution of feature maps. There are different types of upsampling, the one we are using is nearest neighbour.

Visual represenatation of Nearest Neighbour Upsampling

<img src="test\images\upsampling1.png" alt="NN_up">

## Explanation of how Up_Sample operates

As we can see in the above image, that each element(pixel) is repeated a certain number of times to increase the resolution. So, the block will receive two 
elements each of 8-bits parallely from each channel. There are 16 such channels all giving inputs parallely in row major fashion, for which our design is having asymmetric FIFOs
with 2:1 ratio, i.e., 16-bit input and 8-bit output. So, basically we'll serialize the incoming parallel data and right them in FIFOs but write the 16 channels
data two times in 32 FIFOs like the same data in first 16 FIFOs (each channel one FIFO) and same data in the remaining 16. From here, the data will be written in DDR (of all the 32 FIFIOs),
which will then  help ahead in reading each element a certain number of times to perform the upsampling.

## Steps for testing the design

1. Take the data from the .mem file through a controller and write them in the aysmmetric FIFOs that we have generated using IP.

2. Now, we'll read the data from all the 32 FIFOs through a read controller and then set 'top_test_upsample' as top module to test the design.

3. After uploding the design onto the Vaaman board, open the debugger create the reset signal as a trigger and check the waveform for functional verification.