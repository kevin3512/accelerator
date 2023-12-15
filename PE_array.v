module PE_array(
    input               clk,                     // clock signal
    input               rst,                     // reset signal 
    input [31:0]        In0_0, In0_1, In0_2, In0_3, In0_4, In0_5, In0_6, In0_7, In0_8, In0_9, In0_10, In0_11, In0_12, In0_13, In0_14, In0_15,          
    input [31:0]        Par0_0, Par0_1, Par0_2, Par0_3, Par0_4, Par0_5, Par0_6, Par0_7, Par0_8, Par0_9, Par0_10, Par0_11, Par0_12, Par0_13, Par0_14, Par0_15,    

    input [31:0]        In1_0, In1_1, In1_2, In1_3, In1_4, In1_5, In1_6, In1_7, In1_8, In1_9, In1_10, In1_11, In1_12, In1_13, In1_14, In1_15,          
    input [31:0]        Par1_0, Par1_1, Par1_2, Par1_3, Par1_4, Par1_5, Par1_6, Par1_7, Par1_8, Par1_9, Par1_10, Par1_11, Par1_12, Par1_13, Par1_14, Par1_15,     

    input [31:0]        In2_0, In2_1, In2_2, In2_3, In2_4, In2_5, In2_6, In2_7, In2_8, In2_9, In2_10, In2_11, In2_12, In2_13, In2_14, In2_15,          
    input [31:0]        Par2_0, Par2_1, Par2_2, Par2_3, Par2_4, Par2_5, Par2_6, Par2_7, Par2_8, Par2_9, Par2_10, Par2_11, Par2_12, Par2_13, Par2_14, Par2_15,     

    input [31:0]        In3_0, In3_1, In3_2, In3_3, In3_4, In3_5, In3_6, In3_7, In3_8, In3_9, In3_10, In3_11, In3_12, In3_13, In3_14, In3_15,          
    input [31:0]        Par3_0, Par3_1, Par3_2, Par3_3, Par3_4, Par3_5, Par3_6, Par3_7, Par3_8, Par3_9, Par3_10, Par3_11, Par3_12, Par3_13, Par3_14, Par3_15,     
    input [2:0]         Col_index,   
                        //each signal for one column           
    input [7:0]         Sel_cu,                                                     
    input [7:0]         Sel_cu_go_back,   //each signal for one column  
    input [7:0]         Sel_adder,           
    input [3:0]         Is_save_cu_out,
    input               Clear_reg,     //clear all reg value          
    
                        //control output model(one row PE or one column PE or one PE or all PE)
    input [1:0]         Sum_row_pe,               
    input [1:0]         Sum_column_pe,           

    output [31:0]       Scalar_output0, Scalar_output1, Scalar_output2, Scalar_output3,  
    output [31:0]       Out0_0, Out0_1, Out0_2, Out0_3, Out0_4, Out0_5, Out0_6, Out0_7, Out0_8, Out0_9, Out0_10, Out0_11, Out0_12, Out0_13, Out0_14, Out0_15,
    output [31:0]       Out1_0, Out1_1, Out1_2, Out1_3, Out1_4, Out1_5, Out1_6, Out1_7, Out1_8, Out1_9, Out1_10, Out1_11, Out1_12, Out1_13, Out1_14, Out1_15,
    output [31:0]       Out2_0, Out2_1, Out2_2, Out2_3, Out2_4, Out2_5, Out2_6, Out2_7, Out2_8, Out2_9, Out2_10, Out2_11, Out2_12, Out2_13, Out2_14, Out2_15,
    output [31:0]       Out3_0, Out3_1, Out3_2, Out3_3, Out3_4, Out3_5, Out3_6, Out3_7, Out3_8, Out3_9, Out3_10, Out3_11, Out3_12, Out3_13, Out3_14, Out3_15
);

reg[31:0] all_in[7:0][63:0];
reg[31:0] all_par[7:0][63:0];

