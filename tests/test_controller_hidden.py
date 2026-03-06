import cocotb
from cocotb.triggers import Timer
import os
from pathlib import Path
from cocotb_tools.runner import get_runner

@cocotb.test()
async def stall_test(dut):
    dut.rst_n.value = 1
    dut.we_exec.value = 0
    dut.rs1_en.value = 0
    dut.rs2_en.value = 0
    await Timer(1, units="us")

    # Test RAW Hazard on rs1
    dut.rs1_addr.value = 5
    dut.rd_addr_exec.value = 5
    dut.we_exec.value = 1
    dut.rs1_en.value = 1
    await Timer(1, units="us")
    assert dut.stall.value == 1, "Error: Failed to stall"

def test_controller_hidden_runner():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sources = [proj_path / "sources/controller.sv"]
    runner = get_runner(sim)
    runner.build(sources=sources, hdl_toplevel="controller", always=True)
    runner.test(hdl_toplevel="controller", test_module="test_controller_hidden")
