// lookup table for twiddle factors
// the values used for the LUT are taken from cos_lut.mem 
// This is the function cos(2*pi*i/LUT_POINTS) and has size LUT_POINTS (i is an integer)
// FFT_POINTS can be less than or equal to LUT_POINTS, both always a power of 2
// The point is that any fft size less than size LUT_POINTS can be generated without changing the file cos_lut.mem
// make sure LUT_POINTS/DATA_WIDTH matches the length/data width of cos_lut.mem

module twiddle_LUT #(parameter FFT_POINTS = 1024, parameter LUT_POINTS = 8192, DATA_WIDTH = 24)(
    input logic [$clog2(FFT_POINTS)-1:0] index,         // twiddle factor index (width = log2(FFT_POINTS))
    output logic signed [DATA_WIDTH-1:0] twiddle_real,  // real part 
    output logic signed [DATA_WIDTH-1:0] twiddle_imag   // imaginary part (already includes negative sign)
);

    // create cosine LUT from .mem file
    reg signed [DATA_WIDTH-1:0] cos_lut [0:LUT_POINTS-1];
    initial begin
        $readmemh("cos_lut.mem", cos_lut);
    end

    // Compute the twiddle factors
    always_comb begin
        // if LUT_POINTS > FFT_POINTS, we need different index
        int lut_index = index * (LUT_POINTS / FFT_POINTS);

        twiddle_real = cos_lut[lut_index];

        // Compute the imaginary part (-sin) using shifted cos function
        int offset = LUT_POINTS / 4; // offset for -sin function
        int imag_index = (lut_index + offset) % LUT_POINTS;
        twiddle_imag = cos_lut[imag_index];
    end

endmodule