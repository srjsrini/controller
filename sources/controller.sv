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

// TODO: Implement UART transmit logic with parity

endmodule





