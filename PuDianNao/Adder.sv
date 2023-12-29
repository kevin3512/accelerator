module Adder#(parameter WIDTH = 16)(
    input[WIDTH-1:0]        hot_in[15:0],    //数据宽度可变，但是数组的宽度是硬件决定的，不可变
    input[WIDTH-1:0]        cold_in[15:0],
    output[WIDTH-1:0]       out[15:0]
);

adder_2 add0(hot_in[0], cold_in[0], out[0]);
adder_2 add1(hot_in[1], cold_in[1], out[1]);
adder_2 add2(hot_in[2], cold_in[2], out[2]);
adder_2 add3(hot_in[3], cold_in[3], out[3]);
adder_2 add4(hot_in[4], cold_in[4], out[4]);
adder_2 add5(hot_in[5], cold_in[5], out[5]);
adder_2 add6(hot_in[6], cold_in[6], out[6]);
adder_2 add7(hot_in[7], cold_in[7], out[7]);
adder_2 add8(hot_in[8], cold_in[8], out[8]);
adder_2 add9(hot_in[9], cold_in[9], out[9]);
adder_2 add10(hot_in[10], cold_in[10], out[10]);
adder_2 add11(hot_in[11], cold_in[11], out[11]);
adder_2 add12(hot_in[12], cold_in[12], out[12]);
adder_2 add13(hot_in[13], cold_in[13], out[13]);
adder_2 add14(hot_in[14], cold_in[14], out[14]);
adder_2 add15(hot_in[15], cold_in[15], out[15]);

endmodule