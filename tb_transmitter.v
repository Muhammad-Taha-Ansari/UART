`timescale 1ns/1ps

module tb_transmitter;

  // Parameters
  parameter CLK_PERIOD = 20;     // 50 MHz clock -> 20ns
  parameter BAUD_RATE_TICK = 16; // oversampling factor

  // Signals
  reg clk, reset;
  reg t_start;
  reg s_tick;
  reg [7:0] data_in;
  wire t_done_tick;
  wire tx;   // transmitter output

  // Instantiate DUT
  transmitter uut (
    .clk(clk),
    .reset(reset),
    .t_start(t_start),
    .s_tick(s_tick),
    .data_in(data_in),
    .t_done_tick(t_done_tick),
    .transmitter(tx)
  );

  // Clock generation
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Baud tick generator
  integer tick_count = 0;
  always @(posedge clk) begin
    tick_count <= tick_count + 1;
    if (tick_count == BAUD_RATE_TICK-1) begin
      s_tick <= 1;
      tick_count <= 0;
    end else begin
      s_tick <= 0;
    end
  end

  // Task to send a byte
  task send_byte;
    input [7:0] data;
    begin
      @(posedge clk);
      data_in = data;
      t_start = 1;
      @(posedge clk);
      t_start = 0;
      // Wait until transmission is done
      wait(t_done_tick);
      #(10*CLK_PERIOD); // small gap
    end
  endtask

  // Test sequence
  initial begin
    // Init
    reset = 1;
    t_start = 0;
    data_in = 8'h00;
    s_tick = 0;
    #(10*CLK_PERIOD);
    reset = 0;

    // Transmit "HELLO"
    send_byte("H"); // 0x48
    send_byte("E"); // 0x45
    send_byte("L"); // 0x4C
    send_byte("L"); // 0x4C
    send_byte("O"); // 0x4F

    #(1000*CLK_PERIOD);
    $stop;
  end

endmodule
