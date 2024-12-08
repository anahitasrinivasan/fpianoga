import cocotb
import os
import random
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

@cocotb.test()
async def test_simple(dut):
    """simple test to make sure counters count"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.pixel_clk_in, 10, units="ns").start())
    dut._log.info("Holding reset...")
    dut.rst_in.value = 1
    await ClockCycles(dut.pixel_clk_in, 3) #wait three clock cycles
    dut.rst_in.value = 0 #un reset device
    await ClockCycles(dut.pixel_clk_in, 400) #wait a few clock cycles
    # try resetting again
    dut.rst_in.value = 1
    await ClockCycles(dut.pixel_clk_in, 3) #wait three clock cycles
    dut.rst_in.value = 0 #un reset device
    await ClockCycles(dut.pixel_clk_in, 20) #wait a few clock cycles

def video_sig_gen_runner():
    """Simulate using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "video_sig_gen.sv"]
    build_test_args = ["-Wall"]
    parameters = {
        'ACTIVE_H_PIXELS': 7, 
        'H_FRONT_PORCH': 1,
        'H_SYNC_WIDTH': 2, 
        'H_BACK_PORCH': 1, 
        'ACTIVE_LINES': 5, 
        'V_FRONT_PORCH': 1, 
        'V_SYNC_WIDTH': 2, 
        'V_BACK_PORCH': 1, 
        'FPS': 3}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="video_sig_gen",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="video_sig_gen",
        test_module="test_video_sig_gen",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    video_sig_gen_runner()