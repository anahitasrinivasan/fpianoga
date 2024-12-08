module note_sprite #(
  parameter WIDTH=50, HEIGHT=50)(
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [10:0] x_in,
  input wire [9:0]  y_in,
  input wire [23:0] color_in, 
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out);

  logic in_sprite;
  assign in_sprite = ((hcount_in >= x_in && hcount_in < (x_in + WIDTH)) &&
                      (vcount_in >= y_in && vcount_in < (y_in + HEIGHT)));
  always_comb begin
    if (in_sprite) begin
      red_out = color_in[23:16];
      green_out = color_in[15:8];
      blue_out = color_in[7:0];
    end else begin
      red_out = 8'hFF;
      green_out = 8'hFF;
      blue_out = 8'hFF;
    end
  end
endmodule