// result of row PE for array ， 行求和的时候不直接输出，保存到这里
reg[31:0] row_pe_array0[15:0]; 
reg[31:0] row_pe_array1[15:0]; 
reg[31:0] row_pe_array2[15:0]; 
reg[31:0] row_pe_array3[15:0]; 
// result of column PE for scalar
reg[31:0] row_pe_scalar[3:0];
// 一列PE的标量输出
wire[31:0] pe_scalar_output[31:0];
reg[31:0] pre_pe_scalar_output[31:0];
// 一列PE的向量输出
wire[31:0] pe_array_output[7:0][63:0];
reg[31:0] pre_pe_array_output[7:0][63:0];

//每个数组保存的是每一列PE的信号
reg[7:0]  all_sel_cu[7:0];
reg[7:0]  all_sel_cu_go_back[7:0];
reg[7:0]  all_sel_adder[7:0];
reg[3:0]  all_is_save_cu_out[7:0];

reg[31:0] reg_scalar_output[3:0];
// reg array_output0
reg[31:0] reg_array_output0[15:0];
// reg array_output1
reg[31:0] reg_array_output1[15:0];
// reg array_output2
reg[31:0] reg_array_output2[15:0];
// reg array_output3
reg[31:0] reg_array_output3[15:0];
// save currently output PE's row number
integer   cur_row_num;
// save currently output PE's column number
integer   cur_col_num; 
reg[4:0]  k;

reg[2:0]  pre_col_index;  //save last col_index value

// reg variable initialization
initial begin:initial_var
    integer i, j;
    for (j = 0; j < 16; j = j + 1) begin
            row_pe_array0[j] = 32'h0;
            row_pe_array1[j] = 32'h0;
            row_pe_array2[j] = 32'h0;
            row_pe_array3[j] = 32'h0;
    end
    for (i = 0; i < 4; i = i + 1) begin
        row_pe_scalar[i] = 32'h0;
        // reg_scalar_output[i] = 32'h0;
    end

    for (i = 0; i < 16; i = i + 1) begin
        reg_array_output0[i] = 32'h0;
        reg_array_output1[i] = 32'h0;
        reg_array_output2[i] = 32'h0;
        reg_array_output3[i] = 32'h0;
    end

    for (i = 0; i < 32; i = i + 1) begin
        pre_pe_scalar_output[i] = 32'h0;
    end
    for(i = 0; i < 8; i = i + 1)begin
        for(j = 0; j < 64; j = j + 1)begin
            pre_pe_array_output[i][j] = 32'h0;
        end
    end
end

always @ (posedge clk or negedge rst)begin:clear_reg
    integer i, j;
    if(!rst)begin

    end else begin
        if(Clear_reg)begin
            for (j = 0; j < 16; j = j + 1) begin
                    row_pe_array0[j] = 32'h0;
                    row_pe_array1[j] = 32'h0;
                    row_pe_array2[j] = 32'h0;
                    row_pe_array3[j] = 32'h0;
            end
            for (i = 0; i < 4; i = i + 1) begin
                row_pe_scalar[i] = 32'h0;
                // reg_scalar_output[i] = 32'h0;
            end

            for (i = 0; i < 16; i = i + 1) begin
                reg_array_output0[i] = 32'h0;
                reg_array_output1[i] = 32'h0;
                reg_array_output2[i] = 32'h0;
                reg_array_output3[i] = 32'h0;
            end

            for (i = 0; i < 32; i = i + 1) begin
                pre_pe_scalar_output[i] = 32'h0;
            end
            for(i = 0; i < 8; i = i + 1)begin
                for(j = 0; j < 64; j = j + 1)begin
                    pre_pe_array_output[i][j] = 32'h0;
                end
            end
        end
    end
end

