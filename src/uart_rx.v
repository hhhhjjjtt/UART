module uart_rx #(
    parameter BAUD_RATE = 115200,
    parameter CLK_HZ = 25000000
) (
    input i_serial,
    input i_Clk,
    input i_reset,
    output [7:0] o_rx_data,
    output o_rx_done
);
    parameter CLK_PER_BIT = CLK_HZ/BAUD_RATE;
    parameter CLK_MID = ((CLK_PER_BIT-1)/2);

    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [7:0] r_rx_data;
    reg r_rx_done;
    reg [1:0] state;
    reg [2:0] data_bit_counter;
    reg [31:0] clk_bit_counter;
    reg bit_data;

    wire is_fe;
    wire r_serial;

    falling_edge_det falling_edge_det_0(i_serial, i_Clk, i_reset, is_fe, r_serial);

    wire bit_end;
    assign bit_end = (clk_bit_counter == CLK_PER_BIT - 1); // for debug

    always @(posedge i_Clk or posedge i_reset) begin
        if (i_reset) begin
            r_rx_done <= 0;
            r_rx_data <= 8'b00000000;
            data_bit_counter <= 3'b000;
            clk_bit_counter <= 0;
            bit_data <= 0;
            state <= IDLE;
        end
        else begin
            // r_rx_done <= 0;
            case (state)
                IDLE: begin
                    r_rx_done <= 0;
                    data_bit_counter <= 3'b000;
                    clk_bit_counter <= 0;
                    bit_data <= 0;
                    if (is_fe)
                        state <= START;
                end
                START: begin
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_MID) begin
                        bit_data <= r_serial;
                    end
                    else if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        if (bit_data == 0) begin
                            state <= DATA;
                        end
                        else 
                            state <= IDLE;
                    end 
                end
                DATA: begin
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_MID) begin
                        bit_data <= r_serial;
                    end
                    else if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        r_rx_data[data_bit_counter] <= bit_data;
                        data_bit_counter <= data_bit_counter + 1;
                        if (data_bit_counter == 7) begin
                            state <= STOP;
                            data_bit_counter <= 0;
                        end
                    end
                end
                STOP: begin
                    clk_bit_counter <= clk_bit_counter + 1;
                    if (clk_bit_counter == CLK_PER_BIT - 1) begin
                        clk_bit_counter <= 0;
                        state <= IDLE;
                        r_rx_done <= 1;
                    end
                end
                default: 
                    state <= IDLE;
            endcase
        end
    end

    assign o_rx_data = r_rx_data;
    assign o_rx_done = r_rx_done;
endmodule