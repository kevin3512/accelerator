//2输入的加法器
module adder_2 (
    input[31:0]         a,
    input[31:0]         b,
    output reg[31:0]        out
);

always_comb begin : cal_add
    if(a !== 32'hxxxx_xxxx && b !== 32'hxxxx_xxxx)begin
        out = a + b;
    end else if(a !== 32'hxxxx_xxxx)begin
        out = a;
    end else begin
        out = b;
    end
end
endmodule