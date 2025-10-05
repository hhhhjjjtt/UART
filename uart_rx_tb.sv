`timescale 1ns/1ps

module uart_rx_tb (
);
    reg i_serial;
    reg i_Clk;
    reg i_reset;
    wire [7:0] o_rx_data;
    wire o_rx_done;

    parameter BAUD_RATE = 115200;
    parameter CLK_HZ = 25000000;
    parameter CLK_PERIOD = 40; //25MHz=40ns
    parameter CLK_PER_BIT = CLK_HZ/BAUD_RATE;

    uart_rx #(
        .BAUD_RATE(BAUD_RATE), 
        .CLK_HZ(CLK_HZ)
    ) uart_rx_0(
        .i_serial(i_serial), 
        .i_Clk(i_Clk), 
        .i_reset(i_reset), 
        .o_rx_data(o_rx_data), 
        .o_rx_done(o_rx_done)
        );

    initial begin
        i_Clk = 0;
        forever begin
            #(CLK_PERIOD/2); // 25MHz Clock
            i_Clk = ~i_Clk;
        end
    end
        
    initial begin
        i_reset = 1;
        i_serial = 1;
        #(10*CLK_PERIOD);

        i_reset = 0;
        #(10*CLK_PERIOD);

        send_byte_rx (8'b10110010);

        #(2*CLK_PER_BIT*CLK_PERIOD);
        
        send_byte_rx (8'b10001000);

        #(2*CLK_PER_BIT*CLK_PERIOD);

        $finish(0);
    end
    
    task send_byte_rx (input [7:0] i_byte);
		begin
			i_serial = 0;
			#(CLK_PER_BIT*CLK_PERIOD);
			
			for (int k = 0; k < 8; k++) begin
                i_serial = i_byte[k];
                #(CLK_PER_BIT*CLK_PERIOD);
			end
			
			i_serial = 1;
			#(CLK_PER_BIT*CLK_PERIOD);
		end
	endtask

endmodule