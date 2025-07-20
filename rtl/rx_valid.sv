module rx_valid_gen (
    input logic cpu_clk,
    input logic rx_valid,
    output logic cpu_valid
);

    /*this module has two states
    first state makes the cpu_valid signal low, until the rx_valid signal is high
    then we go to the second state, where cpu_valid is high
    then the next state will be directly the first state again
    
    */


    typedef enum logic {
        IDLE,
        VALID
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge cpu_clk) begin
        current_state <= next_state;
    end

    always_comb begin
        case (current_state)
            IDLE: begin
                if (rx_valid) begin
                    next_state = VALID;
                    cpu_valid = 1; // CPU is ready to process data
                end else begin
                    cpu_valid = 0; // CPU is not ready until rx_valid is high
                    next_state = IDLE;
                end
            end
            
            VALID: begin
                if (rx_valid) begin
                    cpu_valid = 0;
                    next_state = VALID; // Go back to IDLE if rx_valid goes low
                end
                else begin
                    cpu_valid = 0; // CPU is not ready until rx_valid is high
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE; // Default state is IDLE
                cpu_valid = rx_valid;
            end
        endcase
    end

endmodule