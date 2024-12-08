`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"../../data/X`"
`endif  /* ! SYNTHESIS */

module guided_play(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] keys_in,
  input wire song_select,
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
  output logic [23:0] note_guide_color1,
  output logic [23:0] note_guide_color2,
  output logic [23:0] note_guide_color3,
  output logic [23:0] note_guide_color4,
  output logic [23:0] note_guide_color5,
  output logic [23:0] note_guide_color6,
  output logic [23:0] note_guide_color7,
  output logic [23:0] note_guide_color8,
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

Correct Note Color: h4E_82_5D
Incorrect Note Color: hA6_49_49
*/

logic [3:0] counter;
logic [2:0] key_played;
logic [1:0] song_address;

guided_play_counter note_counter (
  .clk_in(clk_in),
  .rst_in(rst_in),
  .keys_in(keys_in),
  .trigger(trigger),
  .counter(counter),
  .key_played(key_played),
  .song_address(song_address)
);

logic [31:0] song_row_holder [1:0];
logic [31:0] song_row;
logic [31:0] sr_pipeline_1;
logic [31:0] sr_pipeline_2;

xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(4),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(song1.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) song1 (
    .addra(song_address),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(song_row_holder[0])      // RAM output data, width determined from RAM_WIDTH
);

xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(32),                       // Specify RAM data width
    .RAM_DEPTH(4),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(song2.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) song2 (
    .addra(song_address),     // Address bus, width determined from RAM_DEPTH
    .dina(0),       // RAM input data, width determined from RAM_WIDTH
    .clka(clk_in),       // Clock
    .wea(0),         // Write enable
    .ena(1),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(1),   // Output register enable
    .douta(song_row_holder[1])      // RAM output data, width determined from RAM_WIDTH
);

assign song_row = (song_select == 1) ? (song_row_holder[1]) : (song_row_holder[0]);

always_ff @(posedge clk_in) begin
    if(rst_in) begin
        note_y1 <= 10'd500;
        note_y2 <= 10'd500;
        note_y3 <= 10'd500;
        note_y4 <= 10'd500;
        note_y5 <= 10'd500;
        note_y6 <= 10'd500;
        note_y7 <= 10'd500;
        note_y8 <= 10'd500; 
        note_color1 <= 24'h00_00_00;
        note_color2 <= 24'h00_00_00;
        note_color3 <= 24'h00_00_00;
        note_color4 <= 24'h00_00_00;
        note_color5 <= 24'h00_00_00;
        note_color6 <= 24'h00_00_00;
        note_color7 <= 24'h00_00_00;
        note_color8 <= 24'h00_00_00;
        note_guide_color1 <= 24'h00_00_00;
        note_guide_color2 <= 24'h00_00_00;
        note_guide_color3 <= 24'h00_00_00;
        note_guide_color4 <= 24'h00_00_00;
        note_guide_color5 <= 24'h00_00_00;
        note_guide_color6 <= 24'h00_00_00;
        note_guide_color7 <= 24'h00_00_00;
        note_guide_color8 <= 24'h00_00_00;
        cursor_x <= 11'd240;
    end else begin
        sr_pipeline_1 <= song_row;
        sr_pipeline_2 <= sr_pipeline_1;
        case (counter)
            0: begin
                case (sr_pipeline_2[30:28])
                    3'd0: begin note_y1 <= 10'd485; note_guide_color1 <= 24'h52_F7_4F; end
                    3'd1: begin note_y1 <= 10'd460; note_guide_color1 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y1 <= 10'd435; note_guide_color1 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y1 <= 10'd410; note_guide_color1 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y1 <= 10'd385; note_guide_color1 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y1 <= 10'd360; note_guide_color1 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y1 <= 10'd335; note_guide_color1 <= 24'h4F_65_F7; end
                    3'd7: begin note_y1 <= 10'd310; note_guide_color1 <= 24'h52_F7_4F; end
                    default: begin note_y1 <= 10'd500; note_guide_color1 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[26:24])
                    3'd0: begin note_y2 <= 10'd485; note_guide_color2 <= 24'h52_F7_4F; end
                    3'd1: begin note_y2 <= 10'd460; note_guide_color2 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y2 <= 10'd435; note_guide_color2 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y2 <= 10'd410; note_guide_color2 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y2 <= 10'd385; note_guide_color2 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y2 <= 10'd360; note_guide_color2 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y2 <= 10'd335; note_guide_color2 <= 24'h4F_65_F7;  end
                    3'd7: begin note_y2 <= 10'd310; note_guide_color2 <= 24'h52_F7_4F; end
                    default: begin note_y2 <= 10'd500; note_guide_color2 <= 24'h00_00_00;  end
                endcase

                case (sr_pipeline_2[22:20])
                    3'd0: begin note_y3 <= 10'd485; note_guide_color3 <= 24'h52_F7_4F; end
                    3'd1: begin note_y3 <= 10'd460; note_guide_color3 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y3 <= 10'd435; note_guide_color3 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y3 <= 10'd410; note_guide_color3 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y3 <= 10'd385; note_guide_color3 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y3 <= 10'd360; note_guide_color3 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y3 <= 10'd335; note_guide_color3 <= 24'h4F_65_F7; end
                    3'd7: begin note_y3 <= 10'd310; note_guide_color3 <= 24'h52_F7_4F; end
                    default: begin note_y3 <= 10'd500; note_guide_color3 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[18:16])
                    3'd0: begin note_y4 <= 10'd485; note_guide_color4 <= 24'h52_F7_4F; end
                    3'd1: begin note_y4 <= 10'd460; note_guide_color4 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y4 <= 10'd435; note_guide_color4 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y4 <= 10'd410; note_guide_color4 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y4 <= 10'd385; note_guide_color4 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y4 <= 10'd360; note_guide_color4 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y4 <= 10'd335; note_guide_color4 <= 24'h4F_65_F7; end
                    3'd7: begin note_y4 <= 10'd310; note_guide_color4 <= 24'h52_F7_4F; end
                    default: begin note_y4 <= 10'd500; note_guide_color4 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[14:12])
                    3'd0: begin note_y5 <= 10'd485; note_guide_color5 <= 24'h52_F7_4F; end
                    3'd1: begin note_y5 <= 10'd460; note_guide_color5 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y5 <= 10'd435; note_guide_color5 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y5 <= 10'd410; note_guide_color5 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y5 <= 10'd385; note_guide_color5 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y5 <= 10'd360; note_guide_color5 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y5 <= 10'd335; note_guide_color5 <= 24'h4F_65_F7; end
                    3'd7: begin note_y5 <= 10'd310; note_guide_color5 <= 24'h52_F7_4F; end
                    default: begin note_y5 <= 10'd500; note_guide_color5 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[10:8])
                    3'd0: begin note_y6 <= 10'd485; note_guide_color6 <= 24'h52_F7_4F; end
                    3'd1: begin note_y6 <= 10'd460; note_guide_color6 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y6 <= 10'd435; note_guide_color6 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y6 <= 10'd410; note_guide_color6 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y6 <= 10'd385; note_guide_color6 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y6 <= 10'd360; note_guide_color6 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y6 <= 10'd335; note_guide_color6 <= 24'h4F_65_F7; end
                    3'd7: begin note_y6 <= 10'd310; note_guide_color6 <= 24'h52_F7_4F; end
                    default: begin note_y6 <= 10'd500; note_guide_color6 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[6:4])
                    3'd0: begin note_y7 <= 10'd485; note_guide_color7 <= 24'h52_F7_4F; end
                    3'd1: begin note_y7 <= 10'd460; note_guide_color7 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y7 <= 10'd435; note_guide_color7 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y7 <= 10'd410; note_guide_color7 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y7 <= 10'd385; note_guide_color7 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y7 <= 10'd360; note_guide_color7 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y7 <= 10'd335; note_guide_color7 <= 24'h4F_65_F7; end
                    3'd7: begin note_y7 <= 10'd310; note_guide_color7 <= 24'h52_F7_4F; end
                    default: begin note_y7 <= 10'd500; note_guide_color7 <= 24'h00_00_00; end
                endcase

                case (sr_pipeline_2[2:0])
                    3'd0: begin note_y8 <= 10'd485; note_guide_color8 <= 24'h52_F7_4F; end
                    3'd1: begin note_y8 <= 10'd460; note_guide_color8 <= 24'hF7_E9_4F; end
                    3'd2: begin note_y8 <= 10'd435; note_guide_color8 <= 24'h4F_D3_F7; end
                    3'd3: begin note_y8 <= 10'd410; note_guide_color8 <= 24'hB1_4F_F7; end
                    3'd4: begin note_y8 <= 10'd385; note_guide_color8 <= 24'hF7_C2_4F; end
                    3'd5: begin note_y8 <= 10'd360; note_guide_color8 <= 24'hF7_4F_4F; end
                    3'd6: begin note_y8 <= 10'd335; note_guide_color8 <= 24'h4F_65_F7; end
                    3'd7: begin note_y8 <= 10'd310; note_guide_color8 <= 24'h52_F7_4F; end
                    default: begin note_y8 <= 10'd500; note_guide_color8 <= 24'h00_00_00; end
                endcase

                note_color1 <= 24'h00_00_00;
                note_color2 <= 24'h00_00_00;
                note_color3 <= 24'h00_00_00;
                note_color4 <= 24'h00_00_00;
                note_color5 <= 24'h00_00_00;
                note_color6 <= 24'h00_00_00;
                note_color7 <= 24'h00_00_00;
                note_color8 <= 24'h00_00_00;

                cursor_x <= 11'd240;
            end
            1: begin
                if(key_played == sr_pipeline_2[30:28]) begin
                    note_color1 <= 24'h4E_82_5D;
                end else begin
                    note_color1 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd362;
            end 
            2: begin
                if(key_played == sr_pipeline_2[26:24]) begin
                    note_color2 <= 24'h4E_82_5D;
                end else begin
                    note_color2 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd487;
            end
            3: begin
                if(key_played == sr_pipeline_2[22:20]) begin
                    note_color3 <= 24'h4E_82_5D;
                end else begin
                    note_color3 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd612;
            end
            4: begin
                if(key_played == sr_pipeline_2[18:16]) begin
                    note_color4 <= 24'h4E_82_5D;
                end else begin
                    note_color4 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd737;
            end
            5: begin
                if(key_played == sr_pipeline_2[14:12]) begin
                    note_color5 <= 24'h4E_82_5D;
                end else begin
                    note_color5 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd862;
            end
            6: begin
                if(key_played == sr_pipeline_2[10:8]) begin
                    note_color6 <= 24'h4E_82_5D;
                end else begin
                    note_color6 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd987;
            end
            7: begin
                if(key_played == sr_pipeline_2[6:4]) begin
                    note_color7 <= 24'h4E_82_5D;
                end else begin
                    note_color7 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd1112;
            end
            8: begin
                if(key_played == sr_pipeline_2[2:0]) begin
                    note_color8 <= 24'h4E_82_5D;
                end else begin
                    note_color8 <= 24'hA6_49_49;
                end
                cursor_x <= 11'd1217;
            end
        endcase
    end
end
 
endmodule
 
`default_nettype wire