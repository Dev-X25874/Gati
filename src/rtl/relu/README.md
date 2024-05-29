# vaaman-relu

## Rectified Linear Unit (ReLU) - Activation function in Neural Networks

### ReLU in a nutshell

The rectified linear activation function is a simple calculation that returns the value provided as input directly, or the value 0 if the input is 0 or less. If the clipping is desired, the positive numbers can also be clipped at a certain value.
```
f(x)=max(0,x)
```
![image](https://github.com/vicharak-in/vaaman-relu/assets/102940423/433d0962-dfda-4ddd-a321-956789c370d1)


The above image shows example of ReLU activation function. 

There are a lot of other variants of ReLU like `Softplus`, `leaky ReLU`, `exponential linear unit` (ELU) and `Sigmoid linear unit` (SiLU), etc., which are used to improve performances in some tasks but for our current version we've implemented `ReLU` which is the most used activation functions of all.

### Implementation of ReLU on Vaaman in verilog

The design compares the input from the systolic array and assigns the respective outputs based on the inputs. The same has been implemented in Verilog in this design.

For the testing of the same on Vaaman we've used UART. 

The .xml file, .v files, .vcd files have been added in this repo.

### Branching strategy employed

This strategy involves three main branches: `main`, `test`, and `develop`. 

1. Main branch - The `main` branch serves as the primary branch that contains the finalized and latest design of our hardware project. Code is merged into main only after thorough testing and validation.

2. Test branch - The `test` branch is dedicated to hosting all the files required for testing on hardware boards.

3. Develop branch - The `develop` branch is the workspace for ongoing development. It contains the latest code changes, including features that are still in progress or undergoing testing. This branch allows for collaboration among team members without impacting the stability of the main branch.

### Output Waveforms
![image](https://github.com/vicharak-in/vaaman-relu/assets/102940423/2b479cca-62e7-45cf-b812-07cb3130a251)

The above image shows the input and the output interfacing signals for the three instances of ReLU module.


### Input and output

Instructions and configurations for interfacing with your hardware design was done through `GTKterm`. GTKterm is a versatile terminal emulator that facilitates communication with hardware devices through a serial interface. The input sent and the output received through GTKterm is given shown in the below picture. 

 * This is an example for 3 instnaces of ReLU blocks where the inputs are clip constant and the input data which has to be clipped.
 * The first 3 bytes represent the clipping constants for the 3 ReLU instances.
 * The next subsequent three 32 bits/4 bytes inputs represent the input data to the three instances of ReLU

![image](https://github.com/vicharak-in/vaaman-relu/assets/102940423/59b84745-1891-4325-a792-56bfe37713b3)




