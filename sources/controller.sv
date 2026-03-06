`timescale 1us/1us
module controller (
    input  logic clk, rst_n,
    input  logic [4:0] rs1_addr, rs2_addr, rd_addr_exec,
    input  logic rs1_en, rs2_en, we_exec,
    output logic stall, flush_exec
);
    // TODO: Implement RAW hazard detection logic
    assign stall = 1'b0;      
    assign flush_exec = 1'b0; 
endmodule
