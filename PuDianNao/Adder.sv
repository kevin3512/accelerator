module Adder#(parameter WIDTH = 32)(
    input[WIDTH-1:0]        hot_in[15:0],    //数据宽度可变，但是数组的宽度是硬件决定的，不可变
    input[WIDTH-1:0]        cold_in[15:0],
    input[1:0]              symbol,         //计算符号，2'b01 表示加， 2'b10表示 hot_in - cold_in ， 2‘b11表示 cold_in - hot_in
    output[WIDTH-1:0]       out[15:0]
);

reg[WIDTH-1:0]  reg_hot_in[15:0];
reg[WIDTH-1:0]  reg_cold_in[15:0];


always @ (*) begin : handle_add_symbol
    case(symbol)
        2'b01:
            begin
                for(integer i = 0; i < WIDTH; i = i + 1)begin
                    reg_hot_in[i] = hot_in[i];
                    reg_cold_in[i] = cold_in[i];
                end

            end
        2'b10:
            begin
                for(integer i = 0; i < WIDTH; i = i + 1)begin
                    reg_hot_in[i] = hot_in[i];
                    reg_cold_in[i] = -cold_in[i];
                end

            end
        2'b11:
            begin
                for(integer i = 0; i < WIDTH; i = i + 1)begin
                    reg_hot_in[i] = -hot_in[i];
                    reg_cold_in[i] = cold_in[i];
                end

            end
    endcase
end

adder_2 add0(reg_hot_in[0], reg_cold_in[0], out[0]);
adder_2 add1(reg_hot_in[1], reg_cold_in[1], out[1]);
adder_2 add2(reg_hot_in[2], reg_cold_in[2], out[2]);
adder_2 add3(reg_hot_in[3], reg_cold_in[3], out[3]);
adder_2 add4(reg_hot_in[4], reg_cold_in[4], out[4]);
adder_2 add5(reg_hot_in[5], reg_cold_in[5], out[5]);
adder_2 add6(reg_hot_in[6], reg_cold_in[6], out[6]);
adder_2 add7(reg_hot_in[7], reg_cold_in[7], out[7]);
adder_2 add8(reg_hot_in[8], reg_cold_in[8], out[8]);
adder_2 add9(reg_hot_in[9], reg_cold_in[9], out[9]);
adder_2 add10(reg_hot_in[10], reg_cold_in[10], out[10]);
adder_2 add11(reg_hot_in[11], reg_cold_in[11], out[11]);
adder_2 add12(reg_hot_in[12], reg_cold_in[12], out[12]);
adder_2 add13(reg_hot_in[13], reg_cold_in[13], out[13]);
adder_2 add14(reg_hot_in[14], reg_cold_in[14], out[14]);
adder_2 add15(reg_hot_in[15], reg_cold_in[15], out[15]);

endmodule