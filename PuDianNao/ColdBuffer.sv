module ColdBuffer (
    input               clk,
    input               rst,
    input[31:0]         in[255:0],  //read width = u * f * 16 bit  , 其中u = 16 ， f = 16 , u 表示MLU的数量，f表示每个MLU能够处理的dimension或者是feature
    input[4:0]          idx,        // 16 KB = 32 * 256 * 16 bit，因此下标有5位
    input               read_en,    //读使能
    input               write_en,   //写使能
    output[31:0]        out[255:0]
);

reg[31:0]       buff[31:0][255:0];   //Colcdbuff可以保存32轮16个MLU的输入
reg[31:0]       out[255:0];

always @ (posedge clk or negedge rst)begin: save_mem_data
    integer i, j;
    if(!rst)begin

    end else begin
        if(write_en)begin
            for(i = 0; i < 256; i = i + 1)begin
                buff[idx][i] = in[i];
            end
        end else if(read_en) begin
            for(j = 0; j < 256; j = j + 1)begin
                out[j] = buff[idx][j];
            end
        end
    end
end

endmodule