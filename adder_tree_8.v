//8输入的加法器树
module adder_tree_8(
    input[31:0]     a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,
    output[31:0]    out
);

//第一层加法树的部分和
wire[31:0] ps0, ps1, ps2, ps3, ps4, ps5, ps6, ps7;
//第二层加法树的部分和
wire[31:0] ps2_0, ps2_1, ps2_2, ps2_3;  
//第三层加法树的部分和
wire[31:0] ps3_0, ps3_1;


//第一层加法树
adder_2 u1_0(a0, a1, ps0);
adder_2 u1_1(a2, a3, ps1);
adder_2 u1_2(a4, a5, ps2);
adder_2 u1_3(a6, a7, ps3);
adder_2 u1_4(a8, a9, ps4);
adder_2 u1_5(a10, a11, ps5);
adder_2 u1_6(a12, a13, ps6);
adder_2 u1_7(a14, a15, ps7);

//第二层加法树
adder_2 u2_0(ps0, ps1, ps2_0);
adder_2 u2_1(ps2, ps3, ps2_1);
adder_2 u2_2(ps4, ps5, ps2_2);
adder_2 u2_3(ps6, ps7, ps2_3);

//第三层加法树
adder_2 u3_0(ps2_0, ps2_1, ps3_0);
adder_2 u3_1(ps2_2, ps2_3, ps3_1);

//第四层结果输出
adder_2 u4(ps3_0, ps3_1, out);

endmodule


//testbench of adder_tree_8
`timescale 1ns/1ns
module adder_tree_8_tb;
    reg[31:0]         A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15;
    wire[31:0]        Out;

    adder_tree_8 adder_tree_8(.a0(A0), .a1(A1), .a2(A2), .a3(A3), .a4(A4), .a5(A5), .a6(A6), .a7(A7),
                                    .a8(A8), .a9(A9), .a10(A10), .a11(A11), .a12(A12), .a13(A13), .a14(A14), .a15(A15), 
                                        .out(Out)
    );
    initial begin 
        #5     A0<=32'h1; A8<=32'h9;
        #5     A1<=32'h2; A9<=32'ha;
        #5     A2<=32'h3; A10<=32'hb;
        #5     A3<=32'h4; A11<=32'hc;
        #5     A4<=32'h5; A12<=32'hd;
        #5     A5<=32'h6; A13<=32'he;
        #5     A6<=32'h7; A14<=32'hf;
        #5     A7<=32'h8; A15<=32'h10;
    end
endmodule