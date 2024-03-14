// computes 1024 length fft and writes to file
module testbench_FFT_large();

    localparam FFT_POINTS = 1024;
    localparam DATA_WIDTH = 24;

    logic clk, reset;
    logic start_fft;
    logic forward_inverse;
    logic signed [23:0] in_data_real [0:FFT_POINTS-1];
    logic signed [23:0] in_data_imag [0:FFT_POINTS-1];
    logic signed [39:0] out_data_real [0:FFT_POINTS-1];
    logic signed [39:0] out_data_imag[0:FFT_POINTS-1];
    logic fft_data_valid;
    logic fft_in_prog;

    fft_controller #(.FFT_POINTS(FFT_POINTS), .DATA_WIDTH(24)) fft_c_0 
    (clk, reset, start_fft, forward_inverse, in_data_real, in_data_imag, out_data_real, out_data_imag, fft_data_valid, fft_in_prog);

    always begin 
        #1; 
        clk = ~clk;
    end

    int i;
    initial begin
        int file_handle;
        file_handle = $fopen("fft_output.txt", "w");

        // Check if file opened successfully
        if (file_handle == 0) begin
            $display("Error: Unable to open file for writing");
            $finish;
        end

        clk = 0;
        reset = 1;
        forward_inverse = 1; // foward transform

        // create square wave with period = fft length
        for (i=0; i<FFT_POINTS; i=i+1) begin
            if ((i/16) % 2 == 0)     in_data_real[i] = 24'h400000;
            else                in_data_real[i] = 24'hC00000;
        end
        in_data_imag = '{default:0};

        #5;
        reset = 0;
        #5;
        start_fft = 1;
        #5;
        start_fft = 0;

        // Wait for signal to go high
        @(posedge fft_data_valid);

        // Write array contents to file
        for (i=0; i<FFT_POINTS; i=i+1) 
            $fwrite(file_handle, "%d,%d\n", out_data_real[i], out_data_imag[i]);

        // Close the file
        $fclose(file_handle);
        $display("Array contents have been written to file.");
        // $finish;
       
    end

endmodule 