import cocotb
import os
import sys
from math import log
import math
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner
from random import randrange as rr

@cocotb.test()
# async def test_a(dut):
#     """cocotb test for image_sprite"""
#     dut._log.info("Starting...")
#     cocotb.start_soon(Clock(dut.pixel_clk_in, 10, units="ns").start())
#     dut.rst_in.value = 0
#     await ClockCycles(dut.pixel_clk_in,1)
#     dut.rst_in.value = 1
#     await ClockCycles(dut.pixel_clk_in,5)
#     dut.x_in.value = 256
#     dut.y_in.value = 256
#     dut.vcount_in.value = 380
#     dut.rst_in.value = 0
#     await ClockCycles(dut.pixel_clk_in,10)
#     for x in range(1026):
#       await FallingEdge(dut.pixel_clk_in)
#       dut.hcount_in.value = x
#       await RisingEdge(dut.pixel_clk_in)

## the above for reference of what was done on the past testbench

async def test_a(dut):
    """cocotb test for image_sprite"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_in, 10, units="ns").start())
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in,1)
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in,5)

    dut.rst_in.value = 0
    dut.compute_needed.value = 1
    #dut.coeffs = 0b0000_0000_0000_0001_0000_0000_0000_0001
    #dut.coeffs = 0b1111_1111_1111_1111_1111_1111_1111_1111
    #dut.coeffs.value = 0b0000_0000_0000_0011_0000_0000_0000_0100
    dut.coeffs.value = 0b1111_1111_0000_0001_0000_0000_0100_1011
    await ClockCycles (dut.clk_in, 1)
    dut.compute_needed.value = 0
    await ClockCycles (dut.clk_in, 1)
    dut.compute_needed.value = 0
    await ClockCycles(dut.clk_in, 20)
    
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_in,1)
    dut.rst_in.value = 0
    await ClockCycles(dut.clk_in,1)

    dut.compute_needed.value = 1
    dut.coeffs = 0b1111_1111_1111_1111_1111_1111_1111_1111
    await ClockCycles (dut.clk_in, 1)
    dut.compute_needed.value = 0
    await ClockCycles(dut.clk_in, 20)

    # for i in range(40):
    #     # await FallingEdge(dut.clk_in)
    #     dut.pixel_data_in = rr(0, 16)
    #     if (dut.hcount_in == 3):
    #         dut.hcount_in.value = 0
    #         dut.vcount_in.value = dut.vcount_in + 1
    #     else:
    #         dut.hcount_in.value = dut.hcount_in + 1
    #     #await RisingEdge(dut.clk_in)
    #     await ClockCycles(dut.clk_in, 1)



    # dut.rst_in.value = 0
    # await ClockCycles(dut.clk_in,1)
    # for i in range(700):
    #     await FallingEdge(dut.clk_in)
    #     dut.x_in.value = i
    #     dut.y_in.value = i
    #     dut.valid_in.value = 1
    #     await RisingEdge(dut.clk_in)
    # dut.tabulate_in.value = 1
    # dut.valid_in.value = 0
    # await ClockCycles(dut.clk_in, 1)
    # dut.tabulate_in.value = 0
    # await ClockCycles(dut.clk_in, 5000)


    # dut.rst_in.value = 0
    # await ClockCycles(dut.clk_in,1)
    # dut.rst_in.value = 1
    # dut.valid_in.value = 0
    # dut.tabulate_in.value = 0
    # await ClockCycles(dut.clk_in,5)
    # dut.tabulate_in.value = 0

    # dut.rst_in.value = 0
    # await ClockCycles(dut.clk_in,1)
    # for i in range(700):
    #     await FallingEdge(dut.clk_in)
    #     dut.x_in.value = i
    #     dut.y_in.value = 10
    #     dut.valid_in.value = 1
    #     await RisingEdge(dut.clk_in)
    # dut.tabulate_in.value = 1
    # await ClockCycles(dut.clk_in, 1)
    # dut.tabulate_in.value = 0
    # await ClockCycles(dut.clk_in, 5000)

   
def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "magnitude_compute.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="magnitude_compute",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="magnitude_compute",
        test_module="test_magnitude_compute",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()