always@(*) begin:handle_input
    integer i;
    i = Col_index;
    all_in[i][0] = In0_0;
    all_in[i][1] = In0_1;
    all_in[i][2] = In0_2;
    all_in[i][3] = In0_3;
    all_in[i][4] = In0_4;
    all_in[i][5] = In0_5;
    all_in[i][6] = In0_6;
    all_in[i][7] = In0_7;
    all_in[i][8] = In0_8;
    all_in[i][9] = In0_9;
    all_in[i][10] = In0_10;
    all_in[i][11] = In0_11;
    all_in[i][12] = In0_12;
    all_in[i][13] = In0_13;
    all_in[i][14] = In0_14;
    all_in[i][15] = In0_15;
    all_in[i][16] = In1_0;
    all_in[i][17] = In1_1;
    all_in[i][18] = In1_2;
    all_in[i][19] = In1_3;
    all_in[i][20] = In1_4;
    all_in[i][21] = In1_5;
    all_in[i][22] = In1_6;
    all_in[i][23] = In1_7;
    all_in[i][24] = In1_8;
    all_in[i][25] = In1_9;
    all_in[i][26] = In1_10;
    all_in[i][27] = In1_11;
    all_in[i][28] = In1_12;
    all_in[i][29] = In1_13;
    all_in[i][30] = In1_14;
    all_in[i][31] = In1_15;
    all_in[i][32] = In2_0;
    all_in[i][33] = In2_1;
    all_in[i][34] = In2_2;
    all_in[i][35] = In2_3;
    all_in[i][36] = In2_4;
    all_in[i][37] = In2_5;
    all_in[i][38] = In2_6;
    all_in[i][39] = In2_7;
    all_in[i][40] = In2_8;
    all_in[i][41] = In2_9;
    all_in[i][42] = In2_10;
    all_in[i][43] = In2_11;
    all_in[i][44] = In2_12;
    all_in[i][45] = In2_13;
    all_in[i][46] = In2_14;
    all_in[i][47] = In2_15;
    all_in[i][48] = In3_0;
    all_in[i][49] = In3_1;
    all_in[i][50] = In3_2;
    all_in[i][51] = In3_3;
    all_in[i][52] = In3_4;
    all_in[i][53] = In3_5;
    all_in[i][54] = In3_6;
    all_in[i][55] = In3_7;
    all_in[i][56] = In3_8;
    all_in[i][57] = In3_9;
    all_in[i][58] = In3_10;
    all_in[i][59] = In3_11;
    all_in[i][60] = In3_12;
    all_in[i][61] = In3_13;
    all_in[i][62] = In3_14;
    all_in[i][63] = In3_15;

    all_par[i][0] = Par0_0;
    all_par[i][1] = Par0_1;
    all_par[i][2] = Par0_2;
    all_par[i][3] = Par0_3;
    all_par[i][4] = Par0_4;
    all_par[i][5] = Par0_5;
    all_par[i][6] = Par0_6;
    all_par[i][7] = Par0_7;
    all_par[i][8] = Par0_8;
    all_par[i][9] = Par0_9;
    all_par[i][10] = Par0_10;
    all_par[i][11] = Par0_11;
    all_par[i][12] = Par0_12;
    all_par[i][13] = Par0_13;
    all_par[i][14] = Par0_14;
    all_par[i][15] = Par0_15;
    all_par[i][16] = Par1_0;
    all_par[i][17] = Par1_1;
    all_par[i][18] = Par1_2;
    all_par[i][19] = Par1_3;
    all_par[i][20] = Par1_4;
    all_par[i][21] = Par1_5;
    all_par[i][22] = Par1_6;
    all_par[i][23] = Par1_7;
    all_par[i][24] = Par1_8;
    all_par[i][25] = Par1_9;
    all_par[i][26] = Par1_10;
    all_par[i][27] = Par1_11;
    all_par[i][28] = Par1_12;
    all_par[i][29] = Par1_13;
    all_par[i][30] = Par1_14;
    all_par[i][31] = Par1_15;
    all_par[i][32] = Par2_0;
    all_par[i][33] = Par2_1;
    all_par[i][34] = Par2_2;
    all_par[i][35] = Par2_3;
    all_par[i][36] = Par2_4;
    all_par[i][37] = Par2_5;
    all_par[i][38] = Par2_6;
    all_par[i][39] = Par2_7;
    all_par[i][40] = Par2_8;
    all_par[i][41] = Par2_9;
    all_par[i][42] = Par2_10;
    all_par[i][43] = Par2_11;
    all_par[i][44] = Par2_12;
    all_par[i][45] = Par2_13;
    all_par[i][46] = Par2_14;
    all_par[i][47] = Par2_15;
    all_par[i][48] = Par3_0;
    all_par[i][49] = Par3_1;
    all_par[i][50] = Par3_2;
    all_par[i][51] = Par3_3;
    all_par[i][52] = Par3_4;
    all_par[i][53] = Par3_5;
    all_par[i][54] = Par3_6;
    all_par[i][55] = Par3_7;
    all_par[i][56] = Par3_8;
    all_par[i][57] = Par3_9;
    all_par[i][58] = Par3_10;
    all_par[i][59] = Par3_11;
    all_par[i][60] = Par3_12;
    all_par[i][61] = Par3_13;
    all_par[i][62] = Par3_14;
    all_par[i][63] = Par3_15;

    all_sel_cu[i] = Sel_cu;
    all_sel_cu_go_back[i] = Sel_cu_go_back;
    all_sel_adder[i] = Sel_adder;
    all_is_save_cu_out[i] = Is_save_cu_out;
