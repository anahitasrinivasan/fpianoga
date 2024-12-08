`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
  input wire clk_100mhz_raw, //crystal reference clock
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [2:0] hdmi_tx_p, //hdmi output signals (positives) (blue, green, red)
  output logic [2:0] hdmi_tx_n, //hdmi output signals (negatives) (blue, green, red)
  output logic spkl, spkr, // left and right channels of line out port
  output logic hdmi_clk_p, hdmi_clk_n //differential hdmi clock
  );

  logic clk_100mhz; 
  BUFG clock (
    .I(clk_100mhz_raw),
    .O(clk_100mhz)
  );

  //shut up those rgb LEDs (active high):
  assign rgb1 = 0;
  assign rgb0 = 0;

  //have btn[0] control system reset
  logic sys_rst;
  assign sys_rst = btn[0]; //reset is btn[0]
 
  logic clk_pixel, clk_5x; //clock lines
  logic locked; //locked signal (we'll leave unused but still hook it up)
 
  //clock manager...creates 74.25 Hz and 5 times 74.25 MHz for pixel and TMDS
  hdmi_clk_wiz_720p mhdmicw (
      .reset(0),
      .locked(locked),
      .clk_ref(clk_100mhz),
      .clk_pixel(clk_pixel),
      .clk_tmds(clk_5x));


  // ----------AUDIO----------

  //set this parameter to the number of clock cycles between each cycle of an 8kHz trigger
localparam CYCLES_PER_TRIGGER = 12500; 
  logic [31:0]        trigger_count;
  logic KHz_trigger;
  assign KHz_trigger = (trigger_count == CYCLES_PER_TRIGGER-1);



  counter counter_8khz_trigger
      (.clk_in(clk_100mhz),
      .rst_in(sys_rst),
      .period_in(CYCLES_PER_TRIGGER),
      .count_out(trigger_count));   

    logic [7:0] audio_sample_buff;
    logic valid_amp_out;

    // logic [31:0] phase_offset_tracker_in;
    // logic [31:0] phase_sine_out;
    // logic [31:0] phase_incrementer;
    // assign phase_incrementer = 32'b0000_0010_0000_0000_0000_0000_0000_0000;


  // sine_generator_v2 sine_gen_2(
  //   .clk_in(clk_100mhz),
  //   .rst_in(sys_rst),
  //   .phase_offset_in(phase_offset_tracker_in),
  //   .valid_info_in(1'b1),
  //   .phase_increment(phase_incrementer),
  //   .amp_out(audio_sample_buff),
  //   .full_phase_next_out(phase_sine_out)
  // );

  //todo: remember that the magnitudes coming out of the coeff info generator are 32 bits, but input to the sine wave sum is 10 bits (take bottom 10 bits)

  logic [4:0][31:0] top_5_coeffs;
  always_comb begin
    top_5_coeffs[0] = 32'b1111111100000001_0000000001001011;
    top_5_coeffs[1] = 32'b1111111110111101_0000000011100111;
    top_5_coeffs[2] = 32'b0000000000001101_1111111111110100;
    top_5_coeffs[3] = 32'b0000000000000010_1111111111111101;
    top_5_coeffs[4] = 32'b0000000000001110_1111111111111001;
  end

  coeff_info_gen_mags mag_gen (
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    .valid_data_in(1'b1),
    .top_n_coeffs(top_5_coeffs),
    .coeff_mags_out(mags_out_coeffs),
    .valid_data_out(coeff_information_ready)
  );

  logic coeff_information_ready;
  logic [NUM_HARMONICS-1:0][31:0] mags_out_coeffs;

  localparam NUM_NOTES = 8;
  localparam NUM_HARMONICS = 5;
  logic [NUM_NOTES-1:0] notes_playing_switches;
  assign notes_playing_switches = {sw[8], sw[9], sw[10], sw[11], sw[12], sw[13], sw[14], sw[15]};

  logic [NUM_HARMONICS-1:0][31:0] phases_init_in;
  logic [NUM_HARMONICS-1:0][9:0] magnitudes_init_in;

  always_comb begin
    phases_init_in[0] = (sw[1])? {6'd29, 26'b0}: 0;
    phases_init_in[1] = (sw[1])? {6'd19, 26'b0}: 0;
    phases_init_in[2] = (sw[1])? {6'd56, 26'b0}: 0;
    phases_init_in[3] = (sw[1])? {6'd55, 26'b0}: 0; //-9pi/32 rads
    phases_init_in[4] = (sw[1])? {6'd59, 26'b0}: 0;
    //phases_init_in[0] = 0;
    //phases_init_in[1] = 0;
    // magnitudes_init_in[0] = 10'b01_0000_1011;
    // magnitudes_init_in[1] = 10'b00_1111_0001;
    // magnitudes_init_in[2] = 10'b00_0001_0010;
    // magnitudes_init_in[3] = 10'b00_0000_0100;
    // magnitudes_init_in[4] = 10'b00_0001_0000;
    
    for (integer i=0; i<NUM_HARMONICS; i++)begin
      magnitudes_init_in[i] = mags_out_coeffs[i][9:0];
    end

  end

  sine_wave_sum_v2 wav_sum_out (
    .clk_in(clk_100mhz),
    .rst_in(sys_rst),
    .notes_playing(notes_playing_switches),
    .coeff_info_ready(coeff_information_ready),
    .freq_info_ready(1'b1),
    .coeff_phases(phases_init_in),
    .coeff_magnitudes(magnitudes_init_in),
    .step_in(KHz_trigger),
    .sum_valid_out(valid_amp_out),
    .sum_out(audio_sample_buff)
  );


  logic [7:0] audio_sample;

  always_ff @(posedge clk_100mhz) begin 
    if (KHz_trigger)begin
      audio_sample <= {~audio_sample_buff[7],audio_sample_buff[6:0]};
    end
  end

  // Line out Audio
  logic [7:0] line_out_audio;

  assign line_out_audio = audio_sample;

  logic spk_out;
  // instantiate a pwm module to drive spk_out
  pwm pwm_output(
          .clk_in(clk_100mhz),
          .rst_in(sys_rst),
          .dc_in(line_out_audio),
          .sig_out(spk_out)

  );

  // set both output channels equal to the same PWM signal!
  assign spkl = spk_out;
  assign spkr = spk_out;

  assign led = {10'b0, valid_amp_out, audio_sample_buff}; // for debugging purposes


  // ----------VIDEO----------
 
  logic [10:0] hcount; //hcount of system!
  logic [9:0] vcount; //vcount of system!
  logic hor_sync; //horizontal sync signal
  logic vert_sync; //vertical sync signal
  logic active_draw; //ative draw! 1 when in drawing region.0 in blanking/sync
  logic new_frame; //one cycle active indicator of new frame of info!
  logic [5:0] frame_count; //0 to 59 then rollover frame counter
 
  //written by you previously! (make sure you include in your hdl)
  //default instantiation so making signals for 720p
  video_sig_gen mvg(
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_out(hcount),
      .vcount_out(vcount),
      .vs_out(vert_sync),
      .hs_out(hor_sync),
      .ad_out(active_draw),
      .nf_out(new_frame),
      .fc_out(frame_count));
 
  logic [7:0] staff_red, staff_green, staff_blue;
  logic [7:0] treble_red, treble_green, treble_blue;
  logic [7:0] inst_red, inst_green, inst_blue;
  logic [7:0] metronome_red, metronome_green, metronome_blue;
  logic [7:0] cursor_red, cursor_green, cursor_blue;
  logic metronome_color;
  logic [7:0] note_red [7:0];
  logic [7:0] note_green [7:0];
  logic [7:0] note_blue [7:0];
  logic [7:0] note_guide_red [7:0];
  logic [7:0] note_guide_green [7:0];
  logic [7:0] note_guide_blue [7:0];
  logic [7:0] red, green, blue;
  
  logic [9:0] note_y1 [1:0];
  logic [9:0] note_y2 [1:0];
  logic [9:0] note_y3 [1:0];
  logic [9:0] note_y4 [1:0];
  logic [9:0] note_y5 [1:0];
  logic [9:0] note_y6 [1:0];
  logic [9:0] note_y7 [1:0];
  logic [9:0] note_y8 [1:0];

  logic [23:0] note_color1 [1:0];
  logic [23:0] note_color2 [1:0];
  logic [23:0] note_color3 [1:0];
  logic [23:0] note_color4 [1:0];
  logic [23:0] note_color5 [1:0];
  logic [23:0] note_color6 [1:0];
  logic [23:0] note_color7 [1:0];
  logic [23:0] note_color8 [1:0];

  logic [23:0] note_guide_color1;
  logic [23:0] note_guide_color2;
  logic [23:0] note_guide_color3;
  logic [23:0] note_guide_color4;
  logic [23:0] note_guide_color5;
  logic [23:0] note_guide_color6;
  logic [23:0] note_guide_color7;
  logic [23:0] note_guide_color8;

  logic [10:0] cursor_x [1:0];
  
  staff_lines lines (
      .hcount_in(hcount),
      .vcount_in(vcount),
      .red_out(staff_red),
      .green_out(staff_green),
      .blue_out(staff_blue));

  treble_clef #(
      .WIDTH(200),
      .HEIGHT(360)) treble (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(0),
      .y_in(180),
      .red_out(treble_red),
      .green_out(treble_green),
      .blue_out(treble_blue));
  
  instructions #(
      .WIDTH(300),
      .HEIGHT(110)) instructions (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(920),
      .y_in(10),
      .red_out(inst_red),
      .green_out(inst_green),
      .blue_out(inst_blue));

  metronome metronome_counter (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .trigger(new_frame),
    .color(metronome_color)
  );

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) metronome (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(30),
    .y_in(30),
    .color_in(((metronome_color) ? 24'h00_00_00 : 24'hFF_FF_FF)), 
    .red_out(metronome_red),
    .green_out(metronome_green),
    .blue_out(metronome_blue));


  free_play free_play (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .keys_in({sw[8], sw[9], sw[10], sw[11], sw[12], sw[13], sw[14], sw[15]}),
    .trigger(new_frame),
    .note_y1(note_y1[0]),
    .note_y2(note_y2[0]),
    .note_y3(note_y3[0]),
    .note_y4(note_y4[0]),
    .note_y5(note_y5[0]),
    .note_y6(note_y6[0]),
    .note_y7(note_y7[0]),
    .note_y8(note_y8[0]),
    .note_color1(note_color1[0]),
    .note_color2(note_color2[0]),
    .note_color3(note_color3[0]),
    .note_color4(note_color4[0]),
    .note_color5(note_color5[0]),
    .note_color6(note_color6[0]),
    .note_color7(note_color7[0]),
    .note_color8(note_color8[0]),
    .cursor_x(cursor_x[0]));

  guided_play guided_play (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .keys_in({sw[8], sw[9], sw[10], sw[11], sw[12], sw[13], sw[14], sw[15]}),
    .song_select(sw[1]),
    .trigger(new_frame),
    .note_y1(note_y1[1]),
    .note_y2(note_y2[1]),
    .note_y3(note_y3[1]),
    .note_y4(note_y4[1]),
    .note_y5(note_y5[1]),
    .note_y6(note_y6[1]),
    .note_y7(note_y7[1]),
    .note_y8(note_y8[1]), 
    .note_color1(note_color1[1]),
    .note_color2(note_color2[1]),
    .note_color3(note_color3[1]),
    .note_color4(note_color4[1]),
    .note_color5(note_color5[1]),
    .note_color6(note_color6[1]),
    .note_color7(note_color7[1]),
    .note_color8(note_color8[1]),
    .note_guide_color1(note_guide_color1),
    .note_guide_color2(note_guide_color2),
    .note_guide_color3(note_guide_color3),
    .note_guide_color4(note_guide_color4),
    .note_guide_color5(note_guide_color5),
    .note_guide_color6(note_guide_color6),
    .note_guide_color7(note_guide_color7),
    .note_guide_color8(note_guide_color8),
    .cursor_x(cursor_x[1]));

  note_sprite #(
    .WIDTH(10), 
    .HEIGHT(360)) cursor (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(((sw[0]) ? cursor_x[1] : cursor_x[0])),
    .y_in(180),
    .color_in(((metronome_color) ? 24'h00_00_00 : 24'hFF_FF_FF)), 
    .red_out(cursor_red),
    .green_out(cursor_green),
    .blue_out(cursor_blue));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_1 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(280),
    .y_in(((sw[0]) ? note_y1[1] : note_y1[0])),
    .color_in(((sw[0]) ? note_color1[1] : note_color1[0])), 
    .red_out(note_red[0]),
    .green_out(note_green[0]),
    .blue_out(note_blue[0]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_2 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(405),
    .y_in(((sw[0]) ? note_y2[1] : note_y2[0])),
    .color_in(((sw[0]) ? note_color2[1] : note_color2[0])),
    .red_out(note_red[1]),
    .green_out(note_green[1]),
    .blue_out(note_blue[1]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_3 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(530),
    .y_in(((sw[0]) ? note_y3[1] : note_y3[0])),
    .color_in(((sw[0]) ? note_color3[1] : note_color3[0])),
    .red_out(note_red[2]),
    .green_out(note_green[2]),
    .blue_out(note_blue[2]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_4 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(655),
    .y_in(((sw[0]) ? note_y4[1] : note_y4[0])),
    .color_in(((sw[0]) ? note_color4[1] : note_color4[0])),
    .red_out(note_red[3]),
    .green_out(note_green[3]),
    .blue_out(note_blue[3]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_5 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(780),
    .y_in(((sw[0]) ? note_y5[1] : note_y5[0])),
    .color_in(((sw[0]) ? note_color5[1] : note_color5[0])),
    .red_out(note_red[4]),
    .green_out(note_green[4]),
    .blue_out(note_blue[4]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_6 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(905),
    .y_in(((sw[0]) ? note_y6[1] : note_y6[0])),
    .color_in(((sw[0]) ? note_color6[1] : note_color6[0])),
    .red_out(note_red[5]),
    .green_out(note_green[5]),
    .blue_out(note_blue[5]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_7 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(1030),
    .y_in(((sw[0]) ? note_y7[1] : note_y7[0])),
    .color_in(((sw[0]) ? note_color7[1] : note_color7[0])),
    .red_out(note_red[6]),
    .green_out(note_green[6]),
    .blue_out(note_blue[6]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_8 (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(1155),
    .y_in(((sw[0]) ? note_y8[1] : note_y8[0])),
    .color_in(((sw[0]) ? note_color8[1] : note_color8[0])),
    .red_out(note_red[7]),
    .green_out(note_green[7]),
    .blue_out(note_blue[7]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_1_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(280),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color1 : 24'hFF_FF_FF)), 
    .red_out(note_guide_red[0]),
    .green_out(note_guide_green[0]),
    .blue_out(note_guide_blue[0]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_2_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(405),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color2 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[1]),
    .green_out(note_guide_green[1]),
    .blue_out(note_guide_blue[1]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_3_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(530),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color3 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[2]),
    .green_out(note_guide_green[2]),
    .blue_out(note_guide_blue[2]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_4_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(655),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color4 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[3]),
    .green_out(note_guide_green[3]),
    .blue_out(note_guide_blue[3]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_5_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(780),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color5 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[4]),
    .green_out(note_guide_green[4]),
    .blue_out(note_guide_blue[4]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_6_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(905),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color6 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[5]),
    .green_out(note_guide_green[5]),
    .blue_out(note_guide_blue[5]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_7_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(1030),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color7 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[6]),
    .green_out(note_guide_green[6]),
    .blue_out(note_guide_blue[6]));

  note_sprite #(
    .WIDTH(50), 
    .HEIGHT(50)) note_8_guide (
    .hcount_in(hcount),
    .vcount_in(vcount),
    .x_in(1155),
    .y_in(650),
    .color_in(((sw[0]) ? note_guide_color8 : 24'hFF_FF_FF)),
    .red_out(note_guide_red[7]),
    .green_out(note_guide_green[7]),
    .blue_out(note_guide_blue[7]));

  logic hor_sync_pipe;
  logic vert_sync_pipe;
  logic active_draw_pipe;

  always_ff @(posedge clk_pixel) begin
    if(sys_rst) begin
      red <= 8'hFF;
      green <= 8'hFF;
      blue <= 8'hFF;
      hor_sync_pipe <= 0;
      vert_sync_pipe <= 0;
      active_draw_pipe <= 0;
    end else begin
      hor_sync_pipe <= hor_sync;
      vert_sync_pipe <= vert_sync;
      active_draw_pipe <= active_draw;

      if (treble_red == 0) begin
        red <= 0;
      end else if (inst_red == 0) begin
        red <= 0;
      end else if (metronome_red == 0) begin
        red <= 0;
      end else if (cursor_red == 0) begin
        red <= 0;
      end else if (staff_red == 0) begin
        if ((note_red[0] & note_red[1] & note_red[2] & note_red[3] & note_red[4] & note_red[5] & note_red[6] & note_red[7] &
             note_guide_red[0] & note_guide_red[1] & note_guide_red[2] & note_guide_red[3] & note_guide_red[4] & note_guide_red[5] & note_guide_red[6] & note_guide_red[7]) != 8'hFF) begin
          red <= (note_red[0] & note_red[1] & note_red[2] & note_red[3] & note_red[4] & note_red[5] & note_red[6] & note_red[7] & note_guide_red[0] & note_guide_red[1] & note_guide_red[2] & note_guide_red[3] & note_guide_red[4] & note_guide_red[5] & note_guide_red[6] & note_guide_red[7]);
        end else begin
          red <= 0;
        end
      end else if ((note_red[0] & note_red[1] & note_red[2] & note_red[3] & note_red[4] & note_red[5] & note_red[6] & note_red[7] &
                    note_guide_red[0] & note_guide_red[1] & note_guide_red[2] & note_guide_red[3] & note_guide_red[4] & note_guide_red[5] & note_guide_red[6] & note_guide_red[7]) != 8'hFF) begin
          red <= (note_red[0] & note_red[1] & note_red[2] & note_red[3] & note_red[4] & note_red[5] & note_red[6] & note_red[7] & note_guide_red[0] & note_guide_red[1] & note_guide_red[2] & note_guide_red[3] & note_guide_red[4] & note_guide_red[5] & note_guide_red[6] & note_guide_red[7]);
      end else begin
        red <= 8'hFF;
      end

      if (treble_green == 0) begin
        green <= 0;
      end else if (inst_green == 0) begin
        green <= 0;
      end else if (metronome_green == 0) begin
        green <= 0;
      end else if (cursor_green == 0) begin
        green <= 0;
      end else if (staff_green == 0) begin
        if ((note_green[0] & note_green[1] & note_green[2] & note_green[3] & note_green[4] & note_green[5] & note_green[6] & note_green[7] & 
             note_guide_green[0] & note_guide_green[1] & note_guide_green[2] & note_guide_green[3] & note_guide_green[4] & note_guide_green[5] & note_guide_green[6] & note_guide_green[7]) != 8'hFF) begin
          green <= (note_green[0] & note_green[1] & note_green[2] & note_green[3] & note_green[4] & note_green[5] & note_green[6] & note_green[7] & note_guide_green[0] & note_guide_green[1] & note_guide_green[2] & note_guide_green[3] & note_guide_green[4] & note_guide_green[5] & note_guide_green[6] & note_guide_green[7]);
        end else begin
          green <= 0;
        end
      end else if ((note_green[0] & note_green[1] & note_green[2] & note_green[3] & note_green[4] & note_green[5] & note_green[6] & note_green[7] & 
                    note_guide_green[0] & note_guide_green[1] & note_guide_green[2] & note_guide_green[3] & note_guide_green[4] & note_guide_green[5] & note_guide_green[6] & note_guide_green[7]) != 8'hFF) begin
          green <= (note_green[0] & note_green[1] & note_green[2] & note_green[3] & note_green[4] & note_green[5] & note_green[6] & note_green[7] & note_guide_green[0] & note_guide_green[1] & note_guide_green[2] & note_guide_green[3] & note_guide_green[4] & note_guide_green[5] & note_guide_green[6] & note_guide_green[7]);
      end else begin
        green <= 8'hFF;
      end

      if (treble_blue == 0) begin
        blue <= 0;
      end else if (inst_blue == 0) begin
        blue <= 0;
      end else if (metronome_blue == 0) begin
        blue <= 0;
      end else if (cursor_blue == 0) begin
        blue <= 0;
      end else if (staff_blue == 0) begin
        if ((note_blue[0] & note_blue[1] & note_blue[2] & note_blue[3] & note_blue[4] & note_blue[5] & note_blue[6] & note_blue[7] & 
             note_guide_blue[0] & note_guide_blue[1] & note_guide_blue[2] & note_guide_blue[3] & note_guide_blue[4] & note_guide_blue[5] & note_guide_blue[6] & note_guide_blue[7]) != 8'hFF) begin
          blue <= (note_blue[0] & note_blue[1] & note_blue[2] & note_blue[3] & note_blue[4] & note_blue[5] & note_blue[6] & note_blue[7] & note_guide_blue[0] & note_guide_blue[1] & note_guide_blue[2] & note_guide_blue[3] & note_guide_blue[4] & note_guide_blue[5] & note_guide_blue[6] & note_guide_blue[7]);
        end else begin
          blue <= 0;
        end
      end else if ((note_blue[0] & note_blue[1] & note_blue[2] & note_blue[3] & note_blue[4] & note_blue[5] & note_blue[6] & note_blue[7] & 
             note_guide_blue[0] & note_guide_blue[1] & note_guide_blue[2] & note_guide_blue[3] & note_guide_blue[4] & note_guide_blue[5] & note_guide_blue[6] & note_guide_blue[7]) != 8'hFF) begin
          blue <= (note_blue[0] & note_blue[1] & note_blue[2] & note_blue[3] & note_blue[4] & note_blue[5] & note_blue[6] & note_blue[7] & note_guide_blue[0] & note_guide_blue[1] & note_guide_blue[2] & note_guide_blue[3] & note_guide_blue[4] & note_guide_blue[5] & note_guide_blue[6] & note_guide_blue[7]);
      end else begin
        blue <= 8'hFF;
      end
    end
  end

  logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder!
  logic tmds_signal [2:0]; //output of each TMDS serializer!
 
  //three tmds_encoders (blue, green, red)
  //green should have no control signal like red
  //the blue channel DOES carry the two sync signals:
  //  * control_in[0] = horizontal sync signal
  //  * control_in[1] = vertical sync signal
 
  tmds_encoder tmds_red(
      .clk_in(clk_pixel),
      .rst_in(sys_rst),
      .data_in(red),
      .control_in(2'b0),
      .ve_in(active_draw_pipe),
      .tmds_out(tmds_10b[2]));

  tmds_encoder tmds_green(
      .clk_in(clk_pixel),
      .rst_in(sys_rst),
      .data_in(green),
      .control_in(2'b0),
      .ve_in(active_draw_pipe),
      .tmds_out(tmds_10b[1]));
 
  tmds_encoder tmds_blue(
      .clk_in(clk_pixel),
      .rst_in(sys_rst),
      .data_in(blue),
      .control_in({vert_sync_pipe, hor_sync_pipe}),
      .ve_in(active_draw_pipe),
      .tmds_out(tmds_10b[0]));

  //three tmds_serializers (blue, green, red):
  tmds_serializer red_ser(
      .clk_pixel_in(clk_pixel),
      .clk_5x_in(clk_5x),
      .rst_in(sys_rst),
      .tmds_in(tmds_10b[2]),
      .tmds_out(tmds_signal[2]));
  
  tmds_serializer green_ser(
      .clk_pixel_in(clk_pixel),
      .clk_5x_in(clk_5x),
      .rst_in(sys_rst),
      .tmds_in(tmds_10b[1]),
      .tmds_out(tmds_signal[1]));
  
  tmds_serializer blue_ser(
      .clk_pixel_in(clk_pixel),
      .clk_5x_in(clk_5x),
      .rst_in(sys_rst),
      .tmds_in(tmds_10b[0]),
      .tmds_out(tmds_signal[0]));
 
  //output buffers generating differential signals:
  //three for the r,g,b signals and one that is at the pixel clock rate
  //the HDMI receivers use recover logic coupled with the control signals asserted
  //during blanking and sync periods to synchronize their faster bit clocks off
  //of the slower pixel clock (so they can recover a clock of about 742.5 MHz from
  //the slower 74.25 MHz clock)
  OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
  OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
  OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
  OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));
 
endmodule // top_level
`default_nettype wire