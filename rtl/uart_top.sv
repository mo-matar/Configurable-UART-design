module uart_top #(
    parameter DATA_WIDTH = 8
//	parameter PARITY_PER_BYTE = 1'b1;
//    parameter NO_PARITY_PER_BYTE = 1'b0;
) (
    input logic clk_576KHz,
    input logic rst_n,
    /*TRANSMITTER SIGNALS*/
    input logic tx_valid,
    input logic [DATA_WIDTH-1:0] tx_data,
    input logic tx_error,
    input logic tx_parity_per_byte,
    output logic tx_ready,
    output logic tx_out,
    /*RECEIVER SIGNALS*/
    input logic rx_in,
    input logic rx_parity_per_byte,
    output logic rx_valid,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic rx_error,
    /*BAUD RATE SELECTIONS*/
    input logic [1:0] brg_select
);

    logic tx_rx_clk;
    brg brg_inst (

        .clk(clk_576KHz),
        .select(brg_select),
        .rst_n(rst_n),
        .baud_tick(tx_rx_clk)
    );


    // Instantiate the transmitter
    tx_asm #(.DATA_WIDTH(DATA_WIDTH)) tx_inst (
        .clk(tx_rx_clk),
        .rst_n(rst_n),
        .valid(tx_valid),
        .data(tx_data),
        .error(tx_error),
        .parity_per_byte(tx_parity_per_byte),
        .ready(tx_ready),
        .tx_out(tx_out)
    );

    // Instantiate the receiver
    rx_asm #(.DATA_WIDTH(DATA_WIDTH)) rx_inst (
        .clk(tx_rx_clk),
        .rst_n(rst_n),
        .rx_in(rx_in),
        .parity_per_byte(rx_parity_per_byte),
        .valid(rx_valid),
        .data(rx_data),
        .error(rx_error)
    );


    
endmodule