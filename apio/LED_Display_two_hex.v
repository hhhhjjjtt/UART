module LED_Display_two_hex (
    input [7:0] i_data,
    output a1,
    output b1,
    output c1,
    output d1,
    output e1,
    output f1,
    output g1,
    output a2,
    output b2,
    output c2,
    output d2,
    output e2,
    output f2,
    output g2
);

    wire [3:0] r_data_upper;
    wire [3:0] r_data_lower;

    assign r_data_upper = i_data[7:4];
    assign r_data_lower = i_data[3:0];

    wire [6:0] led_digit_data_upper;
    wire [6:0] led_digit_data_lower;

    num_2_led num_2_led_0(r_data_upper, led_digit_data_upper);
    num_2_led num_2_led_1(r_data_lower, led_digit_data_lower);

    assign a1 = led_digit_data_upper[0];
    assign b1 = led_digit_data_upper[1];
    assign c1 = led_digit_data_upper[2];
    assign d1 = led_digit_data_upper[3];
    assign e1 = led_digit_data_upper[4];
    assign f1 = led_digit_data_upper[5];
    assign g1 = led_digit_data_upper[6];

    assign a2 = led_digit_data_lower[0];
    assign b2 = led_digit_data_lower[1];
    assign c2 = led_digit_data_lower[2];
    assign d2 = led_digit_data_lower[3];
    assign e2 = led_digit_data_lower[4];
    assign f2 = led_digit_data_lower[5];
    assign g2 = led_digit_data_lower[6];

endmodule



module num_2_led (
    input [3:0] i_num,
    output reg [6:0] led_digit
);

always @(*) begin
    case (i_num)
        4'h0: led_digit = 7'b1000000;
        4'h1: led_digit = 7'b1111001;
        4'h2: led_digit = 7'b0100100;
        4'h3: led_digit = 7'b0110000;
        4'h4: led_digit = 7'b0011001;
        4'h5: led_digit = 7'b0010010;
        4'h6: led_digit = 7'b0000010;
        4'h7: led_digit = 7'b1111000;
        4'h8: led_digit = 7'b0000000;
        4'h9: led_digit = 7'b0010000;
        4'hA: led_digit = 7'b0001000;
        4'hB: led_digit = 7'b0000011;
        4'hC: led_digit = 7'b1000110;
        4'hD: led_digit = 7'b0100001;
        4'hE: led_digit = 7'b0000110;
        4'hF: led_digit = 7'b0001110;
        default: led_digit = 7'b1111111;
    endcase
end
    
endmodule