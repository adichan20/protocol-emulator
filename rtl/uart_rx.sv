module uart_rx #(
      parameter int CLK_FREQ,
      parameter int BAUD_RATE
)(
      input logic clk,
      input logic nRST,
      input logic rx,

      output logic [7:0] data_out,
      output logic data_valid,
      output logic busy
);
      localparam int CLKS_PER_UART_BIT = CLK_FREQ / BAUD_RATE;
      localparam int BAUD_COUNT_WIDTH = (CLKS_PER_UART_BIT <= 1) ? 1: $clog2(CLKS_PER_UART_BIT);
      localparam int MID_CYCLE_COUNT = CLKS_PER_UART_BIT / 2;

      logic [BAUD_COUNT_WIDTH-1:0] baud_counter;
      logic start_valid;
      logic stop_valid;


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
                        if (start_valid) busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1 && start_valid) next_state = BIT0;
                  end

                  BIT0: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT1;
                  end

                  BIT1: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT2;
                  end

                  BIT2: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT3;
                  end                  

                  BIT3: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT4;
                  end          

                  BIT4: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT5;
                  end     

                  BIT5: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT6;
                  end     

                  BIT6: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = BIT7;
                  end     

                  BIT7: begin
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = STOP_CHECK;
                  end  

                  STOP_CHECK: begin 
                        busy = 1'b1;
                        if (baud_counter == CLKS_PER_UART_BIT - 1) next_state = START;
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
                  baud_counter <= '0;
                  start_valid <= 1'b0;
                  stop_valid <= 1'b0;
            end else begin
                  data_valid <= 1'b0;
                  current_state <= next_state;
                  baud_counter <= (baud_counter+1) % CLKS_PER_UART_BIT;
                  
                  case (current_state)
                        START: begin
                              if (rx == 1'b0 && !start_valid) begin
                                    start_valid <= 1'b1;   
                                    baud_counter <= '0;
                              end
                        end

                        BIT0: if (baud_counter == MID_CYCLE_COUNT) shift_register[0] <= rx;
                        BIT1: if (baud_counter == MID_CYCLE_COUNT) shift_register[1] <= rx;
                        BIT2: if (baud_counter == MID_CYCLE_COUNT) shift_register[2] <= rx;
                        BIT3: if (baud_counter == MID_CYCLE_COUNT) shift_register[3] <= rx;
                        BIT4: if (baud_counter == MID_CYCLE_COUNT) shift_register[4] <= rx;
                        BIT5: if (baud_counter == MID_CYCLE_COUNT) shift_register[5] <= rx;
                        BIT6: if (baud_counter == MID_CYCLE_COUNT) shift_register[6] <= rx;
                        BIT7: if (baud_counter == MID_CYCLE_COUNT) shift_register[7] <= rx;

                        STOP_CHECK: begin
                              if (baud_counter == MID_CYCLE_COUNT && rx == 1'b1) begin
                                    stop_valid <= 1'b1;
                              end else if (baud_counter == CLKS_PER_UART_BIT - 1) begin
                                    if (stop_valid) begin
                                          data_out <= shift_register;
                                          data_valid <= 1'b1;
                                    end 
                                    start_valid <= 1'b0;
                                    stop_valid <= 1'b0;                                    
                              end
                        end
                  endcase
            end
      end
endmodule
