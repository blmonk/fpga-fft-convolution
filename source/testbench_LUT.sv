module testbench_LUT();

    logic [3:0] index;
    logic signed [23:0] twiddle_real, twiddle_imag;

    // instantiate look up table
    twiddle_LUT #(.FFT_POINTS(16)) lut0 (
        .index(index), 
        .twiddle_real(twiddle_real), 
        .twiddle_imag(twiddle_imag)
    );

    initial begin
        index = 4'd0;   #10;
        index = 4'd1;   #10;
        index = 4'd2;   #10;
        index = 4'd3;   #10;
        index = 4'd4;   #10;
        index = 4'd5;   #10;
        index = 4'd6;   #10;
        index = 4'd7;   #10;
        index = 4'd8;   #10;
        index = 4'd9;   #10;
        index = 4'd10;  #10;
        index = 4'd11;  #10;
        index = 4'd12;  #10;
        index = 4'd13;  #10;
        index = 4'd14;  #10;
        index = 4'd15;  #10;
    end

endmodule
        
