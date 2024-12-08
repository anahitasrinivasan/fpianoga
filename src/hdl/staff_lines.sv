module staff_lines(
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    output logic [7:0] red_out,
    output logic [7:0] green_out,
    output logic [7:0] blue_out
    );

    always_comb begin
        if(vcount_in == 10'd258 || vcount_in == 10'd259 || vcount_in == 10'd260 || vcount_in == 10'd261 || vcount_in == 10'd262 ||
           vcount_in == 10'd308 || vcount_in == 10'd309 || vcount_in == 10'd310  || vcount_in == 10'd311 || vcount_in == 10'd312 ||
           vcount_in == 10'd358 || vcount_in == 10'd359 || vcount_in == 10'd360 || vcount_in == 10'd361 || vcount_in == 10'd362 ||
           vcount_in == 10'd408 || vcount_in == 10'd409 || vcount_in == 10'd410 || vcount_in == 10'd411 || vcount_in == 10'd412 ||
           vcount_in == 10'd458 || vcount_in == 10'd459 || vcount_in == 10'd460 || vcount_in == 10'd461 || vcount_in == 10'd462) begin
            red_out = 8'h00;
            green_out = 8'h00;
            blue_out = 8'h00;
        end else begin
            red_out = 8'hFF;
            green_out = 8'hFF;
            blue_out = 8'hFF;
        end
    end

endmodule