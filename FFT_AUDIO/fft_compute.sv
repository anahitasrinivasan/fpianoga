`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module fft_compute (
    input wire clk_in,
    input wire rst_in,
    output logic data_valid_out, //single-cycle high
    output logic [4:0][31:0] top_5_harmonic_coeffs
);

localparam BRAM_DEPTH = 15300; 
//localparam BRAM_DEPTH = 4101;
localparam OFFSET = 0;

xilinx_single_port_ram_read_first
     #(
       .RAM_WIDTH(16),
       .RAM_DEPTH(BRAM_DEPTH),
       .RAM_PERFORMANCE("HIGH_PERFORMANCE"),
       .INIT_FILE("c4_audio.mem")
     ) c4_audio_mem
       (
        .addra(bram_addr),     // Address bus, width determined from RAM_DEPTH
        .dina(0),          // RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),     // Clock
        .wea(1'b0),            // Write enable
        .ena(1'b1),            // RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in), // Output reset (does not affect memory contents)
        .regcea(1'b1),         // Output register enable
        .douta(bram_dout)      // RAM output data, width determined from RAM_WIDTH
        );

logic compute_needed;

/////////INSTANTIATING BRAM VARIABLES//////////
logic [10:0] bram_addr; //will only go up to [0,1024) - actually maybe 1026 (2 cycle delay)
logic [15:0] bram_dout;
//////////////////////////////////////////////


////////INSTANTIATING FFT-RELATED INPUTS AND OUTPUTS /////////
logic fft_in_enable;

logic [15:0] fft_real_out;
logic [15:0] fft_img_out;
logic fft_data_valid_out;

logic [9:0] num_fft_samples_out;
logic all_fft_data_out; //want this to be a single-cycle high - will determine compute_needed for later modules
//logic [4:0][31:0] top_5_harmonic_coeffs; // will be [0,1,2,3,4]; [fund, harm2, harm3. harm4, harm5];

//bin numbers for the desired output frequencies's bin numbers: [5.5744, 11.16, 16.744, 22.33, 27.91]

////////////////////////////////////////////////////////

logic [31:0] extended_dout;
assign extended_dout = $signed(bram_dout);

FFT #(
    .WIDTH(32)
) fft_inst (
    .clock(clk_in),
    .reset(rst_in),
    .di_en(fft_in_enable),
    .di_re(bram_dout),
    .di_im(16'b0),
    .do_en(fft_data_valid_out),
    .do_re(fft_real_out),
    .do_im(fft_img_out)
);


//todo: calculate the bit-reversed order of the bins I want, and on that bin number, will get the associated coefficients and store them in an array

always_ff @(posedge clk_in)begin
    if (rst_in)begin
        compute_needed <= 1;
        bram_addr <= 0;
        fft_in_enable <= 0;
        all_fft_data_out <= 0; 
        num_fft_samples_out <= 0;
        data_valid_out <= 0;
    end else begin
        if (compute_needed)begin
            fft_in_enable <= ((bram_addr>0)&&(bram_addr<1025))? 1: 0;
            bram_addr <= bram_addr +1;
            num_fft_samples_out <= ((fft_data_valid_out)||(all_fft_data_out))? num_fft_samples_out+1: num_fft_samples_out; //or-ing with the all_fft... makes sure increment by one more so that all_fft_data_out goes back to zero
            all_fft_data_out <= (num_fft_samples_out == 1023)? 1: all_fft_data_out;
            compute_needed <= (all_fft_data_out)? 0: compute_needed;
            data_valid_out <= all_fft_data_out;

            if (fft_data_valid_out)begin
                //all_coeff_outputs_fft[num_fft_samples_out] <= {fft_real_out, fft_img_out};
                //if ((num_fft_samples_out == 10'd384)||(num_fft_samples_out == 10'd832)||(num_fft_samples_out == 10'd544)||(num_fft_samples_out == 10'd416)||(num_fft_samples_out == 10'd224)) begin
                if ((num_fft_samples_out == 10'd640)||(num_fft_samples_out == 10'd192)||(num_fft_samples_out == 10'd32)||(num_fft_samples_out == 10'd416)||(num_fft_samples_out == 10'd864)) begin
                    //block where if the bit-reverse order index corresponds to one of the expected bins, then we place the coefficient there in the correct place
                    case(num_fft_samples_out)
                        10'd640: top_5_harmonic_coeffs[0] <= {fft_real_out, fft_img_out};
                        10'd192: top_5_harmonic_coeffs[1] <= {fft_real_out, fft_img_out};
                        10'd32: top_5_harmonic_coeffs[2] <= {fft_real_out, fft_img_out};
                        10'd416: top_5_harmonic_coeffs[3] <= {fft_real_out, fft_img_out};
                        10'd864: top_5_harmonic_coeffs[4] <= {fft_real_out, fft_img_out};
                        default: top_5_harmonic_coeffs <= top_5_harmonic_coeffs;
                    endcase
                end
            end
        end else begin
            compute_needed <= compute_needed;
            data_valid_out <= 0;
        end
    end
end


endmodule

`default_nettype wire