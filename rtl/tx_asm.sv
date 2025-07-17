// Code your design here
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
    output logic tx_out
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
    logic [2:0] bit_count;
    logic parity;
    logic error_reg;

    assign tx_out = tx_out_reg;
    assign ready = ready_reg;

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
                        ready_reg <= 0;
                        data_reg <= data;
                    end else begin
                        ready_reg <= 1;
                    end
                    tx_out_reg <= 1;
                end
                
                start: begin
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
                end
            endcase
        end
    end
    
    always_comb begin
        
        
        case (current_state)
            idle: begin
                if (valid) begin
                    next_state = start;
                end else begin
                    next_state = idle;
                end
            end
            
            start: begin
                next_state = transmit;
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
            end
            
            default: next_state = idle;
        endcase
    end

endmodule

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
    logic [3:0] bit_count;
    logic [3:0] byte_count;
    logic parity;
    logic actual_parity;
    logic error_reg;
    logic valid_reg;


    assign data = data_reg;
    assign valid = valid_reg;
    assign error = error_reg;

    typedef enum logic [2:0] {
        idle = 3'b000,
        start = 3'b001,
        receive = 3'b010,
        parity_per_byte_checker = 3'b011,
        last_bit_parity_checker = 3'b100,
        stop = 3'b101
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
                //$assert (condition = (rx_in == 0), message = "Start bit not detected");
              	if(rx_in == 0) $display("still 0");
            end

            receive: begin
                data_reg <= {rx_in, data_reg[DATA_WIDTH-1:1]};
                bit_count <= bit_count + 1;
                
            end

            parity_per_byte_checker: begin

                //parity <= rx_in;
                byte_count <= byte_count + 1;
              //actual_parity <= ^data_reg[byte_count * 8 +: 8];
              error_reg <= (rx_in != (^data_reg[byte_count * 8 +: 8]));
                if (!((byte_count+1) * 8 == DATA_WIDTH)) begin
                        bit_count <= 0;
                end

            end

            last_bit_parity_checker: begin

                parity <= rx_in;
                actual_parity <= ^data_reg[DATA_WIDTH-1:0];
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
                    next_state = start;
                end else begin
                    next_state = idle;
                end

            end

            start: begin
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

            stop: begin
               next_state = idle;
            end

            default: begin
                next_state = idle; // Fallback to idle state
            end

        endcase

    end
            



 endmodule
