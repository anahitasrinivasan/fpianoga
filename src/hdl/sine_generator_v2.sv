`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

//need to find phase increment such that have sampling rate such that if had 440Hz note, given 8000KHz sampling rate, how would we increment the sine generator 

//Sine Wave Generator
module sine_generator_v2 (
  input wire clk_in,
  input wire rst_in, //clock and reset
  //input wire step_in, //trigger a phase step (rate at which you run sine generator); will be running at 8KHz; will trigger outside of the module
  input wire [31:0] phase_offset_in,//phase offset coming from arctan(ratio_ceofficients) - computed in arctan.sv module; or coming in from the previous 
  input wire valid_info_in, //note_playing&&valid_info_ready/in?
  input wire [31:0] phase_increment,
  //output logic valid_amp_out, //probably don't need
  output logic [7:0] amp_out, //output amplitude in 2's complement; 
  output logic [31:0] full_phase_next_out);


// Notes: 
//that it takes to do this (determine this - can use simple formula probably - do it on paper later) - from this, output values for the amplitude need to be 
//the output values of sine at 2*pi/64*timestep
//so phase_on will represent 1/64th of a unit circle (the incrementation between phases) - will also determine what the possible outputs of the arctan function will be

//parameter PHASE_INCR = 32'b1000_0000_0000_0000_0000_0000_0000_0000>>3; //1/16th of 12 khz is 750 Hz
//will be determined by the note we are trying to play
//logic [31:0] phase_on;
logic [5:0] phase_lookup;

always_comb begin
    phase_lookup = (valid_info_in)? phase_offset_in[31:26]: 6'b0; //so that output value will be 0 if not valid information in 
    full_phase_next_out = (valid_info_in)? phase_offset_in + phase_increment: phase_offset_in; 
end

always_comb begin
  // Only need to figure out values for 1st quadrant, the rest follow pretty easily -- need to remember these values are signed (beware of upper bit); choosing to have 6 bits of precision for now for the fixed point decimal part of the number
    case(phase_lookup) 
        // 6'd0: amp_out= 8'b0;
        // 6'd1: amp_out= 8'b00_000110; //0.098
        // 6'd2: amp_out= 8'b00_001100; //0.195
        // 6'd3: amp_out= 8'b00_010010; //0.290
        // 6'd4: amp_out= 8'b00_011000; //pi/8 = 0.383
        // 6'd5: amp_out= 8'b00_011110; //0.471
        // 6'd6: amp_out= 8'b00_100011; //0.556
        // 6'd7: amp_out= 8'b00_101000; //0.634
        // 6'd8: amp_out= 8'b00_101101; //when at 2*pi/64*8 = pi/4 = 0.707
        // 6'd9: amp_out= 8'b00_110001; //0.773
        // 6'd10: amp_out= 8'b00_110101; //0.831
        // 6'd11: amp_out= 8'b00_111000; //0.882
        // 6'd12: amp_out= 8'b00_111011; //0.924
        // 6'd13: amp_out= 8'b00_111101; //0.956
        // 6'd14: amp_out= 8'b00_111110; //0.981
        // 6'd15: amp_out= 8'b00_111111; //0.995
        // 6'd16: amp_out = 8'b01_000000; // when at 2*pi/64*16 = pi/2 ; outputing 1
        // 6'd17: amp_out= 8'b00_111111; //0.995
        // 6'd18: amp_out= 8'b00_111110; //0.981
        // 6'd19: amp_out= 8'b00_111101; //0.956
        // 6'd20: amp_out= 8'b00_111011; //0.924
        // 6'd21: amp_out= 8'b00_111000; //0.882
        // 6'd22: amp_out= 8'b00_110101; //0.831
        // 6'd23: amp_out= 8'b00_110001; //0.773
        // 6'd24: amp_out= 8'b00_101101; //0.707
        // 6'd25: amp_out= 8'b00_101000; //0.634
        // 6'd26: amp_out= 8'b00_100011; //0.556
        // 6'd27: amp_out= 8'b00_011110; //0.471
        // 6'd28: amp_out= 8'b00_011000; //7*pi/8 = 0.383
        // 6'd29: amp_out= 8'b00_010010; //0.290
        // 6'd30: amp_out= 8'b00_001100; //0.195
        // 6'd31: amp_out= 8'b00_000110; //0.098
        // 6'd32: amp_out= 8'b00_000000; // outputting 0
        // //negative values now
        // 6'd33: amp_out= 8'b11_000110; //-0.098
        // 6'd34: amp_out= 8'b11_001100; //-0.195
        // 6'd35: amp_out= 8'b11_010010; //-0.290
        // 6'd36: amp_out= 8'b11_011000; //9pi/8 = -0.383
        // 6'd37: amp_out= 8'b11_011110; //-0.471
        // 6'd38: amp_out= 8'b11_100011; //-0.556
        // 6'd39: amp_out= 8'b11_101000; //-0.634
        // 6'd40: amp_out= 8'b11_101101; //when at 2*pi/64*8 = pi/4 = -0.707
        // 6'd41: amp_out= 8'b11_110001; //-0.773
        // 6'd42: amp_out= 8'b11_110101; //-0.831
        // 6'd43: amp_out= 8'b11_111000; //-0.882
        // 6'd44: amp_out= 8'b11_111011; //-0.924
        // 6'd45: amp_out= 8'b11_111101; //-0.956
        // 6'd46: amp_out= 8'b11_111110; //-0.981
        // 6'd47: amp_out= 8'b11_111111; //-0.995
        // 6'd48: amp_out= 8'b10_000000; // outputing -1
        // 6'd49: amp_out= 8'b11_111111; //-0.995
        // 6'd50: amp_out= 8'b11_111110; //-0.981
        // 6'd51: amp_out= 8'b11_111101; //-0.956
        // 6'd52: amp_out= 8'b11_111011; //-0.924
        // 6'd53: amp_out= 8'b11_111000; //-0.882
        // 6'd54: amp_out= 8'b11_110101; //-0.831
        // 6'd55: amp_out= 8'b11_110001; //-0.773
        // 6'd56: amp_out= 8'b11_101101; //when at 2*pi/64*8 = pi/4 = -0.707
        // 6'd57: amp_out= 8'b11_101000; //-0.634
        // 6'd58: amp_out= 8'b11_100011; //-0.556
        // 6'd59: amp_out= 8'b11_011110; //-0.471
        // 6'd60: amp_out= 8'b11_011000; //9pi/8 = -0.383
        // 6'd61: amp_out= 8'b11_010010; //-0.290
        // 6'd62: amp_out= 8'b11_001100; //-0.195
        // 6'd63: amp_out= 8'b11_000110; //-0.098 //will not be 0 again
        // default: amp_out = 8'b0; //check if this is how handle case defaults in system verilog (I think so)
        6'd0: amp_out<=8'd128;
      6'd1: amp_out<=8'd140;
      6'd2: amp_out<=8'd152;
      6'd3: amp_out<=8'd165;
      6'd4: amp_out<=8'd176;
      6'd5: amp_out<=8'd188;
      6'd6: amp_out<=8'd198;
      6'd7: amp_out<=8'd208;
      6'd8: amp_out<=8'd218;
      6'd9: amp_out<=8'd226;
      6'd10: amp_out<=8'd234;
      6'd11: amp_out<=8'd240;
      6'd12: amp_out<=8'd245;
      6'd13: amp_out<=8'd250;
      6'd14: amp_out<=8'd253;
      6'd15: amp_out<=8'd254;
      6'd16: amp_out<=8'd255;
      6'd17: amp_out<=8'd254;
      6'd18: amp_out<=8'd253;
      6'd19: amp_out<=8'd250;
      6'd20: amp_out<=8'd245;
      6'd21: amp_out<=8'd240;
      6'd22: amp_out<=8'd234;
      6'd23: amp_out<=8'd226;
      6'd24: amp_out<=8'd218;
      6'd25: amp_out<=8'd208;
      6'd26: amp_out<=8'd198;
      6'd27: amp_out<=8'd188;
      6'd28: amp_out<=8'd176;
      6'd29: amp_out<=8'd165;
      6'd30: amp_out<=8'd152;
      6'd31: amp_out<=8'd140;
      6'd32: amp_out<=8'd128;
      6'd33: amp_out<=8'd115;
      6'd34: amp_out<=8'd103;
      6'd35: amp_out<=8'd90;
      6'd36: amp_out<=8'd79;
      6'd37: amp_out<=8'd67;
      6'd38: amp_out<=8'd57;
      6'd39: amp_out<=8'd47;
      6'd40: amp_out<=8'd37;
      6'd41: amp_out<=8'd29;
      6'd42: amp_out<=8'd21;
      6'd43: amp_out<=8'd15;
      6'd44: amp_out<=8'd10;
      6'd45: amp_out<=8'd5;
      6'd46: amp_out<=8'd2;
      6'd47: amp_out<=8'd1;
      6'd48: amp_out<=8'd0;
      6'd49: amp_out<=8'd1;
      6'd50: amp_out<=8'd2;
      6'd51: amp_out<=8'd5;
      6'd52: amp_out<=8'd10;
      6'd53: amp_out<=8'd15;
      6'd54: amp_out<=8'd21;
      6'd55: amp_out<=8'd29;
      6'd56: amp_out<=8'd37;
      6'd57: amp_out<=8'd47;
      6'd58: amp_out<=8'd57;
      6'd59: amp_out<=8'd67;
      6'd60: amp_out<=8'd79;
      6'd61: amp_out<=8'd90;
      6'd62: amp_out<=8'd103;
      6'd63: amp_out<=8'd115;
      default: amp_out <= 0;
    endcase
  end
  
endmodule

`default_nettype wire