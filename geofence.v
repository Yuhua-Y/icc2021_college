module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output valid;
output is_inside;
//reg valid;
//reg is_inside;
/////////////////////////////////////////
reg [3:0]cur_st,nex_st;
reg [3:0]counter_7_read;
reg [3:0]counter_5_site;
reg [2:0]counter_pos;
reg [2:0]counter_neg;
reg [1:0]counter_4;
reg [2:0]counter_6_judge;
reg [2:0]judge_ans;

reg curve_ans;
reg [2:0]right_place;
reg [9:0]out_x[5:0];
reg [9:0]out_y[5:0];

reg [9:0]right_x[5:0];
reg [9:0]right_y[5:0];
reg [9:0]dot_x;
reg [9:0]dot_y;

reg [9:0]first_temp_x;
reg [9:0]first_temp_y;
reg [9:0]end_temp_x;
reg [9:0]end_temp_y;
reg [9:0]temp_x;
reg [9:0]temp_y;
parameter IDLE=4'd0,READ=4'd1,CAL=4'd2,SITE=4'd3,MOVE=4'd4,JUDGE=4'd5,OUTPUT=4'd6;

assign is_inside=((judge_ans==6)||(judge_ans==0))?1:0;
assign valid=(cur_st==OUTPUT)?1:0;
always @(posedge clk or posedge reset) begin
    if(reset)
        cur_st<=IDLE;
    else
        cur_st<=nex_st;
end

always @(*) begin
    case(cur_st)
        IDLE:nex_st=READ;
        READ:nex_st=(counter_7_read==7)?CAL:READ;
        CAL:nex_st=(counter_4==3)?SITE:CAL;
        SITE:nex_st=MOVE;
        MOVE:nex_st=(counter_5_site==5)?JUDGE:CAL;
        JUDGE:nex_st=(counter_6_judge==5)?OUTPUT:JUDGE;
        OUTPUT:nex_st=IDLE;
        default:nex_st=IDLE;
    endcase
end

always @(posedge clk) begin
    if(reset)
        counter_7_read<=0;
    else if(cur_st==READ)
        counter_7_read<=counter_7_read+1;
    else if(cur_st==CAL)
        counter_7_read<=0;
end

always @(posedge clk) begin
    if(reset)
        counter_4<=0;
    else if(cur_st==CAL)
        counter_4<=counter_4+1;
    else 
        counter_4<=0;
end

always @(*) begin
    case(counter_5_site)
    0:begin
        case(counter_4)
        0:begin
            temp_x=out_x[2];
            temp_y=out_y[2];
        end
        1:begin
            temp_x=out_x[3];
            temp_y=out_y[3];
        end
        2:begin
            temp_x=out_x[4];
            temp_y=out_y[4];
        end
        3:begin
            temp_x=out_x[5];
            temp_y=out_y[5];
        end
        endcase
    end
    1:begin
        case(counter_4)
        0:begin
            temp_x=out_x[1];
            temp_y=out_y[1];
        end
        1:begin
            temp_x=out_x[3];
            temp_y=out_y[3];
        end
        2:begin
            temp_x=out_x[4];
            temp_y=out_y[4];
        end
        3:begin
            temp_x=out_x[5];
            temp_y=out_y[5];
        end
        endcase
    end
    2:begin
        case(counter_4)
        0:begin
            temp_x=out_x[1];
            temp_y=out_y[1];
        end
        1:begin
            temp_x=out_x[2];
            temp_y=out_y[2];
        end
        2:begin
            temp_x=out_x[4];
            temp_y=out_y[4];
        end
        3:begin
            temp_x=out_x[5];
            temp_y=out_y[5];
        end
        endcase
    end
    3:begin
        case(counter_4)
        0:begin
            temp_x=out_x[1];
            temp_y=out_y[1];
        end
        1:begin
            temp_x=out_x[2];
            temp_y=out_y[2];
        end
        2:begin
            temp_x=out_x[3];
            temp_y=out_y[3];
        end
        3:begin
            temp_x=out_x[5];
            temp_y=out_y[5];
        end
        endcase
    end
    4:begin
        case(counter_4)
        0:begin
            temp_x=out_x[1];
            temp_y=out_y[1];
        end
        1:begin
            temp_x=out_x[2];
            temp_y=out_y[2];
        end
        2:begin
            temp_x=out_x[3];
            temp_y=out_y[3];
        end
        3:begin
            temp_x=out_x[4];
            temp_y=out_y[4];
        end
        endcase
    end
    default:begin
        temp_x=0;
        temp_y=0;
    end
    endcase
