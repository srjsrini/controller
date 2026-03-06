`timescale 1us/1us
module controller (
    input  logic clk, rst_n,
    input  logic [4:0] rs1_addr, rs2_addr, rd_addr_exec,
    input  logic rs1_en, rs2_en, we_exec,
    output logic stall, flush_exec
);
    always_comb begin
        stall = 1'b0; flush_exec = 1'b0;
        if (rst_n && we_exec && (rd_addr_exec != 5'b0)) begin
            if ((rs1_en && (rs1_addr == rd_addr_exec)) || 
                (rs2_en && (rs2_addr == rd_addr_exec))) begin
                stall = 1'b1; flush_exec = 1'b1;
            end
        end
    end
endmodule