end

assign Scalar_output0 = reg_scalar_output[0] > 0 ? reg_scalar_output[0] : 32'hxxxx_xxxx;
assign Scalar_output1 = reg_scalar_output[1] > 0 ? reg_scalar_output[1] : 32'hxxxx_xxxx;
assign Scalar_output2 = reg_scalar_output[2] > 0 ? reg_scalar_output[2] : 32'hxxxx_xxxx;
assign Scalar_output3 = reg_scalar_output[3] > 0 ? reg_scalar_output[3] : 32'hxxxx_xxxx;

assign Out0_0 = reg_array_output0[0];
assign Out0_1 = reg_array_output0[1];
assign Out0_2 = reg_array_output0[2];
assign Out0_3 = reg_array_output0[3];
assign Out0_4 = reg_array_output0[4];
assign Out0_5 = reg_array_output0[5];
assign Out0_6 = reg_array_output0[6];
assign Out0_7 = reg_array_output0[7];
assign Out0_8 = reg_array_output0[8];
assign Out0_9 = reg_array_output0[9];
assign Out0_10 = reg_array_output0[10];
assign Out0_11 = reg_array_output0[11];
assign Out0_12 = reg_array_output0[12];
assign Out0_13 = reg_array_output0[13];
assign Out0_14 = reg_array_output0[14];
assign Out0_15 = reg_array_output0[15];

assign Out1_0 = reg_array_output1[0];
assign Out1_1 = reg_array_output1[1];
assign Out1_2 = reg_array_output1[2];
assign Out1_3 = reg_array_output1[3];
assign Out1_4 = reg_array_output1[4];
assign Out1_5 = reg_array_output1[5];
assign Out1_6 = reg_array_output1[6];
assign Out1_7 = reg_array_output1[7];
assign Out1_8 = reg_array_output1[8];
assign Out1_9 = reg_array_output1[9];
assign Out1_10 = reg_array_output1[10];
assign Out1_11 = reg_array_output1[11];
assign Out1_12 = reg_array_output1[12];
assign Out1_13 = reg_array_output1[13];
assign Out1_14 = reg_array_output1[14];
assign Out1_15 = reg_array_output1[15];

assign Out2_0 = reg_array_output2[0];
assign Out2_1 = reg_array_output2[1];
assign Out2_2 = reg_array_output2[2];
assign Out2_3 = reg_array_output2[3];
assign Out2_4 = reg_array_output2[4];
assign Out2_5 = reg_array_output2[5];
assign Out2_6 = reg_array_output2[6];
assign Out2_7 = reg_array_output2[7];
assign Out2_8 = reg_array_output2[8];
assign Out2_9 = reg_array_output2[9];
assign Out2_10 = reg_array_output2[10];
assign Out2_11 = reg_array_output2[11];
assign Out2_12 = reg_array_output2[12];
assign Out2_13 = reg_array_output2[13];
assign Out2_14 = reg_array_output2[14];
assign Out2_15 = reg_array_output2[15];

assign Out3_0 = reg_array_output3[0];
assign Out3_1 = reg_array_output3[1];
assign Out3_2 = reg_array_output3[2];
assign Out3_3 = reg_array_output3[3];
assign Out3_4 = reg_array_output3[4];
assign Out3_5 = reg_array_output3[5];
assign Out3_6 = reg_array_output3[6];
assign Out3_7 = reg_array_output3[7];
assign Out3_8 = reg_array_output3[8];
assign Out3_9 = reg_array_output3[9];
assign Out3_10 = reg_array_output3[10];
assign Out3_11 = reg_array_output3[11];
assign Out3_12 = reg_array_output3[12];
assign Out3_13 = reg_array_output3[13];
assign Out3_14 = reg_array_output3[14];
assign Out3_15 = reg_array_output3[15];

