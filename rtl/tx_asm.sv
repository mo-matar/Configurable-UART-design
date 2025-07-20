/**
 * @fileoverview
 * This file contains the implementation of the main application logic.

    this is the implementation of a transmitter for the uart protocol.
    the implementation is based on an ASM chart that defines the
    * state transitions and actions for transmitting data over UART.

    this is the ASM chart for the UART transmitter:

    idle:
    * - tx_out = 1;
     - ready = 1
     if (valid) ready = 0; next_state = start
     else next_state = idle

    start:
    tx_out = 0;
    byte_count = 0;
    bit_count = 0;
    parity = 0;
    next_state = transmit

    transmit:
    tx_out = data_reg[0];
    parity = parity ^ data_reg[0];
    bit_count = bit_count + 1;
    data_reg = data_reg >> 1;
    if (bit_count == 7 && parity_per_byte == 1) next_state = parity_per_byte_generator
    else if (bit_count == WIDTH-1) next_state = last_bit_parity_generator
    else next_state = transmit

    parity_per_byte_generator:
    tx_out = error_reg ? ~parity : parity;
    byte_count = byte_count + 1;
    if (byte_count * 8 == WIDTH) next_state = stop
    else bit_count = 0; next_state = transmit

    last_bit_parity_generator:
    tx_out = error_reg ? ~parity : parity;
    next_state = stop;

    stop:
    tx_out = 1;
    next_state = idle;


 */


 module tx_asm #(
    parameter DATA_WIDTH = 8
) (
    input  logic clk,
    input  logic rst_n,
    input  logic valid,
    input  logic [DATA_WIDTH-1:0] data,
    input  logic error,
    input  logic parity_per_byte,
    output logic ready,
    output logic tx_out,
    output logic tx_done
);

    logic ready_reg;
    logic tx_out_reg;



    typedef enum logic [2:0] {
        idle = 3'b000,
        start = 3'b001,
        transmit = 3'b010,
        parity_per_byte_generator = 3'b011,
        last_bit_parity_generator = 3'b100,
        stop = 3'b101
    } state_t;

    state_t current_state, next_state;
    logic [DATA_WIDTH-1:0] data_reg;
    logic [2:0] byte_count;
   logic [5:0] bit_count;
    logic parity;
    logic error_reg;

    assign tx_out = tx_out_reg;
    //assign ready = ready_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= idle;
            ready_reg <= 1;
            tx_out_reg <= 1;
            data_reg <= 0;
            byte_count <= 0;
            bit_count <= 0;
            parity <= 0;
            error_reg <= 0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                idle: begin
                    if (valid) begin
                      //
                    end else begin
                        //ready <= 1;
                    end
                    tx_out_reg <= 1;
                end
                
                start: begin
                                          data_reg <= data;
                                          //ready_reg <= 0;

                    tx_out_reg <= 0;
                    byte_count <= 0;
                    bit_count <= 0;
                    parity <= 0;
                    error_reg <= error;
                end
                
                transmit: begin
                    tx_out_reg <= data_reg[0];
                    parity <= parity ^ data_reg[0];
                    bit_count <= bit_count + 1;
                    data_reg <= data_reg >> 1;
                end
                
                parity_per_byte_generator: begin
                    tx_out_reg <= error_reg ? ~parity : parity;
                    byte_count <= byte_count + 1;
                    if (!((byte_count+1) * 8 == DATA_WIDTH)) begin
                        bit_count <= 0;
                    end
                end
                
                last_bit_parity_generator: begin
                    tx_out_reg <= error_reg ? ~parity : parity;
                end
                
                stop: begin
                    tx_out_reg <= 1;
                  	//ready <= 1;
                end
            endcase
        end
    end
    
    always_comb begin
        
        
        case (current_state)
            idle: begin
                if (valid) begin
                    next_state = start;
                  	ready = 0;
					  tx_done = 0;
                end else begin
                    next_state = idle;
                  	ready = 1;
                    tx_done = 0;
                end
            end
            
            start: begin
                next_state = transmit;	
				tx_done = 0;
                                  //ready = 0;

            end
            
            transmit: begin
                if (bit_count == 7 && parity_per_byte) begin
                    next_state = parity_per_byte_generator;
                end else if (bit_count == DATA_WIDTH - 1) begin
                    next_state = last_bit_parity_generator;
                end else begin
                    next_state = transmit;
                end
            end
            
            parity_per_byte_generator: begin
                if ((byte_count+1) * 8 == DATA_WIDTH) begin
                    next_state = stop;
                end else begin
                    next_state = transmit;
                end
            end
            
            last_bit_parity_generator: begin
                next_state = stop;
            end
            
            stop: begin
                next_state = idle;
                ready = 1;
                tx_done = 1; // Indicate that transmission is done
            end
            
            default: next_state = idle;
        endcase
    end

endmodule