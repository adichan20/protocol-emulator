`timescale 1 ns/ 1ns

module uart_tx(
      input logic clk,
      input logic nRST,
      input logic start, //active high
      input logic [7:0] data_in,

      output logic tx,
      output logic busy, 
      output logic done
);
      logic [7:0] shift_register;

      //uart output: start bit (tx is default high), data frame (8bits), no parity bit, stop bit (1)
      
      typedef enum logic [3:0] {
            IDLE,
            START,
            BIT0,
            BIT1,
            BIT2,
            BIT3,
            BIT4, 
            BIT5,
            BIT6, 
            BIT7,
            STOP
      } state_t;

      state_t current_state;
      state_t next_state;

      always_comb begin
            next_state = current_state;
            case (current_state) 
                  IDLE: if (start && !busy) next_state = START;
                  START: next_state = BIT0;
                  BIT0: next_state = BIT1;
                  BIT1: next_state = BIT2;
                  BIT2: next_state = BIT3;
                  BIT3: next_state = BIT4;
                  BIT4: next_state = BIT5;
                  BIT5: next_state = BIT6;
                  BIT6: next_state = BIT7;
                  BIT7: next_state = STOP;
                  STOP: next_state = IDLE;
                  default: next_state = IDLE;
            endcase
      end

      always_comb begin
            busy = 1'b0;
            done = 1'b0;
            tx = 1'b1;
            
            case (current_state)
                  START: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = 1'b0;
                  end 

                  BIT0: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[0];                        
                  end

                  BIT1: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[1];                        
                  end

                  BIT2: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[2];                        
                  end

                  BIT3: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[3];                        
                  end

                  BIT4: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[4];                        
                  end

                  BIT5: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[5];                        
                  end

                  BIT6: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[6];                        
                  end

                  BIT7: begin
                        busy = 1'b1;
                        done = 1'b0;
                        tx = shift_register[7];                        
                  end

                  STOP: begin
                        busy = 1'b1;
                        done = 1'b1;
                        tx = 1'b1;                        
                  end

                  default: begin
                        busy = 1'b0;
                        done = 1'b0;
                        tx = 1'b0;   
                  end
            endcase 
      end

      always_ff @(posedge clk, negedge nRST) begin
            if (!nRST) begin
                  shift_register <= '0;
                  current_state <= IDLE;
            end else begin
                  if (start && !busy) begin
                        shift_register <= data_in;
                  end
                  current_state <= next_state;
            end

      end

      

endmodule 