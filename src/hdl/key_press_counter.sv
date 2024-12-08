`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module key_press_counter(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] keys_in,
  input wire trigger,
  output logic [3:0] counter,
  output logic [2:0] key_played,
  output logic [2:0] note_duration
);

logic [7:0] keys_in_prev;
logic [5:0] duration_counter;

always_ff @(posedge clk_in) begin
    if(rst_in) begin
        counter <= 0;
        keys_in_prev <= 0;
        key_played <= 0;
        duration_counter <= 0;
        note_duration <= 0;
    end else begin
        if(trigger) begin
            if(keys_in[0] == 1 && keys_in_prev[0] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd0;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[0] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[1] == 1 && keys_in_prev[1] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd1;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[1] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[2] == 1 && keys_in_prev[2] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd2;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[2] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[3] == 1 && keys_in_prev[3] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd3;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[3] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[4] == 1 && keys_in_prev[4] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd4;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[4] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[5] == 1 && keys_in_prev[5] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd5;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[5] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[6] == 1 && keys_in_prev[6] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd6;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[6] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
            end else if (keys_in[7] == 1 && keys_in_prev[7] == 0) begin // key press initiated
                if (counter == 4'd8) begin
                    counter <= 1;
                end else begin
                    counter <= counter + 1;
                end
                key_played <= 3'd7;
                duration_counter <= 0;
                note_duration <= 0;
            end else if (keys_in[7] == 1) begin // key press (already initiated) continuing
                if(duration_counter == 6'd59) begin
                    duration_counter <= 0;
                    note_duration <= ((note_duration < 3'd7) ? note_duration + 1 : 3'd7);
                end else begin
                    duration_counter <= duration_counter + 1;
                end
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