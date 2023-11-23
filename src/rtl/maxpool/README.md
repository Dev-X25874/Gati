# General Idea of Maxpooling

Maxpooling is a downsampling operation commonly employed in neural networks, especially convolutional neural networks (CNNs). It involves dividing an input feature map into non-overlapping regions, typically 2x2 or 3x3 grids(in VGG 16 's case:- 3x3 grid kernel), and selecting the maximum value from each region. The selected maximum values form a reduced-size output feature map, providing spatial dimensionality reduction. This operation helps in computational efficiency, translation invariance, and feature reduction by focusing on the most prominent features in the input data. Maxpooling is widely used in conjunction with convolutional layers to create hierarchical representations in deep learning models.



# Maxpool Design Overview

This repository presents a custom hardware design for a maxpooling operation implemented in Verilog. The design comprises several interconnected modules that collectively perform maxpooling on incoming data.



# Design Modules

## Counter1:

-Toggles the select line of Demux1 at every positive edge of the clock.
-Controls the flow of data through the subsequent stages of the design.

## Demux1:

-Takes 1 byte of input and assigns it to the 1st output.
-Holds the value of the first output in a register until the second input is received and assigned to the 2nd output.

## Maxpool:

-Takes the two outputs from Demux1 and performs maxpooling.
-Compares the two 8-bit values and outputs the greater of the two as an 8-bit result.

## Counter2:

-Toggles the select line of Demux2 after the final element of a matrix column(each element is of 1 byte) have been received.
-Facilitates the transition to the next batch of data for processing.

## Demux2:

-Select line toggles due to Counter2.
-1st batch of a matrix column elements get stored in FIFO1, and the 2nd batch gets stored in FIFO2.

## FIFO1 and FIFO2:

-Respective memory blocks performing first in, first out (FIFO) activity.
-Supply the input for the next stage of maxpooling.

## Maxpool:

-Takes 1 byte of data at a time from each FIFO.
-Conducts the maxpool operation and outputs the maximum of the two values.
