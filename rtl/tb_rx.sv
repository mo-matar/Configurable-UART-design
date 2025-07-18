`timescale 1ns/1ps

module tb_rx;

    parameter DATA_WIDTH = 32;

    logic clk;
    logic rst_n;
    logic tx_valid;
    logic tx_ready;
    logic [DATA_WIDTH-1:0] tx_data;
    logic tx_error;
    logic parity_per_byte;
    logic tx_out;

    logic rx_in;
    logic rx_valid;
    logic [DATA_WIDTH-1:0] rx_data;
    logic rx_error;

    // Instantiate the transmitter
    tx_asm #(.DATA_WIDTH(DATA_WIDTH)) tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .valid(tx_valid),
        .data(tx_data),
        .error(tx_error),
        .parity_per_byte(parity_per_byte),
        .ready(tx_ready),
        .tx_out(tx_out)
    );

    // Instantiate the receiver
    rx_asm #(.DATA_WIDTH(DATA_WIDTH)) rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_in(rx_in),
        .parity_per_byte(parity_per_byte),
        .valid(rx_valid),
        .data(rx_data),
        .error(rx_error)
    );

    // Connect transmitter output to receiver input
    assign rx_in = tx_out;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    initial begin
        // Initialize
        rst_n = 0;
        tx_valid = 0;
        tx_data = 0;
        tx_error = 0;
        parity_per_byte = 1;
        #(20);
        rst_n = 1;

        // Wait for reset deassertion
        #(20);

        // Send 0xFC (8'b11111100)
        tx_data = 32'hFCFCEEEB;
        tx_valid = 1;


        // Wait for receiver to process
        wait (rx_valid);

        // Check result
        if (rx_data == 32'hFCFCEEEB)
            $display("PASS: Received data=0x%0h valid=%0b  error=%0b",  rx_data, rx_valid, rx_error);
        else
            $display("FAIL: valid=%0b data=0x%0h error=%0b", rx_valid, rx_data, rx_error);

        $finish;
    end

endmodule
