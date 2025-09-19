module fifo
#(
    parameter data_bit = 8,   // width of data (8-bit)
    parameter fifo     = 4    // address bits -> depth = 2^fifo
)
(
    input  wire                  clk, reset,
    input  wire                  rd, wr,
    input  wire [data_bit-1:0]   w_data,
    output wire                  empty, full,
    output wire [data_bit-1:0]   r_data
);

    localparam DEPTH = (1 << fifo);   // FIFO depth (2^fifo)

    // memory array
    reg [data_bit-1:0] array_reg [0:DEPTH-1];

    // pointers and counter
    reg [fifo-1:0] w_ptr_reg, w_ptr_next;
    reg [fifo-1:0] r_ptr_reg, r_ptr_next;
    reg [fifo:0]   count_reg, count_next;   // need extra bit for full detection
    reg [data_bit-1:0] r_data_reg;

    // sequential part
    always @(posedge clk, posedge reset)
        if (reset) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            count_reg <= 0;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            count_reg <= count_next;
        end

    // write memory (synchronous)
    always @(posedge clk)
        if (wr & ~full)
            array_reg[w_ptr_reg] <= w_data;

    // read memory (synchronous)
    always @(posedge clk)
        if (rd & ~empty)
            r_data_reg <= array_reg[r_ptr_reg];

    // next-state logic
    always @* begin
        // defaults
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        count_next = count_reg;

        // write
        if (wr & ~full)
            w_ptr_next = w_ptr_reg + 1;

        // read
        if (rd & ~empty)
            r_ptr_next = r_ptr_reg + 1;

        // count update
        case ({wr & ~full, rd & ~empty})
            2'b10: count_next = count_reg + 1; // write only
            2'b01: count_next = count_reg - 1; // read only
            default: count_next = count_reg;   // no change or both
        endcase
    end

    // outputs
    assign r_data = r_data_reg;
    assign full  = (count_reg == DEPTH);
    assign empty = (count_reg == 0);

endmodule

