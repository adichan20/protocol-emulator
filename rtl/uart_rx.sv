module uart_rx(
      input logic clk,
      input logic nRST,
      input logic rx,

      output logic [7:0] data_out,
      output logic data_valid,
      output logic busy
);

      typedef enum logic [3:0] {
            START,
            BIT0,
            BIT1,
            BIT2,
            BIT3,
            BIT4, 
            BIT5,
            BIT6, 
            BIT7,
            STOP_CHECK
      } state_t;
      
      state_t current_state;
      state_t next_state;

      
      logic [7:0] shift_register;


      always_comb begin
            busy = 1'b0;
            next_state = current_state;

            case (current_state)
                  START: begin
                        if (rx == 0) begin
                              next_state = BIT0;
                              busy = 1'b1;
                        end
                  end

                  BIT0: begin
                        next_state = BIT1;
                        busy = 1'b1;
                  end

                  BIT1: begin
                        next_state = BIT2;
                        busy = 1'b1;
                  end

                  BIT2: begin
                        next_state = BIT3;
                        busy = 1'b1;
                  end                  

                  BIT3: begin
                        next_state = BIT4;
                        busy = 1'b1;
                  end          

                  BIT4: begin
                        next_state = BIT5;
                        busy = 1'b1;
                  end     

                  BIT5: begin
                        next_state = BIT6;
                        busy = 1'b1;
                  end     

                  BIT6: begin
                        next_state = BIT7;
                        busy = 1'b1;
                  end     

                  BIT7: begin
                        next_state = STOP_CHECK;
                        busy = 1'b1;
                  end  

                  STOP_CHECK: begin 
                        next_state = START;
                        busy = 1'b1;

                  end


                  default: next_state = START;
            endcase
      end

      always_ff @(posedge clk, negedge nRST) begin
            if (!nRST) begin
                  shift_register <= '0;
                  current_state <= START;
                  data_valid <= 1'b0;
                  data_out <= '0;

            end else begin
                  data_valid <= 1'b0;
                  current_state <= next_state;

                  case (current_state)
                        BIT0: shift_register[0] <= rx;
                        BIT1: shift_register[1] <= rx;
                        BIT2: shift_register[2] <= rx;
                        BIT3: shift_register[3] <= rx;
                        BIT4: shift_register[4] <= rx;
                        BIT5: shift_register[5] <= rx;
                        BIT6: shift_register[6] <= rx;
                        BIT7: shift_register[7] <= rx;
                        STOP_CHECK: begin
                              if (rx == 1'b1) begin
                                    data_out <= shift_register;
                                    data_valid <= 1'b1;
                              end
                        end
                  endcase
            end
      end
endmodule