end


//dot_x,y
always @(posedge clk) begin
    if(reset)begin
        dot_x<=0;
        dot_y<=0;
    end
    else if(cur_st==IDLE)
        if(counter_7_read==0)begin
            dot_x<=X;
            dot_y<=Y;
        end
end

//out_x
always @(posedge clk) begin
    if(cur_st==READ)begin
        case(counter_7_read)
        0:out_x[0]<=X;
        1:out_x[1]<=X;
        2:out_x[2]<=X;
        3:out_x[3]<=X;
        4:out_x[4]<=X;
        5:out_x[5]<=X;
        endcase
    end
end

//out_y
always @(posedge clk) begin
    if(cur_st==READ)begin
        case(counter_7_read)
        0:out_y[0]<=Y;
        1:out_y[1]<=Y;
        2:out_y[2]<=Y;
        3:out_y[3]<=Y;
        4:out_y[4]<=Y;
        5:out_y[5]<=Y;
        endcase
    end
end

//counter_pos
always @(posedge clk) begin
    if(reset)
    counter_pos<=0;
    else if(cur_st==CAL)begin
        if(curve_ans==1) 
        counter_pos<=counter_pos+1;
    end
    else if(cur_st==MOVE)
        counter_pos<=0;
end

//counter_neg
always @(posedge clk) begin
    if(reset)
    counter_neg<=0;
    else if(cur_st==CAL)begin
        if(curve_ans==0)
        counter_neg<=counter_neg+1;
    end
    else if(cur_st==MOVE)
        counter_neg<=0;
end

//counter_5_site
always @(posedge clk) begin
    if(reset)
        counter_5_site<=0;
    else if(counter_4==3)
        counter_5_site<=counter_5_site+1;
    else if(cur_st==JUDGE)
        counter_5_site<=0;
end



//right_place
always @(posedge clk) begin
    if(cur_st==SITE)
        case (counter_pos)
            3'b100: right_place<=5;
            3'b011: right_place<=4;
            3'b010: right_place<=3;
            3'b001: right_place<=2;
            3'b000: right_place<=1;
            default: right_place<=0;
        endcase
end

     
     
//[19:0]right[5:0]!!!!!! 
always @(posedge clk) begin
    if(cur_st==CAL)
    right_x[0]<=out_x[0];
    else if(cur_st==MOVE)begin
        case(right_place)
        1:right_x[1]<=out_x[counter_5_site];
        2:right_x[2]<=out_x[counter_5_site];
        3:right_x[3]<=out_x[counter_5_site];
        4:right_x[4]<=out_x[counter_5_site];
        5:right_x[5]<=out_x[counter_5_site];
        default:right_x[0]<=out_x[0];
    endcase
    end
end

always @(posedge clk) begin
    if(cur_st==CAL)
    right_y[0]<=out_y[0];
    if(cur_st==MOVE)begin
        case(right_place)
        1:right_y[1]<=out_y[counter_5_site];
        2:right_y[2]<=out_y[counter_5_site];
        3:right_y[3]<=out_y[counter_5_site];
        4:right_y[4]<=out_y[counter_5_site];
        5:right_y[5]<=out_y[counter_5_site];
        default:right_y[0]<=out_y[0];
    endcase
    end
end

always @(posedge clk) begin
    if(reset)
        counter_6_judge<=0;
    else if(cur_st==JUDGE)
        counter_6_judge<=counter_6_judge+1;
    else if(cur_st==OUTPUT)
        counter_6_judge<=0;
