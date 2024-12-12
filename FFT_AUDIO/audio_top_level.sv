`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module audio_top_level
  (
   input wire          clk_100mhz, //100 MHz onboard clock
   input wire [15:0]   sw, //all 16 input slide switches
   input wire [3:0]    btn, //all four momentary button switches
   output logic [15:0] led, //16 green output LEDs (located right above switches)
   output logic [2:0]  rgb0, //RGB channels of RGB LED0
   output logic [2:0]  rgb1, //RGB channels of RGB LED1
   output logic        spkl, spkr // left and right channels of line out port
   );

   //shut up those rgb LEDs for now (active high):
   assign rgb1 = 0; //set to 0.
   assign rgb0 = 0; //set to 0.


logic               sys_rst;
assign sys_rst = btn[0];

logic clk_pixel, clk_5x; //clock lines
logic locked; //locked signal (we'll leave unused but still hook it up)
 
  //clock manager...creates 74.25 Hz and 5 times 74.25 MHz for pixel and TMDS
  hdmi_clk_wiz_720p mhdmicw (
      .reset(0),
      .locked(locked),
      .clk_ref(clk_100mhz),
      .clk_pixel(clk_pixel),
      .clk_tmds(clk_5x));


//set this parameter to the number of clock cycles between each cycle of an 8kHz trigger
localparam CYCLES_PER_TRIGGER = 9281; 
  logic [31:0]        trigger_count;
  logic KHz_trigger;
  assign KHz_trigger = (trigger_count == CYCLES_PER_TRIGGER-1);



  counter counter_8khz_trigger
      (.clk_in(clk_pixel),
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

  fft_compute coeff_compute(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_valid_out(all_coeffs_computed),
    .top_5_harmonic_coeffs(top_5_coeffs)
  );

  logic all_coeffs_computed; //todo: replace the valid bit for the coeff_info_gen_mags with this bit
  
  logic [4:0][31:0] top_5_coeffs;
  // always_comb begin
  //   top_5_coeffs[0] = 32'b1111111100000001_0000000001001011;
  //   top_5_coeffs[1] = 32'b1111111110111101_0000000011100111;
  //   top_5_coeffs[2] = 32'b0000000000001101_1111111111110100;
  //   top_5_coeffs[3] = 32'b0000000000000010_1111111111111101;
  //   top_5_coeffs[4] = 32'b0000000000001110_1111111111111001;
  // end

  coeff_info_gen_mags mag_gen (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .valid_data_in(all_coeffs_computed),
    .top_n_coeffs(top_5_coeffs),
    .coeff_mags_out(mags_out_coeffs),
    .valid_data_out(coeff_information_ready)
  );

  logic coeff_information_ready;
  logic [NUM_HARMONICS-1:0][31:0] mags_out_coeffs;

  localparam NUM_NOTES = 8;
  localparam NUM_HARMONICS = 5;
  logic [NUM_NOTES-1:0] notes_playing_switches;
  assign notes_playing_switches = {sw[15], sw[14], sw[13], sw[12], sw[11], sw[10], sw[9], sw[8]};

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

    // magnitudes_init_in[0] = 10'd300;
    // magnitudes_init_in[1] = 10'd218;
    // magnitudes_init_in[2] = 10'd34;
    // magnitudes_init_in[3] = 10'd11;
    // magnitudes_init_in[4] = 10'd4;
    
    for (integer i=0; i<NUM_HARMONICS; i++)begin
      magnitudes_init_in[i] = mags_out_coeffs[i][11:2];
    end

  end

  sine_wave_sum_v2 wav_sum_out (
    .clk_in(clk_pixel),
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

  always_ff @(posedge clk_pixel) begin 
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
          .clk_in(clk_pixel),
          .rst_in(sys_rst),
          .dc_in(line_out_audio),
          .sig_out(spk_out)

  );

  // set both output channels equal to the same PWM signal!
  assign spkl = spk_out;
  assign spkr = spk_out;

  assign led = {10'b0, valid_amp_out, audio_sample_buff}; // for debugging purposes


endmodule

`default_nettype wire