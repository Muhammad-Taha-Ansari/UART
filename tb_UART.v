`timescale 1ns/1ps

module tb_UART;

    // Parameters (same as top module)
    parameter DATA_BITS   = 8;
    parameter STOP_TICKS  = 16;
    parameter DIVISOR     = 27;
    parameter DIVISOR_BIT = 5;
    parameter FIFO_W      = 2;

    // Inputs
    reg clk;
    reg reset;
    reg rd, wr;
    reg r_in;
    reg [DATA_BITS-1:0] w_data;

    // Outputs
    wire t_full, r_empty, t_out;
    wire [DATA_BITS-1:0] r_data;

    // Instantiate the UART
    UART #(
        .DATA_BITS(DATA_BITS),
        .STOP_TICKS(STOP_TICKS),
        .DIVISOR(DIVISOR),
        .DIVISOR_BIT(DIVISOR_BIT),
        .FIFO_W(FIFO_W)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .r_in(r_in),
        .w_data(w_data),
        .t_full(t_full),
        .r_empty(r_empty),
        .t_out(t_out),
        .r_data(r_data)
    );

    // ---------------- Clock Generation ----------------
    initial clk = 0;
    always #10 clk = ~clk; // 50 MHz clock -> 20 ns period

    // ---------------- Loopback ----------------
    // Connect TX back to RX for testing
    always @(*) r_in = t_out;

    // ---------------- Test Sequence ----------------
    initial begin
        // Initialize signals
        reset = 1;
        rd = 0;
        wr = 0;
        w_data = 0;

        // Wait 5 clock cycles (100 ns) and release reset
        #100;
        reset = 0;

        // ----------- Write Data to TX FIFO -----------
        w_data = 8'hA5;
        wr = 1;
        #20;           // 1 clock cycle = 20 ns
        wr = 0;

        #40;           // wait 2 cycles
        w_data = 8'h3C;
        wr = 1;
        #20;
        wr = 0;

        // ----------- Read RX FIFO -----------
        #1000;         // wait enough time for transmission
        rd = 1;
        #20;
        rd = 0;

        // Finish simulation
        #1000;
        $stop;
    end

endmodule
