# im2col

Systolic Arrays can play a crucial role in accelerating the computationally intensive process of CNN as they are capable of doing fast 
matrix mutliplication with PE grid structure but on the other hand in convolution what we need is dot-product based multiplication. So,
to bridge the gap between convolution and systolic arrays comes in 'im2col' ,i.e, image to column. It slides the filter window across the 
image, extract the patches according to the kernel size and rearranges them into columns which can then be fed into the systolic array for faster computation.

## Explanation of how im2col operates

First, the image data is received from the DRAM along with vital informtion such as kernel size, stride, image dimensions and zero padding which acts as an input to the im2col block. 
After the data is received in the register buffers, each image pixel is coupled with a coordinate which are then to be arranged into 
the image FIFOs according to the filter window.

The no. of image fifos is equal to the number of rows in the systolic array and each one of them have their own bounds which are calculated according to the kernel size and the image
dimensions and are compared with the coordinates. With the help of these bounds and coordinates which will appear in a row major format, we'll control the fashion in which the data is 
being written into the FIFOs by controlling their write enables in order to achieve desired goal.

## Sub-Blocks of im2col

### Index_to_corrdinate

This block provides the image data coming from DDR it's respetive coordinate in a row major format and also manages the when to send the actual data and when to send zeros according to
the padding information such as where to padd and how much to padd that has been made available to it.

### Bound_generation

This block is responsible of generating the bounds for each image FIFO and also controls the write enable of the FIFOs with the help of bounds calculated and the coordinates from the previous block.
It also takes care of the part to perform different types of convolution such as depthwise, pointwise and normal.

### Stride_block

This blocks takes care of the stride part where it performs conventional mod opertion in a faster and efficient way. The inspiration behind this architecture came this research paper 'link'
which uses a seven stage pipline arhcitecture to reduce the the number of resources and increase the speed as well.

### Dely_reisters

These are nothing but a set of registers to delay the output of bound_generation block to match the initial delay of stride_block as a combined output of both the blocks becomes my final ouput 
for the im2col block.

Below given is the block diagram of im2col architecture

<img src="test\images\im2col.drawio.png" alt="im2col Block">

## Steps for testing the design

1. Create a '.mem' file to provide all the necessary inputs and data to im2col block.

2. Next, we need to make FIFO to store the incoming data from mem file, so that we don't miss any data. Also, a controller to bring the data from mem file to fifo.

3. Now, we need another controller which will carefully read the first the inputs and the data from FIFO to the input ports of the im2col block.

4. After uploding the design onto the Vaaman board, open the debugger create the reset signal as a trigger and check the waveform for functional verification.

