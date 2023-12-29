//2输入的加法器
module adder_2 #(parameter WIDTH = 16)(
    input[WIDTH-1:0]         a,
    input[WIDTH-1:0]         b,
    output[WIDTH-1:0]        out
);
    assign out = a + b;
endmodule