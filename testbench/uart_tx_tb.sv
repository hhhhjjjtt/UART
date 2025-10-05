`timescale 1ns/1ps

module uart_tx_tb (
);
    reg [7:0] data;
    reg start;
    reg i_Clk;
    reg reset;

    wire tx_serial;
    wire tx_done;
    wire busy;

    parameter BAUD_RATE = 115200;
    parameter CLK_HZ = 25000000;
    parameter CLK_PERIOD = 40; //25MHz=40ns
    parameter CLK_PER_BIT = CLK_HZ/BAUD_RATE;

    uart_tx #(
        .BAUD_RATE(BAUD_RATE), 
        .CLK_HZ(CLK_HZ)
    ) uart_tx_0(
        .i_data(data), 
        .i_Clk(i_Clk), 
        .i_start(start),
        .i_reset(reset),
        .o_tx_serial(tx_serial),
        .o_tx_done(tx_done),
        .o_busy(busy)
    );

    initial begin
        i_Clk = 0;
        forever begin
            #(CLK_PERIOD/2); // 25MHz Clock
            i_Clk = ~i_Clk;
        end
    end

    initial begin
        reset = 1;
        data = 8'b00000000;
        start = 0;
        #(10*CLK_PERIOD);

        reset = 0;
        #(10*CLK_PERIOD);

        send_byte_tx(8'b10010010);

        #(2*CLK_PER_BIT*CLK_PERIOD);

        send_byte_tx(8'b01011001);
        
        #(2*CLK_PER_BIT*CLK_PERIOD);

        $finish(0);
    end

    task send_byte_tx (input [7:0] i_byte);
		begin
            data = i_byte;
			start = 1;
            #(CLK_PERIOD);
            start = 0;
            #(10*CLK_PER_BIT*CLK_PERIOD);
		end
	endtask
    
endmodule