end

//first_temp_x
always @(*) begin
    if(cur_st==CAL)begin
        case (counter_5_site)
            0: first_temp_x=out_x[1];
            1: first_temp_x=out_x[2];
            2: first_temp_x=out_x[3];
            3: first_temp_x=out_x[4];
            4: first_temp_x=out_x[5];
            default: first_temp_x=0;
        endcase
    end
    else if(cur_st==JUDGE)begin
        case (counter_6_judge)
            0:first_temp_x=right_x[1];
            1:first_temp_x=right_x[2];
            2:first_temp_x=right_x[3];
            3:first_temp_x=right_x[4];
            4:first_temp_x=right_x[5];
            5:first_temp_x=right_x[0];
            default:first_temp_x=0;
        endcase
    end
    else
        first_temp_x=0;
end

//first_temp_y
always @(*) begin
    if(cur_st==CAL)begin
        case(counter_5_site)
            0: first_temp_y=out_y[1];
            1: first_temp_y=out_y[2];
            2: first_temp_y=out_y[3];
            3: first_temp_y=out_y[4];
            4: first_temp_y=out_y[5];
            default: first_temp_y=0; 
        endcase 
    end
    else if(cur_st==JUDGE)begin
        case (counter_6_judge)
            0:first_temp_y=right_y[1];
            1:first_temp_y=right_y[2];
            2:first_temp_y=right_y[3];
            3:first_temp_y=right_y[4];
            4:first_temp_y=right_y[5];
            5:first_temp_y=right_y[0];
            default:first_temp_y=0;
        endcase
    end
    else
        first_temp_y=0;
end

//end_temp_x
always @(*) begin
    if(cur_st==JUDGE)begin
        case (counter_6_judge)
        0:end_temp_x=right_x[0];
        1:end_temp_x=right_x[1];
        2:end_temp_x=right_x[2];
        3:end_temp_x=right_x[3];
        4:end_temp_x=right_x[4];
        5:end_temp_x=right_x[5];
        default:end_temp_x=0;
        endcase
    end
    else end_temp_x=0;
end

//end_temp_y
always @(*) begin
    if(cur_st==JUDGE)begin
        case (counter_6_judge)
        0:end_temp_y=right_y[0];
        1:end_temp_y=right_y[1];
        2:end_temp_y=right_y[2];
        3:end_temp_y=right_y[3];
        4:end_temp_y=right_y[4];
        5:end_temp_y=right_y[5];
        default:end_temp_y=0;
        endcase
    end
    else end_temp_y=0;
end

always @(*) begin
    if(cur_st==CAL)begin
        curve_ans=curve(first_temp_x,first_temp_y,temp_x,temp_y,out_x[0],out_y[0]);
    end
    else if(cur_st==JUDGE)begin
        curve_ans=curve(dot_x,dot_y,first_temp_x,first_temp_y,end_temp_x,end_temp_y);
    end
    else curve_ans=0;
end

always @(posedge clk) begin
    if(reset)
        judge_ans<=0;
    else if(cur_st==JUDGE)begin
        if(curve_ans==1)
            judge_ans<=judge_ans+1;
    end
    else if(cur_st==READ)
        judge_ans<=0;
end

function curve;
input [9:0]Ax,Ay,Bx,By,Cx,Cy;

reg signed [10:0]dis_1,dis_2,dis_3,dis_4;
reg signed [22:0]mul_1,mul_2; 
begin
    dis_1=Ax-Cx;
    dis_2=Ay-Cy;
    dis_3=Bx-Cx;
    dis_4=By-Cy;

    mul_1=dis_1*dis_4;
    mul_2=dis_3*dis_2;
    if(mul_1>mul_2)
        curve=1;//POSTIVE ANTI_CLOCKWISE
    else
        curve=0;//NEGTIVE CLOCKWISE
end

endfunction

/////////////////////////////////////////
endmodule

