# vaaman-quantization

## Bias and Quantization

### Bias and Quantization in a nutshell

`Bias` can be defined as the constant which is added to the product of features and weights. It is used to offset the result. It helps the models to shift the activation function towards the positive or negative side.

If x is the input feature and m is the weight, 
```
f(x)=mx
```
The same linear function with the bias would be,
```
y=f(x) + b
```
Here's the image of how the bias can impact the activation function

![image](https://github.com/vicharak-in/vaaman-quantisation/assets/102940423/9f6d04b8-8940-4fbe-ade1-d3523e30e1b8)


`Quantization` is a techinique of re-encoding information, in a smaller bit-width. Refer [this](https://github.com/vicharak-in/Gati/blob/rst_docs/docs/source/quantization.rst) for a detailed explanation. 



### Implementation of Bias and Quantization on Vaaman in verilog

The design gets the input from the previous block and adds a pre-determined bias value then sends this output to the quantizer which multiplies with the scale and right shifts it. The same has been implemented in Verilog in this design.

For the testing on Vaaman we've used UART. 

The .xml file, .v files, .vcd files have been added in this repo.


### Branching strategy employed

This strategy involves three main branches: `main`, `test`, and `develop`. 

1. Main branch - The `main` branch serves as the primary branch that contains the finalized and latest design of our hardware project. Code is merged into main only after thorough testing and validation.

2. Test branch - The `test` branch is dedicated to hosting all the files required for testing on hardware boards.

3. Develop branch - The `develop` branch is the workspace for ongoing development. It contains the latest code changes, including features that are still in progress or undergoing testing. This branch allows for collaboration among team members without impacting the stability of the main branch.


### Output Waveforms
![image](https://github.com/vicharak-in/vaaman-quantisation/assets/102940423/289c1967-5851-46f2-a89a-8a1108d8c997)


The above image shows the input and the output interfacing signals of the first instance of quantisation module.


### Input and output

Instructions and configurations for interfacing with your hardware design was done through `GTKterm`. GTKterm is a versatile terminal emulator that facilitates communication with hardware devices through a serial interface. The input sent and the output received through GTKterm is given shown in the below picture. 

 * This is an example for 3 instnaces of quantisation blocks where the inputs are bit shift, scale, bias data and the input data from the ReLU.
 * The first 4 words of data represent the bit shift/no. of time to be shifted, scale/scale value to be multiplied with, data bias/predetermined bias data to be added, input data/from the ReLU of the first quantization instance.
 * The next subsequent 2 words represent the input data to the other two instances of quantisation.

![image](https://github.com/vicharak-in/vaaman-quantisation/assets/102940423/99fd007c-3db6-4be4-a14f-ce3d14f355e3)
