`timescale  1ns/1ns
logic clk;

module uart_rx_tb();
      parameter PERIOD = 10;
      always #(PERIOD/2) clk++;
      logic nRST;

      uart_tx DUT0(.clk(clk), .nRST(nRST), . )
      uart_rx DUT(.clk(clk), .nRST(nRST), .rx(rx), .data_out(data_out), .data_valid(data_valid), .busy(busy));
endmodule

program test(


);
endprogram