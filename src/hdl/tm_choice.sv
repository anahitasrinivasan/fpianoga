module tm_choice (
  input wire [7:0] data_in,
  output logic [8:0] qm_out
  );

  logic [3:0] bit_count;

  always_comb begin
    bit_count = data_in[7] + data_in[6] + data_in[5] + data_in[4] + data_in[3] + data_in[2] + data_in[1] + data_in[0];
    if (bit_count > 4'd4 || (bit_count == 4'd4 && data_in[0] == 1'b0)) begin
        // xnor
        qm_out[0] = data_in[0];
        qm_out[1] = ~(data_in[1] ^ qm_out[0]);
        qm_out[2] = ~(data_in[2] ^ qm_out[1]);
        qm_out[3] = ~(data_in[3] ^ qm_out[2]);
        qm_out[4] = ~(data_in[4] ^ qm_out[3]);
        qm_out[5] = ~(data_in[5] ^ qm_out[4]);
        qm_out[6] = ~(data_in[6] ^ qm_out[5]);
        qm_out[7] = ~(data_in[7] ^ qm_out[6]);
        qm_out[8] = 1'b0;
    end else begin
        // xor
        qm_out[0] = data_in[0];
        qm_out[1] = data_in[1] ^ qm_out[0];
        qm_out[2] = data_in[2] ^ qm_out[1];
        qm_out[3] = data_in[3] ^ qm_out[2];
        qm_out[4] = data_in[4] ^ qm_out[3];
        qm_out[5] = data_in[5] ^ qm_out[4];
        qm_out[6] = data_in[6] ^ qm_out[5];
        qm_out[7] = data_in[7] ^ qm_out[6];
        qm_out[8] = 1'b1;
    end
  end
 
endmodule