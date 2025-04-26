# Generalize Pooling Module

This module performs generalized pooling operations with configurable pooling types and dimensions. The operation is divided into several stages and submodules to manage data processing efficiently.

## Module Descriptions

### Pooling First Stage
In the pooling first stage, the pooling action is determined by the signal `pooling_type`. A counter counts up to the `pool_width` and updates the register `temp` value.

### Counter Demux
The counter demux module generates the select line for the module `demux_for_fifo1`.The select line toggles according to the `pool_height` (kernel height).

### Demux for FIFO1
The demux_for_fifo1 module assigns data based on the select line into FIFO1. It differentiates between intermediate data from `pooling_second_stage` and data from `pooling_first_stage`.

### FIFO1 and FIFO2
FIFO1 and FIFO2 contain the first stage pooled data, each holding one column of the actual image.

### Pooling Second Stage
The pooling_second_stage module takes in data from the two FIFOs, and the pooling type is decided by the signal `pooling_type`. The pooling operation is then performed for the second time.

### Counter Pooling Second
The counter_pooling_second module decides if the data coming out of `pooling_second_stage` is intermediate data or the final pooling output. This decision depends on the `pool_height` signal. If the counter equals `pool_height`, the result from `pooling_second_stage` is the final pool operation output. Otherwise, it is intermediate data and is sent back to FIFO1.

### Counter Rowwise Columnwise
The counter_rowwise_columnwise module counts the entire image height and width (`OH` and `OW`, respectively). It consists of two counters: `row_counter` and `column_counter`. When `row_counter` reaches its maximum (`OW`), `column_counter` increases by one, and the `counter_for_demux` (mentioned earlier) gets its data valid signal to start functioning.

## Operation Flow

1. **Pooling First Stage:** Based on the `pooling_type` signal, the initial pooling operation is performed, updating the `temp` register.
2. **Counter Demux:** Generates the select line for `demux_for_fifo1` based on the `pool_height`.
3. **Demux for FIFO1:** Assigns data to FIFO1, distinguishing between intermediate data from `pooling_second_stage` and data from `pooling_first_stage`.
4. **FIFO1 and FIFO2:** Store the first stage pooled data, each containing the first two rows of the image.
5. **Pooling Second Stage:** Takes data from FIFO1 and FIFO2 to perform the second pooling operation based on the `pooling_type`.
6. **Counter Pooling Second:** Determines if the output from `pooling_second_stage` is intermediate data or the final pooled result, based on `pool_height`.
7. **Counter Rowwise Columnwise:** Manages overall image row and column counting, ensuring proper functionality of `counter_for_demux` when `row_counter` reaches its maximum.

## Testing

### UART Receiver and Transmitter
- **UART Receiver:** Collects 8-bit data and sends it to the first FIFO.
- **UART Transmitter:** Sends the final result from the second FIFO.

### Additional FIFOs
- **FIFO for RX Data:** Collects 8-bit data from the UART receiver and sends it to the Generalize Pooling Module.
- **FIFO for TX Data:** Collects the final result from the Generalize Pooling Module to be sent out via the UART transmitter.

### Controller
The controller manages the read signal of the second FIFO and the data valid signal of the UART transmitter.

![image](https://github.com/vicharak-in/Gati/assets/114066925/7c804c12-2b58-4ed4-8c54-d98b154f6e52)

![image](https://github.com/vicharak-in/Gati/assets/114066925/2fe4ab63-079a-43cd-8ddf-0ad145b2ae5f)

![image](https://github.com/vicharak-in/Gati/assets/114066925/7c467588-37dd-472b-9066-0cf1541439ab)





