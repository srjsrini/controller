`timescale 1us/1us

module controller (
    input  logic clk, rst_n,
    input  logic [4:0] rs1_addr, rs2_addr, rd_addr_exec,
    input  logic rs1_en, rs2_en, we_exec,
    output logic stall, flush_exec
);

    // BUGGY IMPLEMENTATION: 
    // This will pass the RAW hazard test, but fail the "No Hazard" 
    // and "Register 0" tests because it stalls too often.
    always_comb begin
        if (rst_n && we_exec) begin
            stall = 1'b1;
            flush_exec = 1'b1;
        end else begin
            stall = 1'b0;
            flush_exec = 1'b0;
        end
    end

endmodule
