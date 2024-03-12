// module for performing decimation, first step of fft
// switches indices around according to a binary mirror
module decimation #(parameter FFT_POINTS = 16, DATA_WIDTH = 30) (
    input logic [DATA_WIDTH-1:0] in_data [0:FFT_POINTS-1],
    output logic [DATA_WIDTH-1:0] decimated_data [0:FFT_POINTS-1]
);

    localparam LOG2_POINTS = $clog2(FFT_POINTS);

    integer i, j, reversed_index;
    logic [LOG2_POINTS-1:0] reversed_index_bits;
    always_comb begin
        for (i = 0; i < FFT_POINTS; i=i+1) begin
            reversed_index = 0;
            for (j = 0; j < LOG2_POINTS; j=j+1) begin
                reversed_index_bits[j] = i[j];
            end
            for (j = 0; j < LOG2_POINTS; j=j+1) begin
                reversed_index = reversed_index | (reversed_index_bits[j] << (LOG2_POINTS - 1 - j));
            end
            decimated_data[i] = in_data[reversed_index];
        end
    end

endmodule