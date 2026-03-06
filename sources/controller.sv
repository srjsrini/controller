module uart_tx (
    input  logic clk,
    input  logic rst,
    input  logic tx_start,
    input  logic [7:0] data_in,
    input  logic [15:0] baud_div,
    input  logic parity_en,
    input  logic parity_type,

    output logic tx,
    output logic busy
);

logic [3:0] bit_cnt;
logic [7:0] shift_reg;
logic [15:0] baud_cnt;
logic parity_bit;

typedef enum logic [2:0] {
    IDLE,
    START,
    DATA,
    PARITY,
    STOP
} state_t;

state_t state;

always_ff @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1;
        busy <= 0;
        baud_cnt <= 0;
        bit_cnt <= 0;
    end else begin

        case(state)

        IDLE: begin
            tx <= 1;
            busy <= 0;

            if(tx_start) begin
                shift_reg <= data_in;
                parity_bit <= ^data_in;  

                if(parity_type)
                    parity_bit <= ~(^data_in);

                state <= START;
                busy <= 1;
                baud_cnt <= 0;
            end
        end

        START: begin
            tx <= 0;

            if(baud_cnt == baud_div) begin
                baud_cnt <= 0;
                bit_cnt <= 0;
                state <= DATA;
            end else
                baud_cnt <= baud_cnt + 1;
        end

        DATA: begin
            tx <= shift_reg[0];

            if(baud_cnt == baud_div) begin
                baud_cnt <= 0;
                shift_reg <= shift_reg >> 1;

                if(bit_cnt == 7) begin
                    if(parity_en)
                        state <= PARITY;
                    else
                        state <= STOP;
                end
                else
                    bit_cnt <= bit_cnt + 1;
            end
            else
                baud_cnt <= baud_cnt + 1;
        end

        PARITY: begin
            tx <= parity_bit;

            if(baud_cnt == baud_div) begin
                baud_cnt <= 0;
                state <= STOP;
            end
            else
                baud_cnt <= baud_cnt + 1;
        end

        STOP: begin
            tx <= 1;

            if(baud_cnt == baud_div) begin
                baud_cnt <= 0;
                state <= IDLE;
            end
            else
                baud_cnt <= baud_cnt + 1;
        end

        endcase
    end
end

endmodule
