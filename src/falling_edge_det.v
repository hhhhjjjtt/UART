module falling_edge_det (
    input i_sig,
    input i_Clk,
    input i_reset,
    output reg o_is_fe,
    output reg o_sig
);
    reg [1:0] r_in;

    always @(posedge i_Clk or posedge i_reset) begin
        if (i_reset) begin
            r_in <= 2'b0;
            o_is_fe <= 0;
            o_sig   <= 1'b0;
        end
        else begin
            o_sig <= r_in[1];
            r_in[1] <= r_in[0];
            r_in[0] <= i_sig;
            if (r_in[1] & ~r_in[0]) 
                o_is_fe <= 1;
            else
                o_is_fe <= 0;
        end
    end
endmodule