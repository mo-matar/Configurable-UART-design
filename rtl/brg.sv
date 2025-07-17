module brg #(
    parameter CLK_FREQ = 576_000 // 
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [1:0]  select,     // 2-bit select: 00=9200, 01=19200, 10=38400, 11=57600
    output logic        baud_tick
);

    // Baud rates supported
    localparam int BAUD_9200   = 9200;
    localparam int BAUD_19200  = 19200;
    localparam int BAUD_38400  = 38400;
    localparam int BAUD_57600  = 57600;

    // Calculate divider values for each baud rate
    localparam int DIV_9200   = CLK_FREQ / BAUD_9200;
    localparam int DIV_19200  = CLK_FREQ / BAUD_19200;
    localparam int DIV_38400  = CLK_FREQ / BAUD_38400;
    localparam int DIV_57600  = CLK_FREQ / BAUD_57600;

    logic [15:0] divider;
    logic [15:0] count;

    // Select divider based on select input
    always_comb begin
        case (select)
            2'b00: divider = DIV_9200;
            2'b01: divider = DIV_19200;
            2'b10: divider = DIV_38400;
            2'b11: divider = DIV_57600;
            default: divider = DIV_9200;
        endcase
    end

    // Clock divider logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            baud_tick <= 0;
        end else begin
            if (count == divider - 1) begin
                count <= 0;
                baud_tick <= 1;
            end else begin
                count <= count + 1;
                baud_tick <= 0;
            end
        end
    end

endmodule
