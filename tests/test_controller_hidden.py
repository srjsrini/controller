import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
import random

@cocotb.test()
async def uart_tx_test(dut):

    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst.value = 1
    dut.tx_start.value = 0
    dut.data_in.value = 0
    dut.parity_en.value = 1
    dut.parity_type.value = 0
    dut.baud_div.value = 5

    for _ in range(5):
        await RisingEdge(dut.clk)

    dut.rst.value = 0

    for _ in range(5):

        data = random.randint(0,255)

        dut.data_in.value = data
        dut.tx_start.value = 1

        await RisingEdge(dut.clk)
        dut.tx_start.value = 0

        while dut.busy.value == 1:
            await RisingEdge(dut.clk)

        assert dut.busy.value == 0
