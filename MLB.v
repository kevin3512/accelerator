//Multiple Level Buffer , LENGTH 是指整个buffer的长度，8是指PE array共有8列，64是指一组并行计算的PEs需要多少个数据
module MLB (
    input               clk,
    input               rst,
    input[31:0]         in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
    input               read_en,    //读使能
    input               write_en,   //写使能
    input[1:0]          sub_tile_idx,      //tile中sub tile 分块的下标 ， 数值上表示第几次给PE array阵列赋值
    input[2:0]          unit_tile_idx,     //subtile种unit tile 分块的下标，数值上和PE array的column_index相同
    output[31:0]        out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15
);

reg[31:0]       buff[31:0][15:0];
reg[31:0]       out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15;
wire[4:0]       idx;   //MLB内部总共32个unit tile的分块下标

assign idx = sub_tile_idx * 8 + unit_tile_idx;

always @ (posedge clk or negedge rst)begin: save_mem_data
    integer i, j;
    if(!rst)begin

    end else begin
        if(read_en)begin
            out0 = buff[idx][0];
            out1 = buff[idx][1];
            out2 = buff[idx][2];
            out3 = buff[idx][3];
            out4 = buff[idx][4];
            out5 = buff[idx][5];
            out6 = buff[idx][6];
            out7 = buff[idx][7];
            out8 = buff[idx][8];
            out9 = buff[idx][9];
            out10 = buff[idx][10];
            out11 = buff[idx][11];
            out12 = buff[idx][12];
            out13 = buff[idx][13];
            out14 = buff[idx][14];
            out15 = buff[idx][15];
        end else if(write_en) begin
            buff[idx][0] = in0;
            buff[idx][1] = in1;
            buff[idx][2] = in2;
            buff[idx][3] = in3;
            buff[idx][4] = in4;
            buff[idx][5] = in5;
            buff[idx][6] = in6;
            buff[idx][7] = in7;
            buff[idx][8] = in8;
            buff[idx][9] = in9;
            buff[idx][10] = in10;
            buff[idx][11] = in11;
            buff[idx][12] = in12;
            buff[idx][13] = in13;
            buff[idx][14] = in14;
            buff[idx][15] = in15;
        end
    end
end

endmodule