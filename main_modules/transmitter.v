module transmitter #(
    parameter DATA_BITS = 8,
    parameter STOP_TICKS = 16
)(
    input  wire clk, reset,
    input  wire t_start, s_tick,
    input  wire [7:0] data_in,
    output reg  t_done_tick,
    output wire transmitter
);

    // State encoding
    localparam [1:0]
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    // State registers
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;         // sample tick counter
    reg [2:0] n_reg, n_next;         // data bit counter
    reg [7:0] b_reg, b_next;         // data shift register
    reg t_reg, t_next;               // tx output buffer

    // Sequential logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            t_reg     <= 1'b1; // idle line = high
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            t_reg     <= t_next;
        end
    end

    // Next-state logic
    always @* begin
        // defaults
        state_next   = state_reg;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        t_next       = t_reg;
        t_done_tick  = 1'b0;

        case (state_reg)
            IDLE: begin
                t_next = 1'b1; // idle line
                if (t_start) begin
                    state_next = START;
                    s_next = 0;
                    b_next = data_in;
                end
            end

            START: begin
                t_next = 1'b0; // start bit
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else
                        s_next = s_reg + 1;
                end
            end

            DATA: begin
                t_next = b_reg[0]; // send LSB
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DATA_BITS-1))
                            state_next = STOP;
                        else
                            n_next = n_reg + 1;
                    end else
                        s_next = s_reg + 1;
                end
            end

            STOP: begin
                t_next = 1'b1; // stop bit = high
                if (s_tick) begin
                    if (s_reg == (STOP_TICKS-1)) begin
                        state_next = IDLE;
                        t_done_tick = 1'b1;
                    end else
                        s_next = s_reg + 1;
                end
            end

            default: state_next = IDLE;
        endcase
    end

    // output assignment
    assign transmitter = t_reg;

endmodule

