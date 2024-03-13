// contains both a axi stream master and slave controller
module fft_controller #(parameter FFT_POINTS = 16, DATA_WIDTH = 24) (
    input logic clk, reset,
    input logic start_fft,
    input logic [DATA_WIDTH-1:0] in_data [0:FFT_POINTS-1],
    output logic [31:0] out_data_real [0:FFT_POINTS-1],
    output logic [31:0] out_data_imag [0:FFT_POINTS-1],
    output logic fft_data_valid,
    output logic fft_in_prog
);


    localparam LOG2_POINTS = $clog2(FFT_POINTS);

    // internal register for holding in_data
    // lowest half of bits = real 
    // highest half of bits = imaginary
    logic [2*DATA_WIDTH-1:0] local_in_data [0:FFT_POINTS-1] = '{default:0};

    int i;
    always_ff @(posedge clk) begin
        if (reset == 1'b1) begin
            fft_data_valid <= 0;
            fft_in_prog <= 0;
        end
        else if (start_fft == 1'b1) begin
            fft_data_valid <= 0;
            fft_in_prog <= 1;
            // load in_data into local_in_data if start_fft is high
            for (i=0; i<FFT_POINTS; i++) begin
                local_in_data[i][DATA_WIDTH-1:0] <= in_data[i];
            end
        end
    end 

    // axi master (input data to fft block)
    logic [2*DATA_WIDTH-1:0] axis_m_data; // data stream value to send to slave
    logic axis_m_valid = 0; // master writes 1 to this if ready to send data
    logic axis_m_ready;     // slave writes 1 to this if ready to receive data
    logic axis_m_last = 0;  // master writes 1 if current frame is the last one
    logic [LOG2_POINTS:0] m_count;
    logic m_write_in_prog = 0; // 

    always_ff @(posedge clk) begin
        if (reset == 1'b1) begin
            axis_m_data <= 0;
            axis_m_valid <= 0;
            axis_m_last <= 0;
            m_count <= 0;
            m_write_in_prog <= 0;
        end 
        else if (start_fft == 1'b1) begin
            m_write_in_prog <= 1;
        end
        else if (m_write_in_prog == 1'b1) begin
            // data logic 
            if (axis_m_ready == 1'b1 && m_write_in_prog == 1'b1) begin
                axis_m_data <= local_in_data[m_count];
                axis_m_valid <= 1;
                m_count <= m_count + 1;
            end
            // last logic 
            if (m_count == FFT_POINTS-1 && axis_m_ready == 1'b1) begin // ex. FFT size = 8, want to check when count = 6 since last should be high on 7
                axis_m_last <= 1;
            end
            else axis_m_last <= 0;
            // valid logic (always high after start_fft until reaches end of counter)
            if (m_count == FFT_POINTS && axis_m_ready) begin
                axis_m_valid <= 0;
                m_write_in_prog <= 0;
            end
        end
    end

    // axi config master: configuration data, in this setup there are 8 bits,
    // LSB = 1 for forward and 0 for inverse transform
    // rest of bits are padding
    logic [7:0] axis_m_config_data;
    logic axis_m_config_valid = 0;
    logic axis_m_config_ready;

    always_ff @(posedge clk) begin
        if (reset == 1'b1) begin
            axis_m_config_data <= 8'd1;
            axis_m_config_valid = 1;
        end
    end

    // axi slave (receive output of fft block)
    logic [63:0] axis_s_data; // data stream value to receive from master
    logic axis_s_valid; // master writes 1 to this if ready to send data
    logic axis_s_ready = 0;     // slave writes 1 to this if ready to receive data
    logic axis_s_last;  // master writes 1 to this on last data frame
    logic [LOG2_POINTS-1:0] s_count; // index 

    always_ff @(posedge clk) begin
        if (reset == 1'b1) begin
            axis_s_ready <= 0;
            // axis_s_data <= 63'd0;
            s_count <= 0;
        end
        else if (axis_s_valid && axis_s_ready) begin
            out_data_real[s_count] <= axis_s_data[31:0];
            out_data_imag[s_count] <= axis_s_data[63:32];
            s_count <= s_count + 1;
            if (axis_s_last == 1'b1) begin
                axis_s_ready <= 0;
                fft_in_prog <= 0;
                fft_data_valid <= 1;
            end
        end
        else if (fft_in_prog == 1'b1) axis_s_ready <= 1;
    end

    // instantiate fft module
    xfft_0 fft_0 (
      .aclk(clk),                                                // input wire aclk
      .s_axis_config_tdata(axis_m_config_data),                  // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(axis_m_config_valid),                // input wire s_axis_config_tvalid
      .s_axis_config_tready(axis_m_config_ready),                // output wire s_axis_config_tready
      .s_axis_data_tdata(axis_m_data),                      // input wire [47 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(axis_m_valid),                    // input wire s_axis_data_tvalid
      .s_axis_data_tready(axis_m_ready),                    // output wire s_axis_data_tready
      .s_axis_data_tlast(axis_m_last),                      // input wire s_axis_data_tlast
      .m_axis_data_tdata(axis_s_data),                      // output wire [63 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(axis_s_valid),                    // output wire m_axis_data_tvalid
      .m_axis_data_tready(axis_s_ready),                    // input wire m_axis_data_tready
      .m_axis_data_tlast(axis_s_last)                      // output wire m_axis_data_tlast
      // .event_frame_started(event_frame_started),                  // output wire event_frame_started
      // .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
      // .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
      // .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      // .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      // .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
    );

endmodule