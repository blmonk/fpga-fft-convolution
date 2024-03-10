// lookup table for twiddle factors
// the values used for the LUT are taken from cos_lut_<FFT_POINTS>.mem 
// This is the function cos(2*pi*i/FFT_POINTS) and has size FFT_POINTS (i is an integer)
// make sure FFT_POINTS matches the specific cos_lut filename

module twiddle_LUT #(parameter FFT_POINTS = 16, FILENAME="cos_lut_16.mem", DATA_WIDTH = 24)(
    output logic signed [DATA_WIDTH-1:0] twiddle_real [0:FFT_POINTS-1],  // real part (cos)
    output logic signed [DATA_WIDTH-1:0] twiddle_imag [0:FFT_POINTS-1]   // imaginary part (-sin)
);

    // create cosine LUT from .mem file
    initial begin
        $readmemh(FILENAME, twiddle_real);
    end

    localparam offset = FFT_POINTS / 4; // offset to get -sin from cos

    integer i;
    always_comb begin
        for (i=0; i<FFT_POINTS; i++) begin
            twiddle_imag[i] = twiddle_real[(i + offset) % FFT_POINTS];
        end
    end

endmodule