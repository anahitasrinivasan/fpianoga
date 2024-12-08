`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module color_selector(
  input wire clk_in,
  input wire rst_in,
  input wire [2:0] key_played,
  input wire [2:0] note_duration,
  output logic [23:0] color
);

always_comb begin
    case (key_played)
        3'd0: begin
          case (note_duration)
            3'd0: color = 24'h52_F7_4F;
            3'd1: color = 24'h42_E3_40; // 24'h2F_8F_28;
            3'd2: color = 24'h34_CF_32; // 24'h2F_8F_28;
            3'd3: color = 24'h27_B5_24; // 24'h2F_8F_28; 
            3'd4: color = 24'h1A_9E_18; // 24'h13_38_10;
            3'd5: color = 24'h12_8A_11; // 24'h13_38_10;
            3'd6: color = 24'h09_7A_09; // 24'h13_38_10;
            3'd7: color = 24'h01_70_01; // 24'h00_00_00;
          endcase
        end
        3'd1: begin
          case (note_duration)
            3'd0: color = 24'hF7_E9_4F;
            3'd1: color = 24'hFC_EB_28; // 24'hA3_9A_34;
            3'd2: color = 24'hED_DA_02; // 24'hA3_9A_34;
            3'd3: color = 24'hE3_D3_20; // 24'hA3_9A_34;
            3'd4: color = 24'hC9_BB_18; // 24'h4A_46_16;
            3'd5: color = 24'hB8_AA_0F; // 24'h4A_46_16;
            3'd6: color = 24'hA8_9B_07; // 24'h4A_46_16;
            3'd7: color = 24'h99_8D_05; // 24'h00_00_00;
          endcase
        end
        3'd2: begin
          case (note_duration)
            3'd0: color = 24'h4F_D3_F7;
            3'd1: color = 24'h3E_BB_DE; // 24'h37_8E_A6; 
            3'd2: color = 24'h30_A8_C9; // 24'h37_8E_A6; 
            3'd3: color = 24'h24_96_B5; // 24'h37_8E_A6; 
            3'd4: color = 24'h19_88_A6; // 24'h15_36_40;
            3'd5: color = 24'h10_7E_9C; // 24'h15_36_40;
            3'd6: color = 24'h09_74_91; // 24'h15_36_40;
            3'd7: color = 24'h03_6F_8C; // 24'h00_00_00;
          endcase
        end
        3'd3: begin
          case (note_duration)
            3'd0: color = 24'hB1_4F_F7;
            3'd1: color = 24'hA0_42_E3; // 24'h6C_30_98; 
            3'd2: color = 24'h8B_31_CC; // 24'h6C_30_98;
            3'd3: color = 24'h78_22_B5; // 24'h6C_30_98;
            3'd4: color = 24'h69_17_A3; // 24'h32_17_45;
            3'd5: color = 24'h5B_0F_91; // 24'h32_17_45;
            3'd6: color = 24'h51_08_85; // 24'h32_17_45;
            3'd7: color = 24'h49_01_7D; // 24'h00_00_00;
          endcase
        end
        3'd4: begin
          case (note_duration)
            3'd0: color = 24'hF7_C2_4F;
            3'd1: color = 24'hE3_AE_3D; // 24'h9E_7C_33;
            3'd2: color = 24'hCF_9B_2D; // 24'h9E_7C_33;
            3'd3: color = 24'hBF_8C_21; // 24'h9E_7C_33;
            3'd4: color = 24'hB5_81_14; // 24'h45_36_16;
            3'd5: color = 24'hA8_77_0C; // 24'h45_36_16;
            3'd6: color = 24'h96_69_05; // 24'h45_36_16;
            3'd7: color = 24'h78_53_00; // 24'h00_00_00;
          endcase
        end
        3'd5: begin
          case (note_duration)
            3'd0: color = 24'hF7_4F_4F;
            3'd1: color = 24'hDE_40_40; // 24'h99_31_31;
            3'd2: color = 24'hCF_32_32; // 24'h99_31_31;
            3'd3: color = 24'hBD_24_24; // 24'h99_31_31; 
            3'd4: color = 24'hAB_18_18; // 24'h3B_13_13;
            3'd5: color = 24'h9E_0E_0E; // 24'h3B_13_13;
            3'd6: color = 24'h8F_07_07; // 24'h3B_13_13;
            3'd7: color = 24'h8A_01_01; // 24'h00_00_00;
          endcase
        end
        3'd6: begin
          case (note_duration)
            3'd0: color = 24'h4F_65_F7;
            3'd1: color = 24'h40_54_DB; // 24'h32_40_9C;
            3'd2: color = 24'h32_46_C9; // 24'h32_40_9C;
            3'd3: color = 24'h27_3A_B8; // 24'h32_40_9C; 
            3'd4: color = 24'h1D_2F_A8; // 24'h14_19_3D;
            3'd5: color = 24'h14_25_96; // 24'h14_19_3D;
            3'd6: color = 24'h09_1A_87; // 24'h14_19_3D;
            3'd7: color = 24'h01_12_7A; // 24'h00_00_00;
          endcase
        end
        3'd7: begin
          case (note_duration)
            3'd0: color = 24'h52_F7_4F;
            3'd1: color = 24'h42_E3_40; // 24'h2F_8F_28;
            3'd2: color = 24'h34_CF_32; // 24'h2F_8F_28;
            3'd3: color = 24'h27_B5_24; // 24'h2F_8F_28; 
            3'd4: color = 24'h1A_9E_18; // 24'h13_38_10;
            3'd5: color = 24'h12_8A_11; // 24'h13_38_10;
            3'd6: color = 24'h09_7A_09; // 24'h13_38_10;
            3'd7: color = 24'h01_70_01; // 24'h00_00_00;
          endcase
        end
        default: color = 24'h00_00_00;
    endcase
end
 
endmodule
 
`default_nettype wire