generate
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin : gen_all_PE
        // instance col 1 row 1
        PE pe_inst1 (
            .clk(clk),
            .rst(rst),
            .In0(all_in[i][0]), .In1(all_in[i][1]), .In2(all_in[i][2]), .In3(all_in[i][3]),.In4(all_in[i][4]), .In5(all_in[i][5]), .In6(all_in[i][6]), .In7(all_in[i][7]), .In8(all_in[i][8]), .In9(all_in[i][9]), .In10(all_in[i][10]), .In11(all_in[i][11]), .In12(all_in[i][12]), .In13(all_in[i][13]), .In14(all_in[i][14]), .In15(all_in[i][15]),
            .Par0(all_par[i][0]), .Par1(all_par[i][1]), .Par2(all_par[i][2]), .Par3(all_par[i][3]), .Par4(all_par[i][4]), .Par5(all_par[i][5]), .Par6(all_par[i][6]), .Par7(all_par[i][7]), .Par8(all_par[i][8]), .Par9(all_par[i][9]), .Par10(all_par[i][10]), .Par11(all_par[i][11]), .Par12(all_par[i][12]), .Par13(all_par[i][13]), .Par14(all_par[i][14]), .Par15(all_par[i][15]),
            .Sel_cu(all_sel_cu[i][7:6]),
            .Sel_cu_go_back(all_sel_cu_go_back[i][7:6]),
            .Sel_adder(all_sel_adder[i][7:6]),
            .Is_save_cu_out(all_is_save_cu_out[i][3]),
            .Out_total(pe_scalar_output[i]),
            .Out0(pe_array_output[i][0]), .Out1(pe_array_output[i][1]), .Out2(pe_array_output[i][2]), .Out3(pe_array_output[i][3]), .Out4(pe_array_output[i][4]), .Out5(pe_array_output[i][5]), .Out6(pe_array_output[i][6]), .Out7(pe_array_output[i][7]), 
            .Out8(pe_array_output[i][8]), .Out9(pe_array_output[i][9]), .Out10(pe_array_output[i][10]), .Out11(pe_array_output[i][11]), .Out12(pe_array_output[i][12]), .Out13(pe_array_output[i][13]), .Out14(pe_array_output[i][14]), .Out15(pe_array_output[i][15])
        );

        // instance col 1 row 2
        PE pe_inst2 (
            .clk(clk),
            .rst(rst),
            .In0(all_in[i][16]), .In1(all_in[i][17]), .In2(all_in[i][18]), .In3(all_in[i][19]),.In4(all_in[i][20]), .In5(all_in[i][21]), .In6(all_in[i][22]), .In7(all_in[i][23]),.In8(all_in[i][24]), .In9(all_in[i][25]), .In10(all_in[i][26]), .In11(all_in[i][27]),.In12(all_in[i][28]), .In13(all_in[i][29]), .In14(all_in[i][30]), .In15(all_in[i][31]),
            .Par0(all_par[i][16]), .Par1(all_par[i][17]), .Par2(all_par[i][18]), .Par3(all_par[i][19]),.Par4(all_par[i][20]), .Par5(all_par[i][21]), .Par6(all_par[i][22]), .Par7(all_par[i][23]),.Par8(all_par[i][24]), .Par9(all_par[i][25]), .Par10(all_par[i][26]), .Par11(all_par[i][27]),.Par12(all_par[i][28]), .Par13(all_par[i][29]), .Par14(all_par[i][30]), .Par15(all_par[i][31]),
            .Sel_cu(all_sel_cu[i][5:4]),
            .Sel_cu_go_back(all_sel_cu_go_back[i][5:4]),
            .Sel_adder(all_sel_adder[i][5:4]),
            .Is_save_cu_out(all_is_save_cu_out[i][2]),
            .Out_total(pe_scalar_output[8+i]),
            .Out0(pe_array_output[i][16]), .Out1(pe_array_output[i][17]), .Out2(pe_array_output[i][18]), .Out3(pe_array_output[i][19]), .Out4(pe_array_output[i][20]), .Out5(pe_array_output[i][21]), .Out6(pe_array_output[i][22]), .Out7(pe_array_output[i][23]), 
            .Out8(pe_array_output[i][24]), .Out9(pe_array_output[i][25]), .Out10(pe_array_output[i][26]), .Out11(pe_array_output[i][27]), .Out12(pe_array_output[i][28]), .Out13(pe_array_output[i][29]), .Out14(pe_array_output[i][30]), .Out15(pe_array_output[i][31])
        );

        // instance col 1 row 3
        PE pe_inst3 (
            .clk(clk),
            .rst(rst),
            .In0(all_in[i][32]), .In1(all_in[i][33]), .In2(all_in[i][34]), .In3(all_in[i][35]),.In4(all_in[i][36]), .In5(all_in[i][37]), .In6(all_in[i][38]), .In7(all_in[i][39]),.In8(all_in[i][40]), .In9(all_in[i][41]), .In10(all_in[i][42]), .In11(all_in[i][43]),.In12(all_in[i][44]), .In13(all_in[i][45]), .In14(all_in[i][46]), .In15(all_in[i][47]),
            .Par0(all_par[i][32]), .Par1(all_par[i][33]), .Par2(all_par[i][34]), .Par3(all_par[i][35]),.Par4(all_par[i][36]), .Par5(all_par[i][37]), .Par6(all_par[i][38]), .Par7(all_par[i][39]),.Par8(all_par[i][40]), .Par9(all_par[i][41]), .Par10(all_par[i][42]), .Par11(all_par[i][43]),.Par12(all_par[i][44]), .Par13(all_par[i][45]), .Par14(all_par[i][46]), .Par15(all_par[i][47]),
            .Sel_cu(all_sel_cu[i][3:2]),
            .Sel_cu_go_back(all_sel_cu_go_back[i][3:2]),
            .Sel_adder(all_sel_adder[i][3:2]),
            .Is_save_cu_out(all_is_save_cu_out[i][1]),
            .Out_total(pe_scalar_output[16+i]),
            .Out0(pe_array_output[i][32]), .Out1(pe_array_output[i][33]), .Out2(pe_array_output[i][34]), .Out3(pe_array_output[i][35]), .Out4(pe_array_output[i][36]), .Out5(pe_array_output[i][37]), .Out6(pe_array_output[i][38]), .Out7(pe_array_output[i][39]), 
            .Out8(pe_array_output[i][40]), .Out9(pe_array_output[i][41]), .Out10(pe_array_output[i][42]), .Out11(pe_array_output[i][43]), .Out12(pe_array_output[i][44]), .Out13(pe_array_output[i][45]), .Out14(pe_array_output[i][46]), .Out15(pe_array_output[i][47])
        );

        // instance col 1 row 4
        PE pe_inst4 (
            .clk(clk),
            .rst(rst),
            .In0(all_in[i][48]), .In1(all_in[i][49]), .In2(all_in[i][50]), .In3(all_in[i][51]),.In4(all_in[i][52]), .In5(all_in[i][53]), .In6(all_in[i][54]), .In7(all_in[i][55]),.In8(all_in[i][56]), .In9(all_in[i][57]), .In10(all_in[i][58]), .In11(all_in[i][59]),.In12(all_in[i][60]), .In13(all_in[i][61]), .In14(all_in[i][62]), .In15(all_in[i][63]),
            .Par0(all_par[i][48]), .Par1(all_par[i][49]), .Par2(all_par[i][50]), .Par3(all_par[i][51]),.Par4(all_par[i][52]), .Par5(all_par[i][53]), .Par6(all_par[i][54]), .Par7(all_par[i][55]),.Par8(all_par[i][56]), .Par9(all_par[i][57]), .Par10(all_par[i][58]), .Par11(all_par[i][59]),.Par12(all_par[i][60]), .Par13(all_par[i][61]), .Par14(all_par[i][62]), .Par15(all_par[i][63]),
            .Sel_cu(all_sel_cu[i][1:0]),
            .Sel_cu_go_back(all_sel_cu_go_back[i][1:0]),
            .Sel_adder(all_sel_adder[i][1:0]),
            .Is_save_cu_out(all_is_save_cu_out[i][0]),
            .Out_total(pe_scalar_output[24+i]),
            .Out0(pe_array_output[i][48]), .Out1(pe_array_output[i][49]), .Out2(pe_array_output[i][50]), .Out3(pe_array_output[i][51]), .Out4(pe_array_output[i][52]), .Out5(pe_array_output[i][53]), .Out6(pe_array_output[i][54]), .Out7(pe_array_output[i][55]),  
            .Out8(pe_array_output[i][56]), .Out9(pe_array_output[i][57]), .Out10(pe_array_output[i][58]), .Out11(pe_array_output[i][59]), .Out12(pe_array_output[i][60]), .Out13(pe_array_output[i][61]), .Out14(pe_array_output[i][62]), .Out15(pe_array_output[i][63])
        );
    end
