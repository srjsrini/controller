module uart_tx (

    input  logic       clk,
    input  logic       rst,

    input  logic       baud_tick,     // 1 cycle pulse per bit period
    input  logic       tx_start,

    input  logic [7:0] data_in,

    input  logic       parity_en,
    input  logic       parity_type,   // 0 = even, 1 = odd

    output logic       tx,
    output logic       busy
);

typedef enum logic [2:0] {
    IDLE,
    START_BIT,
    DATA_BITS,
    PARITY_BIT,
    STOP_BIT
} state_t;

state_t state;

logic [7:0] data_reg;
logic [2:0] bit_idx;
logic       parity_bit;

always_ff @(posedge clk) begin

    if (rst) begin
        state   <= IDLE;
        tx      <= 1'b1;
        busy    <= 0;
        bit_idx <= 0;
    end

    else begin

        case(state)

        //--------------------------------
        // IDLE
        //--------------------------------
        IDLE: begin
            tx   <= 1'b1;
            busy <= 0;

            if (tx_start) begin
                busy     <= 1;
                data_reg <= data_in;
                bit_idx  <= 0;

                if (parity_type)
                    parity_bit <= ~(^data_in); // odd
                else
                    parity_bit <= ^data_in;    // even

                state <= START_BIT;
            end
        end

        //--------------------------------
        // START BIT
        //--------------------------------
        START_BIT: begin
            if (baud_tick) begin
                tx <= 0;
                state <= DATA_BITS;
            end
        end

        //--------------------------------
        // DATA BITS
        //--------------------------------
        DATA_BITS: begin
            if (baud_tick) begin
                tx <= data_reg[bit_idx];

                if (bit_idx < 7)
                    bit_idx <= bit_idx + 1;
                else begin
                    bit_idx <= 0;

                    if (parity_en)
                        state <= PARITY_BIT;
                    else
                        state <= STOP_BIT;
                end
            end
        end

        //--------------------------------
        // PARITY BIT
        //--------------------------------
        PARITY_BIT: begin
            if (baud_tick) begin
                tx <= parity_bit;
                state <= STOP_BIT;
            end
        end

        //--------------------------------
        // STOP BIT
        //--------------------------------
        STOP_BIT: begin
            if (baud_tick) begin
                tx   <= 1;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule
