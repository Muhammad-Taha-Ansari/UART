`timescale 1ns/1ps

module tb_b_gen;

    // Testbench signals
    reg clk;
    reg reset;
    wire max_tick;
    wire [4:0] q;   // N = 5

    // Instantiate DUT (Device Under Test)
    b_gen #(.M(27), .N(5)) uut (
        .clk(clk),
        .reset(reset),
        .max_tick(max_tick),
        .q(q)
    );

    // Clock generation: 50 MHz (20 ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // Apply stimulus
    initial begin
        // Start with reset active
        reset = 1;
        #50;          // hold reset for 50 ns

        // Release reset
        reset = 0;

        // Run simulation for some time
        #1000;        // 1000 ns run
        $stop;        // stop simulation
    end

endmodule

