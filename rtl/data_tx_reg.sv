/*
 * UART Transmitter Data Register
 *

 * This register is responsible for managing the valid-ready handshake between two different
 * clock domains: the CPU domain and the UART transmitter domain.
 * it solves the issue of synchronizing data transfer between these two domains.
 * when the tx_ready signals is asserted, it indicates that the UART transmitter is ready to receive data.
 * * The CPU can then assert the cpu_valid signal to indicate that it has data ready for transmission.
    * The register will then assert the tx_valid signal to indicate that the data is ready for transmission.
    and the cpu_ready signal will be deasserted predicting the ready signal that will be deasserted later by the transmitter
    * this ensures that the ready signal is deasserted at the right time, allowing the CPU to prepare the next data for transmission.
  */


 module data_tx_reg (
    input logic cpu_valid,
    input logic cpu_clk,
    output logic cpu_ready,

    input logic tx_ready,
    output logic tx_valid,

    input logic tx_done
);

    typedef enum logic { IDLE = 0, ACTIVE = 1} state_t;
    state_t ready_state;
    logic tx_done_prev; // Previous state of tx_done for edge detection
    logic tx_done_pulse; // Pulse signal for tx_done positive edge
    
    // Edge detection for tx_done
    always @(posedge cpu_clk) begin
        tx_done_prev <= tx_done;
    end
    
    assign tx_done_pulse = tx_done & ~tx_done_prev; // Positive edge detection

    always @(posedge cpu_clk) begin
        if (tx_done_pulse) begin
            ready_state <= IDLE;
        end
        else begin
            case (ready_state)
                IDLE: begin
                    if (cpu_valid && tx_ready)
                        ready_state <= ACTIVE;
                end
                ACTIVE: begin
                    if (!cpu_valid || !tx_ready)
                        ready_state <= IDLE;
                end
                default: begin
                    ready_state <= IDLE; // Default state is IDLE
                end
            endcase
        end
    end
 
    always @(*) begin
        case (ready_state)
            IDLE: begin
                cpu_ready = tx_ready;
                tx_valid = cpu_valid;
            end
            ACTIVE: begin
                cpu_ready = 0;
                tx_valid = cpu_valid;
            end
        endcase
    end

endmodule