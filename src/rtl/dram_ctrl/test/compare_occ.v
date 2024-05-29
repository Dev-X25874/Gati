module CompareFifoOccupants #(parameter N = 8,DEPTH=512)(
    input [N*($clog2(DEPTH)+1)-1:0] occupants,
    input burst_len,
    output reg result
);

integer i;
reg [($clog2(DEPTH)+1):0] fifo_occupants [0:N-1];
reg fifo_occupied_enough; // Track if each FIFO has enough occupants

always @* begin
    result = 1; // Initialize result to true
    
    // Extract and compare each FIFO's occupants
    for (i = 0; i < N; i = i + 1) begin
        fifo_occupants[i] = occupants[(i+1)*($clog2(DEPTH)+1)-1-:($clog2(DEPTH)+1)]; // Assign occupants to fifo_occupants
        fifo_occupied_enough = (fifo_occupants[i] >= (burst_len+1)); // Check if current FIFO has enough occupants
        result = result && fifo_occupied_enough; // Update overall result
    end
end

endmodule