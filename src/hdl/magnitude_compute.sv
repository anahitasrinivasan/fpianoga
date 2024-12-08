`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module magnitude_compute ( 
    input wire clk_in,
    input wire rst_in,
    input wire [31:0] coeffs,
    input wire compute_needed, //will be single-cycle high
    output logic data_valid_out, //ideally single-cycle high
    output logic [31:0] mag_out //todo: determine the output dimension for this; want it to be smaller - see if is okay later on?
);


//todo: rememebver that the incoming values are signed - need to turn into the absolute value before computing anything from it

///SPLIT SQUARE SUM///

logic signed [15:0] real_in;
logic signed [15:0] img_in;
assign real_in = $signed(coeffs[31:16]);
assign img_in = $signed(coeffs[15:0]);

logic [31:0] real_square;
logic [31:0] img_square;

logic [31:0] sum_out;
logic valid_out_buff;
logic data_valid_out_sqs;

//problem: getting single-cycle high from the compute_needed that was passed in - look at tomorrow

always_ff @(posedge clk_in)begin
    if (rst_in)begin
        real_square <= 0;
        img_square <= 0;
        valid_out_buff <= 0;
    end else begin
        if (compute_needed||valid_out_buff)begin
            valid_out_buff <= compute_needed;
            data_valid_out_sqs <= valid_out_buff;
            real_square <= real_in*real_in;
            img_square <= img_in*img_in;

            sum_out <= real_square + img_square;
            data_valid_out_sqs <= valid_out_buff;
        end else begin
            data_valid_out_sqs <= 0;
        end
    end
end

////SQUARE ROOT COMPUTE///
///(Using IP)////////////

sqrt_int #(.WIDTH(32)) sqrt_inst (
    .clk(clk_in),
    .rst_in(rst_in),
    .start(data_valid_out_sqs),
    .busy(sqrt_busy_out),
    .rad(sum_out),
    .valid(data_valid_out),
    .root(mag_out),
    .rem(trash_remainder_out)
);

logic sqrt_busy_out;
logic [31:0] trash_remainder_out;

/////////////////////

endmodule

////IP IS HERE - COPY AND PASTED IT ////////
//I added reset in

// Project F Library - Square Root (Integer)
// (C)2021 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io


module sqrt_int #(parameter WIDTH=8) (      // width of radicand
    input wire logic clk,
    input wire rst_in,
    input wire logic start,             // start signal
    output     logic busy,              // calculation in progress
    output     logic valid,             // root and rem are valid
    input wire logic [WIDTH-1:0] rad,   // radicand
    output     logic [WIDTH-1:0] root,  // root
    output     logic [WIDTH-1:0] rem    // remainder
    );

    logic [WIDTH-1:0] x, x_next;    // radicand copy
    logic [WIDTH-1:0] q, q_next;    // intermediate root (quotient)
    logic [WIDTH+1:0] ac, ac_next;  // accumulator (2 bits wider)
    logic [WIDTH+1:0] test_res;     // sign test result (2 bits wider)

    localparam ITER = WIDTH >> 1;   // iterations are half radicand width
    logic [$clog2(ITER)-1:0] i;     // iteration counter

    always_comb begin
        test_res = ac - {q, 2'b01};
        if (test_res[WIDTH+1] == 0) begin  // test_res ≥0? (check MSB)
            {ac_next, x_next} = {test_res[WIDTH-1:0], x, 2'b0};
            q_next = {q[WIDTH-2:0], 1'b1};
        end else begin
            {ac_next, x_next} = {ac[WIDTH-1:0], x, 2'b0};
            q_next = q << 1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_in)begin
            busy <= 0;
            valid <= 0;
            i <= 0;
            q <= 0;
            root <= 0;
            rem <= 0;
            //todo: maybe add more reset values
        end else begin
            if (start) begin
                busy <= 1;
                valid <= 0;
                i <= 0;
                q <= 0;
                {ac, x} <= {{WIDTH{1'b0}}, rad, 2'b0};
            end else if (busy) begin
                if (i == ITER-1) begin  // we're done
                    busy <= 0;
                    valid <= 1;
                    root <= q_next;
                    rem <= ac_next[WIDTH+1:2];  // undo final shift
                end else begin  // next iteration
                    i <= i + 1;
                    x <= x_next;
                    ac <= ac_next;
                    q <= q_next;
                end
            end
        end
    end
endmodule

`default_nettype wire