module uart_tx #(
    parameter BAUD_RATE = 115200,
    parameter CLK_HZ = 25000000
) (
    input [7:0] i_data,
    input i_Clk,
    input i_reset,
    input i_start,
    output o_tx_serial,
    output o_tx_done,
    output o_busy
);
    parameter CLK_PER_BIT = CLK_HZ/BAUD_RATE;

    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [1:0] state;
    reg r_tx_serial;
    reg r_tx_done;
    reg r_busy;
    reg [2:0] data_bit_counter;
    reg [31:0] clk_bit_counter;
    reg [7:0] r_data;

    wire bit_end;
    assign bit_end = (clk_bit_counter == CLK_PER_BIT - 1); // for debug

    always @(posedge i_Clk or posedge i_reset) begin
        if (i_reset) begin
            state <= IDLE;
            r_tx_serial <= 1;
            r_tx_done <= 0;
            data_bit_counter <= 0;
            clk_bit_counter <= 0;
            r_data <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    r_tx_serial <= 1;
                    r_tx_done <= 0;
                    data_bit_counter <= 0;
                    clk_bit_counter <= 0;
                    if (i_start && ~o_busy) begin
                        r_data <= i_data;
                        state <= START;
                    end
                end 
                START: begin
                    r_tx_serial <= 0;
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        state <= DATA;
                    end
                end
                DATA: begin
                    r_tx_serial <= r_data[data_bit_counter];
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        data_bit_counter <= data_bit_counter + 1;
                        if (data_bit_counter == 7) begin
                            state <= STOP;
                            data_bit_counter <= 0;
                        end
                    end
                end
                STOP: begin
                    r_tx_serial <= 1;
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        r_tx_done <= 1;
                        state <= IDLE;
                    end
                end
                default: 
                    state <= IDLE;
            endcase
        end
    end
    
    assign o_tx_serial = r_tx_serial;
    assign o_tx_done = r_tx_done;
    assign o_busy = (state != IDLE);

endmodule