`default_nettype none
module evt_counter
#(
  parameter MAX_COUNT = 100000000
  )
  ( input wire          clk_in,
    input wire          rst_in,
    input wire          evt_in,
    output logic [$clog2(MAX_COUNT)-1:0]  count_out
  );
 
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      count_out <= 0;
    end else begin
      /* your code here */
      if ((count_out == MAX_COUNT-1)&&evt_in) begin
        count_out <= 0;
      end else begin
      if (evt_in)begin
        count_out <= count_out + 16'b1;
      // end else begin
      //   count_out <= count_out;
      // end
      end
    end
    end
  end 


  // #(
  // parameter MAX_COUNT = 100
  // )
  // ( input wire          clk_in,
  //   input wire          rst_in,
  //   input wire          evt_in,
  //   output logic [$clog2(MAX_COUNT)-1:0]  count_out
  // );
 
  // always_ff @(posedge clk_in) begin
  //   if (rst_in) begin
  //     count_out <= 16'b0;
  //   end else begin
  //     /* your code here */
  //     if (count_out == MAX_COUNT-1) begin
  //       count_out <= 0;
  //     end else begin
  //     if (evt_in)begin
  //       count_out <= count_out + 16'b1;
  //     end else begin
  //       count_out <= count_out;
  //     end
  //   end
  //   end
  // end 
  
endmodule
`default_nettype wire



