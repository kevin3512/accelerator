//Multiple Level Buffer , LENGTH 是指整个buffer的长度，8是指PE array共有8列，64是指一组并行计算的PEs需要多少个数据
module MLB (
    input               clk,
    input               rst,
    input[31:0]         in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
    input               read_en,    //读使能
    input               write_en,   //写使能
    input[4:0]          sel_pe,    //对应PE_array中的PE，一个输出就是一个PE的数据
    output[31:0]        out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15
);

reg[31:0]       buff[31:0][15:0];
reg[31:0]       out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;

always @ (posedge clk or negedge rst)begin: save_mem_data
    integer i, j;
    if(!rst)begin

    end else begin
        if(read_en)begin
            out0 = buff[sel_pe][0];
            out1 = buff[sel_pe][1];
            out2 = buff[sel_pe][2];
            out3 = buff[sel_pe][3];
            out4 = buff[sel_pe][4];
            out5 = buff[sel_pe][5];
            out6 = buff[sel_pe][6];
            out7 = buff[sel_pe][7];
            out8 = buff[sel_pe][8];
            out9 = buff[sel_pe][9];
            out10 = buff[sel_pe][10];
            out11 = buff[sel_pe][11];
            out12 = buff[sel_pe][12];
            out13 = buff[sel_pe][13];
            out14 = buff[sel_pe][14];
            out15 = buff[sel_pe][15];
        end else if(write_en) begin
            buff[sel_pe][0] = in0;
            buff[sel_pe][1] = in1;
            buff[sel_pe][2] = in2;
            buff[sel_pe][3] = in3;
            buff[sel_pe][4] = in4;
            buff[sel_pe][5] = in5;
            buff[sel_pe][6] = in6;
            buff[sel_pe][7] = in7;
            buff[sel_pe][8] = in8;
            buff[sel_pe][9] = in9;
            buff[sel_pe][10] = in10;
            buff[sel_pe][11] = in11;
            buff[sel_pe][12] = in12;
            buff[sel_pe][13] = in13;
            buff[sel_pe][14] = in14;
            buff[sel_pe][15] = in15;
        end
    end
end

endmodule