endgenerate
        
// always @(pe_array_output or pe_scalar_output) begin : pe_output_handler
always @(posedge clk or negedge rst) begin : pe_output_handler
    // save sequence of PE
    integer i, j;
    // current pe output has been changed or not , 10表示标量，01表示向量
    reg[1:0] is_value_changed; // 2'b10表示标量发生变化,2'b01表示向量发生变化
    integer value_changed_index;   //记录一下值发生变化的位置
    if(!rst)begin
        
    end
    else begin
        is_value_changed = 2'b00;
        value_changed_index = 0;
        i = 0;
        j = 0;
        for(i = 0; i < 32; i = i + 1)begin
            if(pre_pe_scalar_output[i] !== pe_scalar_output[i])begin
                is_value_changed = 2'b10;
                pre_pe_scalar_output[i] = pe_scalar_output[i];
                value_changed_index = i;
            end
        end

        if(is_value_changed == 2'b00)begin
            for(j = 0 ; j < 64; j = j + 1)begin
                if(pre_pe_array_output[Col_index][i] !== pe_array_output[Col_index][i])begin
                    is_value_changed = 2'b01;
                    pre_pe_array_output[Col_index][j] = pe_array_output[Col_index][j];
                    value_changed_index = i;
                end
            end   
        end

        if (is_value_changed > 2'b00)begin
            case ({Sum_row_pe, Sum_column_pe})  // Sum_row_pe and Sum_column_pe only can be set 2'b01 or 2'b10
                //case ADD or aDD , directly output PE's result，A reprasent array, a reprasent scalar
                4'b0101: begin
                    if(is_value_changed == 2'b10)begin
                        reg_scalar_output[0] = pe_scalar_output[Col_index];
                        reg_scalar_output[1] = pe_scalar_output[8+Col_index];
                        reg_scalar_output[2] = pe_scalar_output[16+Col_index];
                        reg_scalar_output[3] = pe_scalar_output[24+Col_index];
                    end else if(is_value_changed == 2'b01)begin
                        for (i = 0; i < 16; i = i + 1) begin
                            reg_array_output0[i] = pe_array_output[Col_index][i];
                            reg_array_output1[i] = pe_array_output[Col_index][16+i];
                            reg_array_output2[i] = pe_array_output[Col_index][32+i];
                            reg_array_output3[i] = pe_array_output[Col_index][48+i];
                        end
                    end
                end
                //case ADS or aDS , 输出一列PE的结果 output column PE's result
                4'b0110: begin
                    if(is_value_changed == 2'b10)begin
                        // 一列的标量之和，存储在Scalar_output[0]中
                        reg_scalar_output[Col_index%4] = pe_scalar_output[Col_index] + pe_scalar_output[8+Col_index] + pe_scalar_output[16+Col_index] + pe_scalar_output[24+Col_index];
                    end else if(is_value_changed == 2'b01)begin
                        for (i = 0; i < 16; i = i + 1) begin
                            if(Col_index % 4 == 0)begin
                                reg_array_output0[i] = pe_array_output[Col_index][i] + pe_array_output[Col_index][16+i] + pe_array_output[Col_index][32+i] + pe_array_output[Col_index][48+i];
                            end else if(Col_index % 4 == 1)begin
                                reg_array_output1[i] = pe_array_output[Col_index][i] + pe_array_output[Col_index][16+i] + pe_array_output[Col_index][32+i] + pe_array_output[Col_index][48+i];
                            end else if(Col_index % 4 == 2)begin
                                reg_array_output2[i] = pe_array_output[Col_index][i] + pe_array_output[Col_index][16+i] + pe_array_output[Col_index][32+i] + pe_array_output[Col_index][48+i];
                            end else if(Col_index % 4 == 3)begin
                                reg_array_output3[i] = pe_array_output[Col_index][i] + pe_array_output[Col_index][16+i] + pe_array_output[Col_index][32+i] + pe_array_output[Col_index][48+i];
                            end
                            
                        end
                    end
                end
                //case ASD or aSD or ASS or aSS, 输出一行PE的结果 output row PE's result
                4'b1001, 4'b1010: begin
                    if(is_value_changed == 2'b10)begin
                        //TODO 这里如果pe_scalar_output[7]有数值，那么到下一个clk上升沿的时候，如果is_value_changed 标记为2'b10，就会累加pe_scalar_output[7]，哪怕pe_scalar_output[7]没有任何变化，这里不合理
                        row_pe_scalar[0] = (pe_scalar_output[Col_index] !== 32'hxxxx_xxxx)? row_pe_scalar[0] + pe_scalar_output[Col_index] : row_pe_scalar[0];
                        row_pe_scalar[1] = (pe_scalar_output[8+Col_index] !== 32'hxxxx_xxxx)? row_pe_scalar[1] + pe_scalar_output[8+Col_index] : row_pe_scalar[1];
                        row_pe_scalar[2] = (pe_scalar_output[16+Col_index] !== 32'hxxxx_xxxx)? row_pe_scalar[2] + pe_scalar_output[16+Col_index] : row_pe_scalar[2];
                        row_pe_scalar[3] = (pe_scalar_output[24+Col_index] !== 32'hxxxx_xxxx)? row_pe_scalar[3] + pe_scalar_output[24+Col_index] : row_pe_scalar[3];
                    end else if(is_value_changed == 2'b01)begin
                        for (i = 0; i < 16; i = i + 1) begin
                            row_pe_array0[i] = row_pe_array0[i] + pe_array_output[Col_index][i];
                            row_pe_array1[i] = row_pe_array1[i] + pe_array_output[Col_index][16+i];
                            row_pe_array2[i] = row_pe_array2[i] + pe_array_output[Col_index][32+i];
                            row_pe_array3[i] = row_pe_array3[i] + pe_array_output[Col_index][48+i];
                        end
                    end
                    // 到了最后一列了，把所有列加和
                    if(Col_index == 3'b111)begin
                        // 这一步是ASD或ASS都要执行的
                        if(is_value_changed == 2'b10)begin
                            if({Sum_row_pe, Sum_column_pe} == 4'b1001)begin    //这一步是ASD要执行的
                                reg_scalar_output[0] = row_pe_scalar[0];
                                reg_scalar_output[1] = row_pe_scalar[1];
                                reg_scalar_output[2] = row_pe_scalar[2];
                                reg_scalar_output[3] = row_pe_scalar[3];
                            end else if({Sum_row_pe, Sum_column_pe} == 4'b1010)begin  //这一步是ASS要执行的
                                // Scalar_output0 输出所有PE标量之和
                                reg_scalar_output[0] = row_pe_scalar[0] + row_pe_scalar[1] + row_pe_scalar[2] + row_pe_scalar[3];
                            end
                        end else if(is_value_changed == 2'b01)begin
                            for (i = 0; i < 16; i = i + 1) begin
                                if({Sum_row_pe, Sum_column_pe} == 4'b1010)begin   //这一步是ASD要执行的
                                    reg_array_output0[i] = row_pe_array0[i]; 
                                    reg_array_output1[i] = row_pe_array1[i];
                                    reg_array_output2[i] = row_pe_array2[i];
                                    reg_array_output3[i] = row_pe_array3[i];
                                end else if({Sum_row_pe, Sum_column_pe} == 4'b1010)begin   //这一步是只有ASS要执行的
                                    //Array_output0 输出所有PE向量之和
                                    reg_array_output0[i] = row_pe_array0[i] + row_pe_array1[i] + reg_array_output2[i] + row_pe_array3[i];
                                end
                            end
                        end
                    end
                end
            endcase
        end
    end
end

endmodule