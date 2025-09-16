`timescale 1ns/1ps

module tb_receiver;

  // Parameters
  parameter CLK_PERIOD = 20;     // 50 MHz clock (20ns period)
  parameter BAUD_RATE_TICK = 16; // oversampling = 16x

  // Signals
  reg clk, reset;
  reg rx;                // connected to "reciever" in module
  reg s_tick;
  wire r_done_tick;
  wire [7:0] data_out;

  // Instantiate DUT
  receiver uut (
    .clk(clk),
    .reset(reset),
    .reciever(rx),      // <-- matches your module
    .s_tick(s_tick),
    .r_done_tick(r_done_tick),
    .data_out(data_out)
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

  // UART frame sender task
  task send_byte;
    input [7:0] data;
    integer i;
    begin
      // Idle line
      rx = 1;
      #(BAUD_RATE_TICK*CLK_PERIOD);

      // Start bit
      rx = 0;
      #(BAUD_RATE_TICK*CLK_PERIOD);

      // Data bits (LSB first)
      for (i = 0; i < 8; i = i + 1) begin
        rx = data[i];
        #(BAUD_RATE_TICK*CLK_PERIOD);
      end

      // Stop bit
      rx = 1;
      #(BAUD_RATE_TICK*CLK_PERIOD);
    end
  endtask

  // Test sequence
  initial begin
    // Init
    reset = 1;
    rx = 1;
    s_tick = 0;
    #(10*CLK_PERIOD);
    reset = 0;

    // Send "HELLO"
    send_byte("H"); // 0x48
    send_byte("E"); // 0x45
    send_byte("L"); // 0x4C
    send_byte("L"); // 0x4C
    send_byte("O"); // 0x4F

    // Wait and stop
    #(1000*CLK_PERIOD);
    $stop;
  end

endmodule
