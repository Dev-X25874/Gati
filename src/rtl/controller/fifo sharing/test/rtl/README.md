# FIFO Sharing Controller

The FIFO Sharing Controller facilitates the sharing of a weight FIFO array between a Systolic Array (SA) engine and a Fully Connected (FC) layer. It consists of a multiplexer (mux) which selects whether to send weights from the FIFO array to the SA or FC layer.

## Description

This controller operates based on signals received from the read controllers present in the SA or FC block. Depending on the select signal from the mux, weights are loaded into either the SA or FC block. The selection is determined by the opcode received from the configuration block.

## Parameters

- `N_SA`: Number of SA engines
- `COL_SA`: Number of columns inside each SA engine
- `COL_FC`: Total number of columns in the FC block
- `N_BRAM_BYTES`: Number of bytes read from BRAM in one clock cycle

## Functionality

- When weights are to be read into the FC block, all weights (equal to `COL_FC`) are read simultaneously from the weight FIFO array.
- if `(N_SA * COL_SA) < N_BRAM_BYTES` then weights are loaded into the SA block, in ping pong manner, i.e., the weights are read from the first half of the FIFO array, then after one channel iteration is completed, it switches to reading from the remaining half.
- If `(N_SA * COL_SA) >= N_BRAM_BYTES`, weights from all the FIFO array will be read together in the SA engine, similar to how the FC block operates.
