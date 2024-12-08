`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module coeff_info_gen_mags(
    input wire clk_in,
    input wire rst_in,
    // input wire compute_needed,
    input wire valid_data_in,
    input wire [NUM_HARMONICS-1:0][31:0] top_n_coeffs,
    output logic [NUM_HARMONICS-1:0][31:0] coeff_mags_out,
    //output logic [NUM_HARMONICS-1:0][31:0] phase_offsets_out,
    output logic valid_data_out
);

localparam NUM_HARMONICS = 5;
logic [2:0] i_harmonics;

coeff_info_generator info_gen_i (
    .clk_in(clk_in),
    .rst_in(rst_in||(all_info_current_ready)),
    .coeffs_valid_in(current_coeffs_valid_in),
    .coeffs(current_coeffs_in),
    .compute_needed(compute_needed_coeffs_in),
    .magnitude_out(current_mag_out),
    //.phase_out(current_phase_out),
    .all_coeff_info_ready(all_info_current_ready)
);

//Inputs of the coeff info generator
logic [31:0] current_coeffs_in;
logic current_coeffs_valid_in;
assign current_coeffs_in = (i_harmonics<NUM_HARMONICS)? top_n_coeffs[i_harmonics]: top_n_coeffs[0];
//assign current_coeffs_valid_in = valid_data_in; 
logic compute_needed_coeffs_in;

//Outputs of the coeff info generator 
logic [31:0] current_mag_out;
//logic [31:0] current_phase_out;
logic all_info_current_ready;

//So we know when to start generating things from the next set of coefficients
logic coeff_generator_busy;
//logic bram_retrive_busy;

//to be put into output logic
// logic [NUM_HARMONICS-1:0][15:0] all_mags_out;
// logic [NUM_HARMONICS-1:0][15:0] all_phases_out;

//to be put into output logic
//logic [NUM_HARMONICS-1:0][31:0] phase_offsets_out_inter;
logic [NUM_HARMONICS-1:0][31:0] coeff_mags_out_inter;

//todo: make sure only do the below once we know the data in is valid (blanket if statement)
//todo: since the data_valid in is one cycle, have a variable that will keep track of whether the data valid in has ever gone and use that for the blanket if statement instead
//todo: for now keep commenting out stuff that has to do with the arctan module, if have time will take care of it later.

always_ff @(posedge clk_in)begin
    if (rst_in)begin
        i_harmonics <= 0;
        //phase_offsets_out_inter <= 0;
        coeff_mags_out_inter <= 0;
        coeff_generator_busy <= 0;
        compute_needed_coeffs_in <= 0;
        valid_data_out <= 0;
        current_coeffs_valid_in <= 0;
    end else begin
        current_coeffs_valid_in <= (valid_data_in)? 1: current_coeffs_valid_in;
        if (current_coeffs_valid_in)begin
            if (!coeff_generator_busy&&(i_harmonics<NUM_HARMONICS))begin
                coeff_generator_busy <= 1;
                compute_needed_coeffs_in <= 1;
            end else begin
                compute_needed_coeffs_in <= 0;
                valid_data_out <= (i_harmonics>(NUM_HARMONICS-1))? 1: valid_data_out; // then our sine sum module knows that theses outputs are valid and can be used
                coeff_mags_out <= (valid_data_out)? coeff_mags_out_inter: coeff_mags_out;

                coeff_generator_busy <= (all_info_current_ready)? 0:coeff_generator_busy;
                i_harmonics <= (all_info_current_ready)? i_harmonics+1: i_harmonics;

                //phase_offsets_out_inter[i_harmonics] <= (all_info_current_ready)? current_phase_out: phase_offsets_out_inter[i_harmonics];
                coeff_mags_out_inter[i_harmonics] <= (all_info_current_ready)? current_mag_out: coeff_mags_out_inter[i_harmonics];
            end 
        end

    end
end

endmodule


module coeff_info_generator(
    input wire clk_in,
    input wire rst_in,
    input wire coeffs_valid_in,
    input wire [31:0] coeffs, 
    input wire compute_needed, //since only need to compute once per system reset; make compute_needed a single-cycle high
    output logic [31:0] magnitude_out, //make sure right bit width
    //output logic [5:0] phase_out,
    output logic all_coeff_info_ready //needs to be single-cycle high
);

//todo: make sure clock outputs of magnitude module and of phase module so that don't get weird combinational path through this modules
//generates information that comes from the coefficients for the top N frequencies from the FFT


///Computing magnitude here
magnitude_compute magnitude (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .coeffs(coeffs),
    //.coeffs_valid_in(coeffs_valid_in),
    .compute_needed(compute_needed),
    .mag_out(magnitude_out_inter),
    .data_valid_out(magnitude_out_high) //single_cycle_high
);


/// Computing phase here
// arctan phase_compute (
//     .clk_in(clk_in),
//     .rst_in(rst_in),
//     .coeffs(coeffs),
//     .coeffs_valid_in(coeffs_valid_in),
//     .compute_needed(compute_needed),
//     .phase_encoding_out(phase_out_inter),
//     .valid_phase_out(phase_out_high) //single-cycle high
// );

//logic phase_out_high;
logic magnitude_out_high;

//logic phase_out_inter;
logic [31:0] magnitude_out_inter;

//logic phase_computed;
logic magnitude_computed;

//assign all_coeff_info_ready = phase_computed&&magnitude_computed;
assign all_coeff_info_ready = magnitude_computed;

always_ff @(posedge clk_in)begin
    if (rst_in)begin
        magnitude_out <= 0;
        //phase_out <= 0;
        //all_coeff_info_ready <= 0;
        //phase_computed <= 0;
        magnitude_computed <= 0;
        //magnitude_computed <= 0;
    end else begin
        //phase_computed <= (phase_out_high)? 1: phase_computed;
        magnitude_computed <= (magnitude_out_high)? 1: magnitude_computed;
        magnitude_out <= (magnitude_out_high)? magnitude_out_inter: magnitude_out;
        //phase_out <= (phase_out_high)? phase_out_inter: phase_out;
    end
end

endmodule


`default_nettype wire