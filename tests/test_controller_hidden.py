from __future__ import annotations

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_tools.runner import get_runner

LANGUAGE = os.getenv("HDL_TOPLEVEL_LANG", "verilog").lower().strip()


def calc_even_parity(data):
    return bin(data).count("1") % 2


@cocotb.test()
async def uart_tx_hidden_test(dut):
    """Test UART transmitter with parity"""

    dut.rst.value = 1
    dut.tx_start.value = 0
    dut.data_in.value = 0
    dut.parity_en.value = 1

    clock = Clock(dut.clk, 10, unit="us")
    clock.start(start_high=False)

    for _ in range(5):

        data = random.randint(0, 255)

        dut.data_in.value = data
        dut.tx_start.value = 1

        await RisingEdge(dut.clk)
        dut.tx_start.value = 0

        # Wait for start bit
        await RisingEdge(dut.clk)

        assert dut.tx.value == 0, "Start bit incorrect"

        # Check 8 data bits
        for i in range(8):
            await RisingEdge(dut.clk)
            expected = (data >> i) & 1
            assert dut.tx.value == expected, f"Data bit {i} incorrect"

        # Check parity bit
        await RisingEdge(dut.clk)
        parity = calc_even_parity(data)
        assert dut.tx.value == parity, "Parity bit incorrect"

        # Stop bit
        await RisingEdge(dut.clk)
        assert dut.tx.value == 1, "Stop bit incorrect"


def test_uart_tx_hidden_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [proj_path / "sources/controller.sv"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="uart_tx",
        always=True,
    )

    runner.test(
        hdl_toplevel="uart_tx",
        test_module="test_uart_tx_hidden"
    )
