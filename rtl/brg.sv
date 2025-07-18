module brg #(
    parameter CLK_FREQ = 576_000
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  select,     // 2-bit select: 00=9600, 01=19200, 10=38400, 11=57600
    output logic        baud_tick
);

    // baud rates supported
    localparam int BAUD_9600   = 9600;
    localparam int BAUD_19200  = 19200;
    localparam int BAUD_38400  = 38400;
    localparam int BAUD_57600  = 57600;

    // baud rate selection
    logic [15:0] current_baud;
    always_comb begin
        case (select)
            2'b00: current_baud = BAUD_9600;
            2'b01: current_baud = BAUD_19200;
            2'b10: current_baud = BAUD_38400;
            2'b11: current_baud = BAUD_57600;
            default: current_baud = BAUD_9600;
        endcase
    end

    //calculate divider value
    logic [31:0] max_rate;
    assign max_rate = CLK_FREQ / (current_baud); // Same rate for both rx and tx

    //counter width calculation
    localparam CNT_WIDTH = $clog2(CLK_FREQ / ( BAUD_57600)) + 1;

    logic [CNT_WIDTH-1:0] counter;


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (counter == max_rate[CNT_WIDTH-1:0]) begin
                counter <= 0;
                baud_tick <= ~baud_tick;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule

