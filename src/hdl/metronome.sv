`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module metronome(
  input wire clk_in,
  input wire rst_in,
  input wire trigger,
  output logic color
);

logic [4:0] counter;

always_ff @(posedge clk_in) begin
    if(rst_in) begin
        color <= 0;
        counter <= 0;
    end else begin
        if(trigger) begin
            if (counter == 5'd29) begin
                counter <= 0;
                color <= ((color == 0) ? 1 : 0);
            end else begin
                counter <= counter + 1;
            end
        end
    end
end
 
endmodule
 
`default_nettype wire