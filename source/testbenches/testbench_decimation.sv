module testbench_decimation();

    logic signed [29:0] in_data [0:15]; 
    logic signed [29:0] decimated_data [0:15]; 

    decimation #(.FFT_POINTS(16), .DATA_WIDTH(30)) dec_0 (
        .in_data(in_data), 
        .decimated_data(decimated_data)
    );

    int i;
    initial begin
        for (i=0; i<16; i=i+1) begin
            in_data[i] = i;
        end
    end

endmodule
        
