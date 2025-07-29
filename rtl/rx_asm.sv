

/**
 * @fileoverview
 * This file contains the implementation of the main RX logic.

    this is the implementation of a receiver for the uart protocol.
    the implementation is based on an ASM chart that defines the
    * state transitions and actions for receiving data over UART.

    this is the ASM chart for the UART receiver:

    idle:
    error = 0;
    valid = 0;
    if (rx_in == 0) next_state = start
    else next_state = idle

    

    start:
    bit_count = 0;
    byte_count = 0;
    data_reg = 0;
    actual_parity = 0;
    parity = 0;
 

    receive:
    data_reg = {rx_in, data_reg[DATA_WIDTH-1:1]};
    bit_count = bit_count + 1;
    if (bit_count == 7 && parity_per_byte == 1) next_state = parity_per_byte_checker
    else if (bit_count == DATA_WIDTH-1) next_state = last_bit_parity_checker
    else next_state = receive


    parity_per_byte_checker:
    parity = rx_in;
    actual_parity = actual_parity ^ rx_in;
    error = (parity != actual_parity);
    byte_count = byte_count + 1;
    bit_count = 0;
    if ((byte_count + 1) * 8 == DATA_WIDTH) next_state = stop
    else next_state = receive


    last_bit_parity_checker:
    parity = rx_in;
    actual_parity = actual_parity ^ rx_in;
    error = (parity != actual_parity);
    next_state = stop;


    stop:
	DATA = DATA_REG
	valid = 1
	
 

 */


 module rx_asm #(
    parameter DATA_WIDTH = 8


) ( input  logic clk,
    input  logic rst_n,
    input  logic rx_in,
    input  logic parity_per_byte,
    output logic valid,
    output logic [DATA_WIDTH-1:0] data,
    output logic error
);

    logic [DATA_WIDTH-1:0] data_reg;
    logic [5:0] bit_count;
    logic [3:0] byte_count;
    logic parity;
    logic actual_parity;
    logic error_reg;
    logic valid_reg;
	    logic last_parity_per_byte;

	


    assign data = data_reg;
    assign valid = valid_reg;
    assign error = error_reg;

    typedef enum logic [2:0] {
        idle = 3'b000,
        start = 3'b001,
        receive = 3'b010,
        parity_per_byte_checker = 3'b011,
        last_bit_parity_checker = 3'b100,
        stop = 3'b101,
        last_bit_parity_per_byte_checker = 3'b110
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= idle;
        end else begin
            current_state <= next_state;

        end


    end

    always_ff @(posedge clk) begin
        case (current_state)
            idle: begin
                error_reg <= 0;
                valid_reg <= 0;
                if (rx_in == 0) begin
                    data_reg <= 0;
                    bit_count <= 0;
                    byte_count <= 0;
                end
            end
            start:
            begin

              	if(rx_in == 0) $display("still 0");
            end

            receive: begin
                    data_reg <= {rx_in, data_reg[DATA_WIDTH-1:1]};
                    bit_count <= bit_count + 1;
                
            end

            parity_per_byte_checker: begin

                //parity <= rx_in;
                byte_count <= byte_count + 1;
				bit_count <= 0;
              //actual_parity <= ^data_reg[byte_count * 8 +: 8];
             if(!error_reg) error_reg <= (rx_in != (^data_reg[byte_count * 8 +: 8]));

            end	
			
			last_bit_parity_per_byte_checker: begin

                error_reg <= (rx_in != (last_parity_per_byte));
 

            end

            last_bit_parity_checker: begin

                //parity <= rx_in;
                //actual_parity <= ^data_reg[DATA_WIDTH-1:0];
                error_reg <= (rx_in != (^data_reg[DATA_WIDTH-1:0]));

            end


            stop: begin

                valid_reg <= 1;
				
            end

        endcase




    end


    always_comb begin

        case(current_state)
            
            idle: begin

                if (rx_in == 0) begin
                    next_state = receive;
                end else begin
                    next_state = idle;
                end

            end

            start: begin // this state is not used
                next_state = receive;

            end

            receive: begin

                if (bit_count == 7 && parity_per_byte) begin
					
                    next_state = parity_per_byte_checker;
                end else if (bit_count == DATA_WIDTH - 1) begin
                    next_state = last_bit_parity_checker;
                end else begin
                    next_state = receive;
                end

            end

            parity_per_byte_checker: begin

                if ((byte_count + 1) * 8 == DATA_WIDTH) begin
                    next_state = stop;
                end else begin
                    next_state = receive;
                end

            end

            last_bit_parity_checker: begin
                next_state = stop;
            end	 
			
			            last_bit_parity_per_byte_checker: begin
                next_state = stop;
            end

            stop: begin
               next_state = idle;
            end

            default: begin
                next_state = idle; // Fallback to idle state
            end

        endcase

    end
            



 endmodule

