`timescale 1 ns/1 ns
logic clk;

module uart_tx_tb();
      parameter PERIOD = 10;
      always #(PERIOD/2) clk++;
      
      logic nRST;
      logic start;
      logic [7:0] data_in;
      logic tx;
      logic busy;
      logic done;

      initial begin
            nRST = 1'b1;
            @(posedge clk);
            nRST = 1'b0;
            @(posedge clk);
            nRST = 1'b1;
      end

      uart_tx DUT(.clk(clk), .nRST(nRST), .start(start), .data_in(data_in),
                  .tx(tx), .busy(busy), .done(done));

      test prog(.tx(tx), .busy(busy), .done(done), .start(start), .data_in(data_in));
endmodule

program test(
      input logic tx,
      input logic busy,
      input logic done,

      output logic start,
      output logic [7:0] data_in
);
      initial begin
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);

            if (!tx && !busy && !done) $display("In IDLE state, nRST logic works");
            
            @(posedge clk);
      
            //TEST 1: Sending a packet of data
            $display("TEST 1: Sending a packet of data");
            start = 1'b1;
            data_in = 8'b10101010;

            @(posedge clk);
            start = 1'b0;
            if (!tx && busy && !done) $display("Enters START state correctly");
            
            @(posedge clk);
            if (!tx && busy && !done) $display("Enters BIT0 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT1 state correctly");

            @(posedge clk);
            if (!tx && busy && !done) $display("Enters BIT2 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT3 state correctly");

            @(posedge clk);
            if (!tx && busy && !done) $display("Enters BIT4 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT5 state correctly");

            @(posedge clk);
            if (!tx && busy && !done) $display("Enters BIT6 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT7 state correctly");

            @(posedge clk);
            if (tx && busy && done) $display("Enters STOP state correctly");

            @(posedge clk);
            if (!tx && !busy && !done) $display("Returns to IDLE state correctly");

            @(posedge clk);
            @(posedge clk);


            //TEST 2: Trying to send new value in while busy
            $display("TEST 2: Trying to send new value in while busy");
            start = 1'b1;
            data_in = 8'b11111111;

            @(posedge clk);
            start = 1'b0;
            if (!tx && busy && !done) $display("Enters START state correctly");
            
            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT0 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT1 state correctly");

            @(posedge clk);
            start = 1'b1;
            data_in = 8'b00000000;
            if (tx && busy && !done) $display("Enters BIT2 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT3 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT4 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT5 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT6 state correctly");

            @(posedge clk);
            if (tx && busy && !done) $display("Enters BIT7 state correctly");

            @(posedge clk);
            if (tx && busy && done) $display("Enters STOP state correctly");

            @(posedge clk);
            if (!tx && !busy && !done) $display("Returns to IDLE state correctly");

            @(posedge clk);
            @(posedge clk);
            $finish;
      end

endprogram 
