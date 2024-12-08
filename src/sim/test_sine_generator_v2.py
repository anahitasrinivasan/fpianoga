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
    # dut.valid_in.value = 0
    # dut.tabulate_in.value = 0
    # dut.hcount_in.value = 0
    # dut.vcount_in.value = 0
    # dut.data_valid_in.value = 0
    # dut.pixel_data_in.value = 0
    await ClockCycles(dut.clk_in,5)
    # dut.tabulate_in.value = 0
    dut.rst_in.value = 0
    dut.phase_offset_in.value = 0b0000_0000_0000_0000_0000_0000_0000_0000
    dut.valid_info_in.value = 0b1
    dut.phase_increment.value = 0b0000_1100_0000_0000_0000_1000_0000_0000

    for i in range(50):
        await ClockCycles(dut.clk_in,1)
        x = dut.full_phase_next_out.value
        dut.phase_offset_in.value = x
    

    # dut.rst_in.value = 0
    # dut.data_valid_in.value = 1
    # await ClockCycles (dut.clk_in, 1)
    # for i in range(10):
    #     for j in range(3):
    #         dut.pixel_data_in = rr(0, 16)
    #         dut.hcount_in.value = j
    #         dut.vcount_in.value = i
    #         await ClockCycles(dut.clk_in, 1)

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
    sources = [proj_path / "hdl" / "sine_generator_v2.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="sine_generator_v2",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="sine_generator_v2",
        test_module="test_sine_generator_v2",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()