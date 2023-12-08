//多路选择器
module multiple_selector(
    input[31:0]         In,
    input[1:0]          Sel,
    output reg[31:0]        Out1,
    output reg[31:0]        Out2,
    output reg[31:0]        Out3,
    output reg[31:0]        Out4
);
    always @(Sel or In)
        case(Sel)
            2'b00:       
                Out1 = In ; 
            2'b01:       
                Out2 = In ;
            2'b10:       
                Out3 = In ;
            2'b11:       
                Out4 = In ;
        endcase
endmodule

//testbench of multiple_selector
`timescale 1ns/1ns
module multiple_selector_tb;
    reg[31:0]               in;
    reg[1:0]                sel;
    wire[31:0]              out1,out2,out3,out4;

    multiple_selector multiple_selector(.In(in), .Sel(sel), .Out1(out1), .Out2(out2), .Out3(out3), .Out4(out4));
    initial begin
                sel<=2'b11; in<=32'hFFFF; 
        #10     sel<=2'b01; in<=32'h0201; 
        #10     sel<=2'b10; in<=32'h3F01; 
        #10     sel<=2'b00; in<=32'hF001; 
    end

endmodule