//指令解析模块
module ins_decode(
    input                clk,
    input                rst,
    input[4:0]           op_code,    //操作码
    input[15:0]          op_addr1,   //操作数的地址1,(读取地址)
    input[15:0]          op_addr2,   //操作者的地址2,(写入地址)
    //MLB 模块控制信号
    output               read_en,
    output               write_en,
    output[4:0]          sel_pe,
    //PE_array 模块控制信号
    output [2:0]         col_index,   
    output [7:0]         sel_cu,                                                     
    output [7:0]         sel_cu_go_back,   //each signal for one column  
    output [7:0]         sel_adder,           
    output [3:0]         is_save_cu_out,          
    output [1:0]         sum_row_pe,               
    output [1:0]         sum_column_pe,        
    //acc_out 模块控制信号
    output               sig,
    //sort_relu 模块控制信号
    output[31:0]         in,
    output[31:0]         index,
    output               asce,   
    output               is_start    
);

//保证输出可以放在左边
reg               read_en,
reg               write_en,
reg[4:0]          sel_pe,
//PE_array 模块控制信号
reg [2:0]         col_index,   
reg [7:0]         sel_cu,                                                     
reg [7:0]         sel_cu_go_back,   //each signal for one column  
reg [7:0]         sel_adder,           
reg [3:0]         is_save_cu_out,          
reg [1:0]         sum_row_pe,               
reg [1:0]         sum_column_pe,        
//acc_out 模块控制信号
reg               sig,
//sort_relu 模块控制信号
reg[31:0]         in,
reg[31:0]         index,
reg               asce,   
reg               is_start   

//PE 的计算状态
parameter PE_STATE_CU_SUB = 3'b001;         //计算cu减法结果
parameter PE_STATE_CU_ADD = 3'b010;         //计算cu加法结果
parameter PE_STATE_CU_MUL = 3'b011;         //计算cu乘法结果
parameter PE_STATE_CU_COM = 3'b100;         //计算cu比较结果
parameter PE_STATE_BACK_IN = 3'b101;        //cu数据写回in
parameter PE_STATE_BACK_PAR = 3'b110;       //cu数据写回par
parameter PE_STATE_ADDER_TREE = 3'b111;     //cu结果经过加法树

reg[2:0]         pe_state;

initial begin:initial_var
    sel_pe = 5'b0;
    col_index = 3'b0;
    pe_state = PE_STATE_CU;
end


always @ (posedge clk or negedge rst)begin: op_code_decoder
    if(!rst)begin
        
    end else begin
        case(op_code)
            5'b00001 :begin   //写数据到MLB
                if(sel_pe >= 32)begin
                    sel_pe = 5'b0;
                end else begin
                    sel_pe = sel_pe + 1;
                    write_en = 1;
                end
            end
            5'b00010 :begin   //从MLB读数据到PE_array
                if(sel_pe >= 32)begin
                    sel_pe = 5'b0;
                end else begin
                    sel_pe = sel_pe + 1;
                    read_en = 1;
                end
            end
            5'b00011:begin  //PE array 计算两个向量之间的距离
                if(col_index >= 8)begin
                    col_index = 3'b0;
                end else begin
                    case(op_code)
                        3'b001:begin   //distance calcalation
                            sum_row_pe = 2'b10;    //row select sum of row PE  
                            sum_column_pe = 2'b10;  //column select sum of column PE
                            
                        end
                    
                    endcase


                    case(pe_state):   // 所有PE状态的部分操作信号(sel_cu、is_save_cu_out、sel_cu_go_back、sel_adder)
                        PE_STATE_CU_SUB:begin
                            sel_cu = 8'b00000000;   //subtraction
                            is_save_cu_out = 4'b0000;  // don't save cu result
                        end
                        PE_STATE_CU_ADD:begin
                            sel_cu = 8'10101010;   //add
                            is_save_cu_out = 4'b0000;  // don't save cu result
                        end
                        PE_STATE_CU_MUL:begin
                            sel_cu = 8'11111111;   //multiplication
                            is_save_cu_out = 4'b0000;  // don't save cu result
                        end
                        PE_STATE_CU_COM:begin
                            sel_cu = 8'01010101;   //compare
                            is_save_cu_out = 4'b0000;  // don't save cu result
                        end
                        PE_STATE_BACK_PAR:begin
                            is_save_cu_out = 4'b1111;     // save cu result first
                            sel_cu_go_back = 8'b01010101;  // cu result go to par
                        end
                        PE_STATE_BACK_IN:begin
                            is_save_cu_out = 4'b1111;     // save cu result first
                            sel_cu_go_back = 8'b11111111;  // cu result go to in
                        end
                        PE_STATE_ADDER_TREE:begin
                            sel_adder = 8'b10101010;
                            col_index = col_index + 1;    //end of caculation , so col_index plus one
                        end
                    endcase 
                end
            end
        endcase
    end
end

endmodule