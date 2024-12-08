`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module guided_play_counter(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] keys_in,
  input wire trigger,
  output logic [3:0] counter,
  output logic [2:0] key_played, 
  output logic [1:0] song_address
);

logic [7:0] keys_in_prev;

always_ff @(posedge clk_in) begin
    if(rst_in) begin
        counter <= 0;
        keys_in_prev <= 0;
        key_played <= 0;
        song_address <= 0;
    end else begin
        if(trigger) begin
            if(keys_in[0] == 1 && keys_in_prev[0] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd0;
            end else if (keys_in[1] == 1 && keys_in_prev[1] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd1;
            end else if (keys_in[2] == 1 && keys_in_prev[2] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd2;
            end else if (keys_in[3] == 1 && keys_in_prev[3] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd3;
            end else if (keys_in[4] == 1 && keys_in_prev[4] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd4;
            end else if (keys_in[5] == 1 && keys_in_prev[5] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd5;
            end else if (keys_in[6] == 1 && keys_in_prev[6] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd6;
            end else if (keys_in[7] == 1 && keys_in_prev[7] == 0) begin
                if (counter == 4'd8) begin
                    counter <= 0;
                    song_address <= ((song_address == 2'd3) ? 0 : (song_address + 1));
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd7;
            end else begin
                counter <= counter;
                key_played <= key_played;
            end
            keys_in_prev <= keys_in;
        end
    end
end
 
endmodule
 
`default_nettype wire