`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module free_play(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] keys_in,
  input wire trigger,
  output logic [9:0] note_y1,
  output logic [9:0] note_y2,
  output logic [9:0] note_y3,
  output logic [9:0] note_y4,
  output logic [9:0] note_y5,
  output logic [9:0] note_y6,
  output logic [9:0] note_y7,
  output logic [9:0] note_y8,
  output logic [23:0] note_color1,
  output logic [23:0] note_color2,
  output logic [23:0] note_color3,
  output logic [23:0] note_color4,
  output logic [23:0] note_color5,
  output logic [23:0] note_color6,
  output logic [23:0] note_color7,
  output logic [23:0] note_color8,
  output logic [10:0] cursor_x
);

/*
Note Locations:

C: 485
D: 460
E: 435
F: 410
G: 385
A: 360
B: 335
C: 310
D: 285
E: 260

*/

logic [3:0] counter;
logic [2:0] key_played;
logic [2:0] note_duration;
logic [23:0] color;
logic [9:0] y;

key_press_counter note_counter (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .keys_in(keys_in),
  .trigger(trigger),
  .counter(counter),
  .key_played(key_played),
  .note_duration(note_duration)
);

color_selector note_color (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .key_played(key_played),
  .note_duration(note_duration),
  .color(color)
);

location_selector note_location (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .key_played(key_played),
  .y(y)
);

always_ff @(posedge clk_in) begin
    if(rst_in) begin
        note_y1 <= 10'd50;
        note_y2 <= 10'd50;
        note_y3 <= 10'd50;
        note_y4 <= 10'd50;
        note_y5 <= 10'd50;
        note_y6 <= 10'd50;
        note_y7 <= 10'd50;
        note_y8 <= 10'd50; 
        note_color1 <= 24'hFF_FF_FF;
        note_color2 <= 24'hFF_FF_FF;
        note_color3 <= 24'hFF_FF_FF;
        note_color4 <= 24'hFF_FF_FF;
        note_color5 <= 24'hFF_FF_FF;
        note_color6 <= 24'hFF_FF_FF;
        note_color7 <= 24'hFF_FF_FF;
        note_color8 <= 24'hFF_FF_FF;
        cursor_x <= 11'd240;
    end else begin
        case (counter)
            1: begin
                note_y1 <= y;
                note_y2 <= 10'd50;
                note_y3 <= 10'd50;
                note_y4 <= 10'd50;
                note_y5 <= 10'd50;
                note_y6 <= 10'd50;
                note_y7 <= 10'd50;
                note_y8 <= 10'd50; 
                note_color1 <= color;
                note_color2 <= 24'hFF_FF_FF;
                note_color3 <= 24'hFF_FF_FF;
                note_color4 <= 24'hFF_FF_FF;
                note_color5 <= 24'hFF_FF_FF;
                note_color6 <= 24'hFF_FF_FF;
                note_color7 <= 24'hFF_FF_FF;
                note_color8 <= 24'hFF_FF_FF;
                cursor_x <= 11'd362;
            end 
            2: begin
                note_y2 <= y;
                note_color2 <= color;
                cursor_x <= 11'd487;
            end
            3: begin
                note_y3 <= y;
                note_color3 <= color;
                cursor_x <= 11'd612;
            end
            4: begin
                note_y4 <= y;
                note_color4 <= color;
                cursor_x <= 11'd737;
            end
            5: begin
                note_y5 <= y;
                note_color5 <= color;
                cursor_x <= 11'd862;
            end
            6: begin
                note_y6 <= y;
                note_color6 <= color;
                cursor_x <= 11'd987;
            end
            7: begin
                note_y7 <= y;
                note_color7 <= color;
                cursor_x <= 11'd1112;
            end
            8: begin
                note_y8 <= y;
                note_color8 <= color;
                cursor_x <= 11'd1217;
            end
        endcase
    end
end
 
endmodule
 
`default_nettype wire