`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);
 
  logic [8:0] q_m;
 
  tm_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));

  logic [3:0] tally;
  logic [3:0] tally_new;
  logic [3:0] net_ones;
  logic more_tilt;
  logic invert;
  logic [3:0] increment;

  assign net_ones = (q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7]) - 4'd4;
  assign more_tilt = (net_ones[3] == tally[3]); // the signs are the same so we will either tilt towards more ones or more zeros
  
  // more_tilt: 1 if we're pushing tally more extreme, 0 otherwise
  // so if balanced, we do the opposite of q_m[8]
  // otherwise, we invert if tilted and we don't invert if not tilted
  assign invert = (tally == 0 || net_ones == 0) ? ~q_m[8] : more_tilt; 

  // if not balanced:
    // if not tilted and q_m[8]: no change to net_ones
    // if tilted and q_m[8]: add 1
    // if not tilted and ~q_m[8]: add 1
    // if tilted and ~q_m[8]: no change to net_ones
  // else:
    // just increment by the net difference between ones and zeros
  assign increment = net_ones - (~(net_ones == 0 || tally == 0) & {q_m[8] ^ ~more_tilt});
  
  // subtract if inverting, otherwise add
  assign tally_new = invert ? tally - increment : tally + increment;
  
  always_ff @(posedge clk_in) begin
    if(rst_in) begin
        tally <= 0;
        tmds_out <= 0;
    end else begin
        if (ve_in == 1'b1) begin
            tally <= tally_new;
            // do the inverting
            tmds_out <= {invert, q_m[8], q_m[7:0] ^ {8{invert}}};
        end else begin
            tally <= 0;
            case (control_in)
                2'b00: tmds_out <= 10'b1101010100;
                2'b01: tmds_out <= 10'b0010101011;
                2'b10: tmds_out <= 10'b0101010100;
                2'b11: tmds_out <= 10'b1010101011;
            endcase
        end
    end
  end
 
 
endmodule
 
`default_nettype wire