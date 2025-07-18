`timescale 1us/1ns

module brg_tb;

    // Parameters
    localparam CLK_FREQ = 576_000;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [1:0] select;
    logic baud_tick;

    // Instantiate DUT
    brg #(.CLK_FREQ(CLK_FREQ)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .select(select),
        .baud_tick(baud_tick)
    );

    // Clock generation
    initial clk = 0;
    always #1 clk = ~clk; // 500 kHz clock (period = 2us)
	integer i;
    // Test sequence
    initial begin
        rst_n = 0;
        select = 2'b00;
        #5;
        rst_n = 1;

        // Test all select values
        
        for (i = 0; i < 4; i = i + 1) begin
            select = i[1:0];
            $display("Testing select = %0d", select);
            repeat (1000) begin
                @(posedge clk);
                if (baud_tick)
                    $display("Time %0t: baud_tick (select=%0d)", $time, select);
            end
        end

        $display("Testbench finished.");
        $finish;
    end

endmodule
