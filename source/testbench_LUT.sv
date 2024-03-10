module testbench_LUT();

    logic signed [23:0] twiddle_real [0:15]; 
    logic signed [23:0] twiddle_imag [0:15]; 

    // instantiate look up table
    twiddle_LUT #(.FFT_POINTS(16), .FILENAME("cos_lut_16.mem")) lut0 (
        // .index(index), 
        .twiddle_real(twiddle_real), 
        .twiddle_imag(twiddle_imag)
    );

endmodule
        
