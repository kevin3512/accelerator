//8输入的加法器树
module Adder_tree #(parameter WIDTH = 32)(
    input[WIDTH-1:0]        in[15:0],
    output[WIDTH-1:0]       out
);

//第一层加法树的部分和
wire[WIDTH-1:0] ps0, ps1, ps2, ps3, ps4, ps5, ps6, ps7;
//第二层加法树的部分和
wire[WIDTH-1:0] ps2_0, ps2_1, ps2_2, ps2_3;  
//第三层加法树的部分和
wire[WIDTH-1:0] ps3_0, ps3_1;


//第一层加法树
adder_2 #(WIDTH) u1_0(in[0], in[1], ps0);
adder_2 #(WIDTH) u1_1(in[2], in[3], ps1);
adder_2 #(WIDTH) u1_2(in[4], in[5], ps2);
adder_2 #(WIDTH) u1_3(in[6], in[7], ps3);
adder_2 #(WIDTH) u1_4(in[8], in[9], ps4);
adder_2 #(WIDTH) u1_5(in[10], in[11], ps5);
adder_2 #(WIDTH) u1_6(in[12], in[13], ps6);
adder_2 #(WIDTH) u1_7(in[14], in[15], ps7);

//第二层加法树
adder_2 #(WIDTH)u2_0(ps0, ps1, ps2_0);
adder_2 #(WIDTH)u2_1(ps2, ps3, ps2_1);
adder_2 #(WIDTH)u2_2(ps4, ps5, ps2_2);
adder_2 #(WIDTH)u2_3(ps6, ps7, ps2_3);

//第三层加法树
adder_2 #(WIDTH)u3_0(ps2_0, ps2_1, ps3_0);
adder_2 #(WIDTH)u3_1(ps2_2, ps2_3, ps3_1);

//第四层结果输出
adder_2 #(WIDTH)u4(ps3_0, ps3_1, out);

endmodule