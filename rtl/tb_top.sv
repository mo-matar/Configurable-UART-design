module tb_top;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10; // 100MHz clock
    
    // Testbench signals
    logic clk_576KHz;
    logic rst_n;
    
    // TX signals
    logic tx_valid;
    logic [DATA_WIDTH-1:0] tx_data;
    logic tx_error;
    logic tx_parity_per_byte;
    logic tx_ready;
    logic tx_out;
    logic tx_done;
    
    // RX signals
    logic rx_in;
    logic rx_parity_per_byte;
    logic rx_valid;
    logic [DATA_WIDTH-1:0] rx_data;
    logic rx_error;
    
    // BRG select
    logic [1:0] brg_select;
    
    // Instantiate UART top module
    uart_top #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk_576KHz(clk_576KHz),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .tx_error(tx_error),
        .tx_parity_per_byte(tx_parity_per_byte),
        .tx_ready(tx_ready),
        .tx_out(tx_out),
        .tx_done(tx_done),
        .rx_in(rx_in),
        .rx_parity_per_byte(rx_parity_per_byte),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .rx_error(rx_error),
        .brg_select(brg_select)
    );
    
    // Connect TX output to RX input for loopback
    assign rx_in = tx_out;
    
    // Clock generation
    initial begin
        clk_576KHz = 0;
        forever #(CLK_PERIOD/2) clk_576KHz = ~clk_576KHz;
    end
    
    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 1;
        tx_valid = 0;
        tx_data = 8'h00;
        tx_error = 0;
        tx_parity_per_byte = 0;
        rx_parity_per_byte = 0;
        brg_select = 2'b00; // 9600 baud
        
        // Reset sequence
        #(CLK_PERIOD * 10);
        rst_n <= 0; 
		#(CLK_PERIOD * 10);
		rst_n <= 1;
        #(CLK_PERIOD * 10);
		@(posedge clk_576KHz)
		tx_valid <= 1;
        
        // Wait for system to stabilize
//        wait(tx_ready);
        //#(CLK_PERIOD * 5);
        
        // Send test data
        $display("Starting transmission of 0xA5");
        tx_data <= 8'hA5;
		@(posedge clk_576KHz)
        tx_valid <= 1;
		
        
        
        // Wait for transmission to complete
	    wait(tx_ready == 1)
        tx_data <= 8'hFC;
		
        // Wait for reception to complete 
		wait(tx_ready == 1)
        wait(rx_valid);
        $display("Reception completed: rx_data = 0x%h, error = %b", rx_data, rx_error);
        
        // Check if received data matches transmitted data
        if (rx_data == 8'hA5 && !rx_error) begin
            $display("TEST PASSED: Data transmitted and received correctly");
        end else begin
            $display("TEST FAILED: Expected 0xA5, got 0x%h, error = %b", rx_data, rx_error);
        end
		
			wait(tx_ready == 1)
		tx_valid <= 0;
		
		wait(rx_valid)
		
		

        
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t: tx_ready=%b tx_valid=%b tx_out=%b rx_valid=%b rx_data=0x%h rx_error=%b", 
                 $time, tx_ready, tx_valid, tx_out, rx_valid, rx_data, rx_error);
    end

endmodule
