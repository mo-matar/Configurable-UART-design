`timescale 1ns/1ps

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
	output logic tx_done,
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
    logic tx_ready_internal;
    logic rx_valid_internal;
    logic tx_valid_internal;
    brg brg_inst (

        .clk(clk_576KHz),
        .select(brg_select),
        .rst_n(rst_n),
        .baud_tick(tx_rx_clk)
    );

    // Instantiate the data transmission register
    data_tx_reg data_tx_reg_inst (
        .cpu_valid(tx_valid),
        .cpu_ready(tx_ready),
        .tx_ready(tx_ready_internal), // Use the baud rate clock for synchronization
        .tx_valid(tx_valid_internal),
        .tx_done(tx_done),
		.cpu_clk(clk_576KHz)
    );


    // Instantiate the transmitter
    tx_asm #(.DATA_WIDTH(DATA_WIDTH)) tx_inst (
        .clk(tx_rx_clk),
        .rst_n(rst_n),
        .valid(tx_valid_internal),
        .data(tx_data),
        .error(tx_error),
        .parity_per_byte(tx_parity_per_byte),
        .ready(tx_ready_internal),
        .tx_out(tx_out),
		.tx_done(tx_done)
    );

    // Instantiate the receiver
    rx_asm #(.DATA_WIDTH(DATA_WIDTH)) rx_inst (
        .clk(tx_rx_clk),
        .rst_n(rst_n),
        .rx_in(rx_in),
        .parity_per_byte(rx_parity_per_byte),
        .valid(rx_valid_internal),
        .data(rx_data),
        .error(rx_error)
    );


    // instantiate the valid signal for the receiver

    rx_valid_gen rx_valid_gen_inst (
        .cpu_clk(clk_576KHz),
        .rx_valid(rx_valid_internal),
		.cpu_valid(rx_valid)
    );


    
endmodule