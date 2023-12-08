//2输入的加法器
module adder_2(
    input[31:0]         a,
    input[31:0]         b,
    output[31:0]    out
);
    assign out = a + b;
endmodule