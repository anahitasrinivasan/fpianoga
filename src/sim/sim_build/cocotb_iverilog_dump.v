module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/anahitasrinivasan/Desktop/6205_python/fpianoga/src/sim/sim_build/key_press_counter.fst");
    $dumpvars(0, key_press_counter);
end
endmodule
