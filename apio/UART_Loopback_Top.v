module UART_Loopback_Top (
    input i_UART_RX,
    input i_Clk,
    input i_Switch_1, // i_reset
    output o_UART_TX,
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G,
    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G
);

    reg [7:0] r_rx_data;
    wire rx_done;

    uart_rx #(
        .BAUD_RATE(115200), 
        .CLK_HZ(25000000)
    ) uart_rx_0 (
        .i_serial(i_UART_RX),
        .i_Clk(i_Clk),
        .i_reset(i_Switch_1),
        .o_rx_data(r_rx_data),
        .o_rx_done(rx_done)
    );

    reg [7:0] data;
    reg start;
    wire busy;
    wire o_tx_serial;

    assign o_UART_TX = busy ? o_tx_serial : 1;

    uart_tx #(
        .BAUD_RATE(115200), 
        .CLK_HZ(25000000)
    ) uart_tx_0 (
        .i_data(data),
        .i_Clk(i_Clk),
        .i_reset(i_Switch_1),
        .i_start(start),
        .o_tx_serial(o_tx_serial),
        .o_tx_done(),
        .o_busy(busy)
    );

    LED_Display_two_hex LED_Display_two_hex_0(
        .i_data(data), 
        .a1(o_Segment1_A),
        .b1(o_Segment1_B),
        .c1(o_Segment1_C),
        .d1(o_Segment1_D),
        .e1(o_Segment1_E),
        .f1(o_Segment1_F),
        .g1(o_Segment1_G),
        .a2(o_Segment2_A),
        .b2(o_Segment2_B),
        .c2(o_Segment2_C),
        .d2(o_Segment2_D),
        .e2(o_Segment2_E),
        .f2(o_Segment2_F),
        .g2(o_Segment2_G)
    );

    always @(posedge i_Clk or posedge i_Switch_1) begin
        if (i_Switch_1) begin
            data <= 0;
            start <= 0;
        end
        else begin
            if (rx_done) begin
                data <= r_rx_data;
                start <= 1;
            end
            else begin
                data <= data;
                start <= 0;
            end
        end        
    end
    
endmodule 