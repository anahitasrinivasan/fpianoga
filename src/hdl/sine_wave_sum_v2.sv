`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module sine_wave_sum_v2(
    input wire clk_in,
    input wire rst_in,
    input wire [NUM_NOTES-1:0] notes_playing, //saying what the notes being played are
    input wire coeff_info_ready,
    input wire freq_info_ready,
    input wire [NUM_HARMONICS-1:0][31:0] coeff_phases,
    input wire [NUM_HARMONICS-1:0][8:0] coeff_magnitudes,  //todo: think about the dimensions of this; for now 10 bits should be fine (upper bit is the sign bit)
    input wire step_in,
    output logic sum_valid_out,
    output logic [7:0] sum_out //todo: maybe change the dimensions on this as well
);

///////////////////////NOTES////////////////////////

//notes playing: [do,do#,re,re#/mi_bemol,mi,fa,fa#,sol,sol#/la_bemole,la,si_bemole,si,do] aka C4-C5
//notes playing [0,1,2,3,.....]

//do state machine that keeps track of the instantaneous phase of every note; wayy better; do one note freq at a time
//13x64 lookup table - see if really 64 but yeah...
//keep track of previous phase, and of ouput of that phase 

//////////////////////////////////////////////////////

localparam NUM_HARMONICS = 5;
localparam NUM_NOTES = 8;

//logic signed [(18+NUM_HARMONICS*NUM_NOTES)-1:0] out_sum_total;
//logic signed [17+3:0] out_sum_total;
logic signed [17+3:0] out_sum_total;
logic signed [17+3:0] out_sum_total_2;
//logic signed [7:0] out_sum_total;
logic all_info_ready;
assign all_info_ready = coeff_info_ready&&freq_info_ready;

////////INSTANTIATE THE 8KHz TRIGER HERE ///////
//                                            //
//                                            //
///////////////////////////////////////////////

logic triggered_8KHz_step;
assign triggered_8KHz_step = step_in;

///// INSTANTIATING THE LUT TO ITERATE THROUGH /////////
logic [NUM_NOTES-1:0][NUM_HARMONICS-1:0][31:0] phase_increment_lut;
logic [NUM_NOTES-1:0][NUM_HARMONICS-1:0][31:0] phases_on_lut;
logic signed [NUM_NOTES-1:0][NUM_HARMONICS-1:0][7:0] sine_outputs_rawdog_lut; 
logic signed [NUM_NOTES-1:0][NUM_HARMONICS-1:0][17:0] sine_outputs_weighted_lut; //(10+8)
//logic signed [NUM_NOTES-1:0][NUM_HARMONICS-1:0][7:0] sine_outputs_weighted_lut;

always_comb begin
    phase_increment_lut[0][0] = 32'b0000_1000_0111_0000_1100_1000_0000_1000; //C4 Fund
    phase_increment_lut[0][1] = 32'b0001_0001_0001_1010_1011_1001_0000_0110; //C4 H2
    phase_increment_lut[0][2] = 32'b0001_1000_0101_1010_1011_1001_0000_0110; //C4 H3
    phase_increment_lut[0][3] = 32'b0010_0010_0011_1010_1011_1001_0000_0110; //C4 H4
    phase_increment_lut[0][4] = 32'b0010_1100_0111_1010_1011_1001_0000_0110; //C4 H5
    phase_increment_lut[1][0] = 32'b0000_1001_0110_1000_0101_1011_0000_0011; //D4 Fund
    phase_increment_lut[1][1] = 32'b0001_0010_1101_0101_0010_0001_1100_0100; //D4 H2
    phase_increment_lut[1][2] = 32'b0001_1100_0011_0101_0010_0001_1100_0100;//D4 H3
    phase_increment_lut[1][3] = 32'b0010_0101_1001_0101_0010_0001_1100_0100; //D4 H4
    phase_increment_lut[1][4] = 32'b0010_1110_1111_0101_0010_0001_1100_0100; //D4 H5
    phase_increment_lut[2][0] = 32'b0000_1010_1000_1000_0011_1010_0000_0000; //E4 Fund
    phase_increment_lut[2][1] = 32'b0001_0101_0011_1101_1110_1001_1000_0000; //E4 H2
    phase_increment_lut[2][2] = 32'b0010_0011_1001_1101_1110_1001_1000_0000; //E4 H3
    phase_increment_lut[2][3] = 32'b0010_1110_1111_1101_1110_1001_1000_0000; //E4 H4
    phase_increment_lut[2][4] = 32'b0011_0101_0101_1101_1110_1001_1000_0000; //E4 H5
    phase_increment_lut[3][0] = 32'b0000_1011_0010_1100_0100_0000_0000_0000; //F4 Fund
    phase_increment_lut[3][1] = 32'b0001_0110_0111_1100_0111_1010_0110_0111; //F4 H2
    phase_increment_lut[3][2] = 32'b0010_0011_1011_1100_0111_1010_0110_0111; //F4 H3
    phase_increment_lut[3][3] = 32'b0010_1110_1111_1100_0111_1010_0110_0111; //F4 H4
    phase_increment_lut[3][4] = 32'b0011_0111_1001_1100_0111_1010_0110_0111; //F4 H5
    phase_increment_lut[4][0] = 32'b0000_1100_0110_1000_0000_0000_0000_0000; //G4 Fund
    phase_increment_lut[4][1] = 32'b0001_1001_1001_1011_0111_0111_0110_0110; //G4 H2
    phase_increment_lut[4][2] = 32'b0010_1001_1001_1011_0111_0111_0110_0110; //G4 H3
    phase_increment_lut[4][3] = 32'b0011_0100_1001_1011_0111_0111_0110_0110; //G4 H4
    phase_increment_lut[4][4] = 32'b0011_1110_1001_1011_0111_0111_0110_0110; //G4 H5
    phase_increment_lut[5][0] = 32'b0000_1110_0000_1000_0000_0000_0000_0000; //A4 Fund
    phase_increment_lut[5][1] = 32'b0001_1100_0000_0000_0000_0000_0000_0000; //A4 H2
    phase_increment_lut[5][2] = 32'b0010_1010_0000_0000_0000_0000_0000_0000; //A4 H3
    phase_increment_lut[5][3] = 32'b0011_1000_0000_0000_0000_0000_0000_0000; //A4 H4
    phase_increment_lut[5][4] = 32'b0100_0110_0000_0000_0000_0000_0000_0000; //A4 H5
    phase_increment_lut[6][0] = 32'b0000_1111_1100_1101_1101_1101_0110_1110; //B4 Fund
    phase_increment_lut[6][1] = 32'b0010_0010_1100_0010_1000_1001_0110_0010; //B4 H2
    phase_increment_lut[6][2] = 32'b00011111100110111100111111010101;
    phase_increment_lut[6][3] = 32'b0100_1110_1100_0010_1000_1001_0110_0010;
    phase_increment_lut[6][4] = 32'b0100_1111_1100_0010_1000_1001_0110_0010;
    phase_increment_lut[7][0] = 32'b0001_0000_1011_0110_1100_0000_0000_0000; //C5 Fund
    phase_increment_lut[7][1] = 32'b0010_0010_0011_1010_1011_1001_0000_0110; //C5 H2
    phase_increment_lut[7][2] = 32'b0011_0111_0101_1010_1011_1001_0000_0110; //C5 H3
    phase_increment_lut[7][3] = 32'b0100_1000_1011_1010_1011_1001_0000_0110; //C5 H4
    phase_increment_lut[7][4] = 32'b0101_0100_1111_1010_1011_1001_0000_0110; //C5 H5
end
////////////////////////////////////////////////////////


///////// SETTING UP ACTUAL ADDING LOGIC PER 8KHZ TRIGGER //////////

//great for pipelining and setting signals as needed, 
//and is nice because no matter how many harmonics being used, can expect the same amount of pipelineing per stage 
//because will be using the same amount of  notes at all times

typedef enum {IDLE, UPDATING, SCALING, ADDING, OUTPUTTING, ERROR} adding_stages; 
adding_stages state;
logic [$clog2(NUM_NOTES)-1:0] i_updating; //note_on
logic [$clog2(NUM_HARMONICS)-1:0] j_updating; //harmonic on
logic [$clog2(NUM_NOTES)-1:0] i_scaling;
logic [$clog2(NUM_HARMONICS)-1:0] j_scaling;
logic [$clog2(NUM_NOTES)-1:0] i_adding;
logic [$clog2(NUM_HARMONICS)-1:0] j_adding;

/////////SETTING UP SINE GEN INSTANTIATION WITH VARIABLES///////////

logic [31:0] sine_phase_offset_in;
assign sine_phase_offset_in = phases_on_lut[i_updating][j_updating];
logic note_playing_in; //will be passed into valid_info_in; assigned by looking at if a note is playing
assign note_playing_in = notes_playing[i_updating];
logic [31:0] sine_phase_increment;
assign sine_phase_increment = phase_increment_lut[i_updating][j_updating];

logic [31:0] sine_gen_phase_out;
logic signed [7:0] sine_gen_amp_out;

sine_generator_v2 sine_wave (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .phase_offset_in(sine_phase_offset_in),
    .phase_increment(sine_phase_increment),
    .valid_info_in(note_playing_in&&all_info_ready),
    .amp_out(sine_gen_amp_out),
    .full_phase_next_out(sine_gen_phase_out)
);

////////////////////////Dealing with the first update////////////////////////////////////////////
logic first_update_done;
logic [NUM_NOTES-1:0][NUM_HARMONICS-1:0][31:0] init_phase_lut;

always_comb begin
    //lut is 8x2x32; (num_notesxnum_harmonicsxsize_phase)
    if (all_info_ready&&(!first_update_done))begin
        init_phase_lut[0] = coeff_phases;
        init_phase_lut[1] = coeff_phases;
        init_phase_lut[2] = coeff_phases;
        init_phase_lut[3] = coeff_phases;
        init_phase_lut[4] = coeff_phases;
        init_phase_lut[5] = coeff_phases;
        init_phase_lut[6] = coeff_phases;
        init_phase_lut[7] = coeff_phases;
    end else begin
        init_phase_lut = init_phase_lut;
    end
end

/////////////

always_ff @(posedge clk_in)begin
    if (rst_in)begin
        sum_out <= 0;
        out_sum_total <= 0;
        sum_valid_out <= 0;
        out_sum_total_2 <= 0;

        phases_on_lut <= 0; //change later to what should be, for now leave as this
        sine_outputs_rawdog_lut <= 0;
        sine_outputs_weighted_lut <= 0;

        i_updating <= 0;
        i_scaling <= 0;
        i_adding <= 0;
        j_updating <= 0;
        j_scaling <= 0;
        j_adding <= 0;

        first_update_done <= 0;
        state <= IDLE;
    end else begin
        //use for loops to add all values in the above arrays when necessary
        case(state)
            IDLE: begin
                //re-set all indexing values
                i_updating <= 0;
                j_updating <= 0;
                i_scaling <= 0;
                j_scaling <= 0;
                i_adding <= 0;
                j_adding <= 0;
                out_sum_total <= 0;
                out_sum_total_2 <= 0;
                state <= (triggered_8KHz_step&&all_info_ready)? UPDATING:IDLE;
                phases_on_lut <= ((!first_update_done)&&all_info_ready)? init_phase_lut: phases_on_lut;
                //phases_on_lut <= ((!first_update_done)&&all_info_ready)? 0: phases_on_lut;
            end UPDATING: begin
                first_update_done <= 1;
                //updating lookup tables for phase_next and sine_output
                phases_on_lut[i_updating][j_updating] <= (note_playing_in)? sine_gen_phase_out: coeff_phases[j_updating];
                sine_outputs_rawdog_lut[i_updating][j_updating] <= {~sine_gen_amp_out[7], sine_gen_amp_out[6:0]};
                ///Updating indexing
                i_updating <= (j_updating == NUM_HARMONICS-1)? ((i_updating == NUM_NOTES-1)? 0: i_updating + 1): i_updating;
                j_updating <= (j_updating == NUM_HARMONICS-1)? 0: j_updating+1;
                //// Updating State
                //sum_out <= {j_updating, i_updating};
                state <= ((i_updating == NUM_NOTES-1)&&(j_updating==NUM_HARMONICS-1))? SCALING: UPDATING;
            end SCALING: begin
                //sum_out <= 8'b11_010100;
                sine_outputs_weighted_lut[i_scaling][j_scaling] <= ($signed({1'b0,coeff_magnitudes[j_scaling]}))*($signed(sine_outputs_rawdog_lut[i_scaling][j_scaling]));
                //sine_outputs_weighted_lut[i_scaling][j_scaling] <= (j_scaling == 1)? 0: sine_outputs_rawdog_lut[i_scaling][j_scaling];
                //sine_outputs_weighted_lut[i_scaling][j_scaling] <= (j_scaling == 4)? 0: ($signed(coeff_magnitudes[j_scaling]))*$signed(sine_outputs_rawdog_lut[i_scaling][j_scaling]);
                //sine_outputs_weighted_lut[i_scaling][j_scaling] <= (j_scaling != 0)? 0: ($signed(coeff_magnitudes[j_scaling]))*$signed(sine_outputs_rawdog_lut[i_scaling][j_scaling]);
                //sine_outputs_weighted_lut[i_scaling][j_scaling] <= ($signed(coeff_magnitudes[j_scaling]))*$signed(sine_outputs_rawdog_lut[i_scaling][j_scaling]);
                //sine_outputs_weighted_lut[i_scaling][j_scaling] <= sine_outputs_rawdog_lut[i_scaling][j_scaling]; 
                //Updating indexing
                i_scaling <= (j_scaling == NUM_HARMONICS-1)? ((i_scaling == NUM_NOTES-1)? 0: i_scaling + 1): i_scaling;
                j_scaling <= (j_scaling == NUM_HARMONICS-1)? 0: j_scaling +1;
                //Updating state
                state <= ((i_scaling == NUM_NOTES-1)&&(j_scaling==NUM_HARMONICS-1))? ADDING: SCALING;
            end ADDING: begin
                //out_sum_total <= $signed(out_sum_total) + $signed((sine_outputs_weighted_lut[i_adding][j_adding]));
                out_sum_total <= $signed(out_sum_total) + $signed((sine_outputs_weighted_lut[i_adding][j_adding]));
                //Updating indexing
                i_adding <= (j_adding == NUM_HARMONICS-1)? ((i_adding == NUM_NOTES-1)? 0: i_adding + 1): i_adding;
                j_adding <= (j_adding == NUM_HARMONICS-1)? 0: j_adding +1;
                //Updating state
                state <= ((i_adding == NUM_NOTES-1)&&(j_adding==NUM_HARMONICS-1))? OUTPUTTING: ADDING;
            end OUTPUTTING: begin
                //sum_out <= out_sum_total[7:0]; //missing the [7:0]
                //out_sum_total_2 <= ($signed(out_sum_total>>>5)+$signed(out_sum_total>>>3));
                //sum_out <= out_sum_total_2[16:9];
                //sum_out <= out_sum_total[19:12];
                sum_out <= out_sum_total[20:13];
                //sum_out <= 8'b11_010100;
                sum_valid_out <= 1;
                state <= IDLE;
            end ERROR: begin
                state <= ERROR;
            end default: begin
                state <= IDLE;
            end
        endcase
    end
end

//assign sum_out = out_sum_total_2[16:9];

endmodule

`default_nettype wire