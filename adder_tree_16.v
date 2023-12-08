//16输入的加法器树
module adder_tree_16(
    input[31:0]         a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,
    input[31:0]         b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,
    output[31:0]    out
);

//第一层加法树的部分和
wire[31:0] ps0, ps1, ps2, ps3, ps4, ps5, ps6, ps7,ps8, ps9, ps10, ps11, ps12, ps13, ps14, ps15;  
//第二层加法树的部分和
wire[31:0] ps2_0, ps2_1, ps2_2, ps2_3, ps2_4, ps2_5, ps2_6, ps2_7;  
//第三层加法树的部分和
wire[31:0] ps3_0, ps3_1, ps3_2, ps3_3;
//第四层加法树的部分和
wire[31:0] ps4_0, ps4_1;

//第一层加法树
adder_2 u1_0(a0, b0, ps0);
adder_2 u1_1(a1, b1, ps1);
adder_2 u1_2(a2, b2, ps2);
adder_2 u1_3(a3, b3, ps3);
adder_2 u1_4(a4, b4, ps4);
adder_2 u1_5(a5, b5, ps5);
adder_2 u1_6(a6, b6, ps6);
adder_2 u1_7(a7, b7, ps7);
adder_2 u1_8(a8, b8, ps8);
adder_2 u1_9(a9, b9, ps9);
adder_2 u1_10(a10, b10, ps10);
adder_2 u1_11(a11, b11, ps11);
adder_2 u1_12(a12, b12, ps12);
adder_2 u1_13(a13, b13, ps13);
adder_2 u1_14(a14, b14, ps14);
adder_2 u1_15(a15, b15, ps15);

//第二层加法树
adder_2 u2_0(ps0, ps1, ps2_0);
adder_2 u2_1(ps2, ps3, ps2_1);
adder_2 u2_2(ps4, ps5, ps2_2);
adder_2 u2_3(ps6, ps7, ps2_3);
adder_2 u2_4(ps8, ps9, ps2_4);
adder_2 u2_5(ps10, ps11, ps2_5);
adder_2 u2_6(ps12, ps13, ps2_6);
adder_2 u2_7(ps14, ps15, ps2_7);

//第三层加法树
adder_2 u3_0(ps2_0, ps2_1, ps3_0);
adder_2 u3_1(ps2_2, ps2_3, ps3_1);
adder_2 u3_2(ps2_4, ps2_5, ps3_2);
adder_2 u3_3(ps2_6, ps2_7, ps3_3);

//第四层加法树
adder_2 u4_0(ps3_0, ps3_1, ps4_0);
adder_2 u4_1(ps3_2, ps3_3, ps4_1);

//第五层结果输出
adder_2 u5(ps4_0, ps4_1, out);

endmodule


//testbench of adder_tree_16
`timescale 1ns/1ns
module adder_tree_16_tb;
    reg[31:0]         A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15;
    reg[31:0]         B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10,B11,B12,B13,B14,B15;
    wire[31:0]        Out;

    adder_tree_16 adder_tree_16(.a0(A0), .a1(A1), .a2(A2), .a3(A3), .a4(A4), .a5(A5), .a6(A6), .a7(A7), .a8(A8), .a9(A9), .a10(A10), .a11(A11), .a12(A12), .a13(A13), .a14(A14), .a15(A15),
                                    .b0(B0), .b1(B1), .b2(B2), .b3(B3), .b4(B4), .b5(B5), .b6(B6), .b7(B7), .b8(B8), .b9(B9), .b10(B10), .b11(B11), .b12(B12), .b13(B13), .b14(B14), .b15(B15),
                                        .out(Out)
    );
    initial begin 
        #5     A0<=32'h1; B0<=32'h2;
        #5     A1<=32'h1; B1<=32'h2;
        #5     A2<=32'h1; B2<=32'h2;
        #5     A3<=32'h1; B3<=32'h2;
        #5     A4<=32'h1; B4<=32'h2;
        #5     A5<=32'h1; B5<=32'h2;
        #5     A6<=32'h1; B6<=32'h2;
        #5     A7<=32'h1; B7<=32'h2;
        #5     A8<=32'h1; B8<=32'h2;
        #5     A9<=32'h1; B9<=32'h2;
        #5     A10<=32'h1; B10<=32'h2;
        #5     A11<=32'h1; B11<=32'h2;
        #5     A12<=32'h1; B12<=32'h2;
        #5     A13<=32'h1; B13<=32'h2;
        #5     A14<=32'h1; B14<=32'h2;
        #5     A15<=32'h1; B15<=32'h2;
        #5     $stop;
    end
endmodule