module testbench_FFT();

    localparam FFT_POINTS = 16;
    localparam DATA_WIDTH = 24;

    logic clk, reset;
    logic start_fft;
    logic [23:0] in_data [0:FFT_POINTS-1];
    logic [31:0] out_data_real [0:FFT_POINTS-1];
    logic [31:0] out_data_imag[0:FFT_POINTS-1];
    logic fft_data_valid;
    logic fft_in_prog;

    // localparam FFT_DATA_WIDTH = DATA_WIDTH + $clog2(DATA_WIDTH) + 1, // need to add extra bits so fft doesn't overflow
    fft_controller fft_c_0 (clk, reset, start_fft, in_data, out_data_real, out_data_imag, fft_data_valid, fft_in_prog);

    always begin 
        #1; 
        clk = ~clk;
    end

    int i;
    initial begin
        clk = 0;
        reset = 1;

        // create square wave signal alternating between 1 and -1 every 2 indices
        for (i=0; i<FFT_POINTS; i=i+1) begin
            if (i%4 < 2) in_data[i] = 24'h400000;
            else         in_data[i] = 24'hC00000;
        end
        #5;
        reset = 0;
        #5;
        start_fft = 1;
        #5;
        start_fft = 0;
       
    end

endmodule //testbench
        
