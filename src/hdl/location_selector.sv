`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module location_selector(
  input wire clk_in,
  input wire rst_in,
  input wire [2:0] key_played,
  output logic [23:0] y
);

always_comb begin
    case (key_played)
        3'd0: y = 10'd485;
        3'd1: y = 10'd460;
        3'd2: y = 10'd435;
        3'd3: y = 10'd410;
        3'd4: y = 10'd385;
        3'd5: y = 10'd360;
        3'd6: y = 10'd335;
        3'd7: y = 10'd310;
        default: y = 10'd500;
    endcase
end
 
endmodule
 
`default_nettype wire