module receiver #(
    parameter DATA_BITS = 8,   
    parameter STOP_TICKS = 16  
)(
    input  wire clk, reset,
    input  wire reciever, s_tick,       // serial input
    output reg  r_done_tick,
    output wire [7:0] data_out
);

    // State encoding
    localparam [1:0] 
        IDLE  = 2'b00,
        START = 2'b01,   
        DATA  = 2'b10,   
        STOP  = 2'b11;   

    // Registers
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;        // oversample counter
    reg [2:0] n_reg, n_next;        // bit counter
    reg [7:0] b_reg, b_next;        // shift register

    // Sequential part
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
        end
    end

    // Next-state logic
    always @* begin
        // defaults
        state_next  = state_reg;
        s_next      = s_reg;
        n_next      = n_reg;
        b_next      = b_reg;
        r_done_tick = 1'b0;

        case (state_reg)
            // wait for start bit
            IDLE: begin
                if (~reciever) begin        // line low = start bit
                    state_next = START;
                    s_next = 0;
                end
            end

            // confirm start bit (sample at midpoint = 8th tick)
            START: begin
                if (s_tick) begin
                    if (s_reg == 7) begin
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else
                        s_next = s_reg + 1;
                end
            end

            // receive data bits
            DATA: begin
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {reciever, b_reg[7:1]};  // shift in LSB first
                        if (n_reg == (DATA_BITS-1))
                            state_next = STOP;
                        else
                            n_next = n_reg + 1;
                    end else
                        s_next = s_reg + 1;
                end
            end

            // check stop bit
            STOP: begin
                if (s_tick) begin
                    if (s_reg == (STOP_TICKS-1)) begin
                        state_next  = IDLE;
                        r_done_tick = 1'b1;  // byte received
                    end else
                        s_next = s_reg + 1;
                end
            end

            default: state_next = IDLE;
        endcase
    end

    // Output
    assign data_out = b_reg;

endmodule

