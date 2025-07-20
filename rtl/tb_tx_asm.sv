module tb_tx_asm;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10; // 10ns clock period

    // Testbench signals
    logic clk;
    logic rst_n;
    logic valid;
    logic [DATA_WIDTH-1:0] data;
    logic error;
    logic parity_per_byte;
    logic ready;
    logic tx_out;
	logic tx_done;

    // Instantiate the DUT
    tx_asm #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .data(data),
        .error(error),
        .parity_per_byte(parity_per_byte),
        .ready(ready),
        .tx_out(tx_out),
		.tx_done(tx_done)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        valid = 0;
        data = 8'h00;
        error = 0;
        parity_per_byte = 0;

        // Reset
        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD);

        //// Test 1: Send byte 0xA5 without parity per byte
//        $display("Test 1: Sending byte 0xA5");
//        data = 8'hA5;
//        valid = 1;
//        #(CLK_PERIOD);
//        valid = 0;
//
//        // Wait for transmission to complete
//        wait(ready == 1);
//        #(CLK_PERIOD * 2);

        // Test 2: Send byte 0x3C with parity per byte enabled
        $display("Test 2: Sending byte 0x3C with parity per byte");
        parity_per_byte = 1;
        data = 8'h3C;
        valid = 1;
        #(CLK_PERIOD * 2);
        valid = 0;

         // Wait for transmission to complete
         wait(ready == 1);
         #(CLK_PERIOD);
		 #40;
		 
		 
		         // Test 2: Send byte 0x3C with parity per byte enabled
        $display("Test 2: Sending byte 0x3C with parity per byte");
        parity_per_byte = 1;
        data = 8'hFB;
        valid = 1;
        #(CLK_PERIOD * 2);
        valid = 0;

         // Wait for transmission to complete
         wait(ready == 1);
         #(CLK_PERIOD);

        // // Test 3: Send byte with error flag
        // $display("Test 3: Sending byte 0x55 with error");
        // parity_per_byte = 0;
        // error = 1;
        // data = 8'h55;
        // valid = 1;
        // #(CLK_PERIOD);
        // valid = 0;

        // // Wait for transmission to complete
        // wait(ready == 1);
        // #(CLK_PERIOD * 2);

        $display("All tests completed");
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        $display("Time: %0t | State: %s | tx_out: %b | ready: %b", 
                 $time, dut.current_state.name(), tx_out, ready);
    end

endmodule
