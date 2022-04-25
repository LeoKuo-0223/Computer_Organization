module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);
reg [3:0]state;
reg [10:0]count;
reg pass_state;

always@(posedge clk or posedge rst)begin
    if(rst)begin
        state<=0;
        count<=0;
        pass_state<=0;
    end 
    else begin

        if((pass && count>512) || pass_state==1)begin
            count<=0;
            state<=0;
            pass_state<=1;
        end
        else begin
            count<=count+1;
            case(count)
                    511: state<=1;
                    575: state<=0;
                    639: state<=1;
                    703: state<=0;
                    767: state<=2;
                    1023: state<=3;
                    1535: state<=0;
            endcase
        end
    end
end

always@(state or negedge pass)begin
    if(!pass) pass_state=0;
    if(count>=1536) count=0;
    case(state)
        0: begin
            G=1;R=0;Y=0;
        end
        1: begin
            G=0;R=0;Y=0;
        end
        2: begin
            G=0;R=0;Y=1;
        end
        3: begin
            G=0;R=1;Y=0;
        end
        default:  begin
            G=0;R=0;Y=0;
        end
    endcase
end
endmodule
