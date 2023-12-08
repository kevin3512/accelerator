//testbench of multiple selector
`timescale 1ns/1ns
module computer_unit_tb;
    reg                 clk;
    reg                 rst;
    reg[31:0]           in_data;
    reg[31:0]           in_par;
    reg[31:0]           sel;
    wire[31:0]          out;

    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA();
        clk = 0;
        rst = 1;
        forever begin
            #1 clk = ~clk;
        end
    end

    computer_unit computer_unit(.clk(clk), .rst(rst),.Input_data(in_data), .Input_par(in_par), .Sel(sel), .Out(out));
    initial begin
                //减法操作 
                sel<=2'b00; in_data<=32'h00888888; in_par<=32'h2;
                //比较器   
        #10     sel<=2'b01; in_data<=32'h00FFFFFF; in_par<=32'h01000000;
                //加法器   
        #10     sel<=2'b10; in_data<=32'h00FFFFFF; in_par<=32'h00000001;
                //乘法器   
        #10     sel<=2'b11; in_data<=32'h00444444; in_par<=32'h2;
    end

endmodule