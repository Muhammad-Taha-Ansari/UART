module UART
#(
    parameter DATA_BITS   = 8,     // number of data bits
    parameter STOP_TICKS  = 16,    // stop bit ticks (s_tick counts)
    parameter DIVISOR     = 27,    // baud rate divisor (e.g., 0.5 Mbps @ 50 MHz)
    parameter DIVISOR_BIT = 5,     // bits needed for divisor counter
    parameter FIFO_W      = 2      // FIFO address bits (depth = 2**FIFO_W)
)
(
    input  wire        clk, reset,
    input  wire        rd, wr,     // CPU read/write signals
    input  wire        r_in,       // UART RX line
    input  wire [DATA_BITS-1:0] w_data,
    output wire        t_full,     // TX FIFO full
    output wire        r_empty,    // RX FIFO empty
    output wire        t_out,      // UART TX line
    output wire [DATA_BITS-1:0] r_data
);

    // ---------------- Wires ----------------
    wire tick;
    wire r_done_tick, t_done_tick;
    wire t_fifo_empty, t_fifo_not_empty;
    wire [DATA_BITS-1:0] t_fifo_out, r_fifo_out;

    // ---------------- Baud Generator ----------------
    baud #(.M(DIVISOR), .N(DIVISOR_BIT)) baud_unit (
        .clk(clk), .reset(reset),
        .max_tick(tick),
        .q()
    );

    // ---------------- Receiver ----------------
    receiver #(.DATA_BITS(DATA_BITS), .STOP_TICKS(STOP_TICKS)) r_unit (
        .clk(clk), .reset(reset),
        .reciever(r_in),
        .s_tick(tick),
        .r_done_tick(r_done_tick),
        .data_out(r_fifo_out)
    );

    // ---------------- RX FIFO ----------------
    fifo #(.data_bit(DATA_BITS), .fifo(FIFO_W)) r_fifo (
        .clk(clk), .reset(reset),
        .rd(rd), .wr(r_done_tick),
        .w_data(r_fifo_out),
        .empty(r_empty), .full(), .r_data(r_data)
    );

    // ---------------- Transmitter ----------------
    transmitter #(.DATA_BITS(DATA_BITS), .STOP_TICKS(STOP_TICKS)) t_unit (
        .clk(clk), .reset(reset),
        .t_start(t_fifo_not_empty),
        .s_tick(tick),
        .data_in(t_fifo_out),
        .t_done_tick(t_done_tick),
        .transmitter(t_out)
    );

    // ---------------- TX FIFO ----------------
    fifo #(.data_bit(DATA_BITS), .fifo(FIFO_W)) t_fifo (
        .clk(clk), .reset(reset),
        .rd(t_done_tick), .wr(wr),
        .w_data(w_data),
        .empty(t_fifo_empty), .full(t_full), .r_data(t_fifo_out)
    );

    assign t_fifo_not_empty = ~t_fifo_empty;

endmodule