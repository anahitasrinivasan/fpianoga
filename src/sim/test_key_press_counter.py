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
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut._log.info("Holding reset...")
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in, 3) #wait three clock cycles
    dut.rst_in.value = 0 #un reset device
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 1
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 0
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 1
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 0
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 1
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 0
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 1
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles
    dut.key_in.value = 0
    await ClockCycles(dut.clk_in, 3) #wait a few clock cycles

def key_press_runner():
    """Simulate using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "key_press_counter.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="key_press_counter",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="key_press_counter",
        test_module="test_key_press_counter",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    key_press_runner()