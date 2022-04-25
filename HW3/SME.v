`define blankspace  8'h20
module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg[4:0] match_index;
output reg valid;

reg [7:0]string[0:33];
reg [5:0]strSize;
reg [5:0]strIdx;
reg [7:0]pattern[0:7];
reg [4:0]patSize;
reg [4:0]patIdx;
reg [1:0]state;
reg matchStr;
reg [5:0]i,j;
reg [4:0]patMatchIdx;
reg [5:0]strMatchIdx;

parameter IDLE=2'd0;
parameter Matching=2'd1;
parameter StringInput=2'd2;
parameter PatternInput=2'd3;

parameter period=8'h2E;
parameter caret=8'h5E;
parameter dollar=8'h24;

always @(posedge clk, posedge reset) begin
    if(reset)begin
        match<=0; valid<=0;
        matchStr<=0;
        match_index<=0;
        state<=IDLE;
        
        strIdx<=1; strSize<=2;
        patIdx<=0; patSize<=0;
        patMatchIdx<=0; strMatchIdx<=1;
        for ( i=0 ;i<34 ;i=i+1 ) string[i]<=`blankspace;
        for ( j=0 ;j<8 ;j=j+1 ) pattern[j]<=0;
    end
    else begin
        if(state==StringInput)begin
            match_index<=0;
            if(matchStr==1)begin
                strSize<=3;
            end
            else strSize<=strSize+1;
            strIdx<=strIdx+1;
            string[strIdx]<=chardata;
            for ( j=0 ;j<8 ;j=j+1 ) pattern[j]<=0;
            patSize<=0;
            patIdx<=0;
            valid<=0;
            match<=0;
            matchStr<=0;
        end
        
        else if(state==PatternInput)begin
            match_index<=0;
            patIdx<=patIdx+1;
            patSize<=patSize+1;
            pattern[patIdx]<=chardata;
            valid<=0;
            match<=0;
            matchStr<=0;
        end
        else if(state==Matching)begin
            if((patMatchIdx==patSize || patMatchIdx == patSize - 1) && strMatchIdx==strSize-1)begin
                for ( j=0 ;j<8 ;j=j+1 ) pattern[j]<=0; //reset pattern
                patSize<=0; patIdx<=0;
                patMatchIdx<=0; strMatchIdx<=1;
                strIdx<=1;patIdx<=0;

                match_index<=match_index;
                match<=1;
                valid<=1;
            end
            else if(patMatchIdx==patSize && strMatchIdx!=strSize-1)begin
                for ( j=0 ;j<8 ;j=j+1 ) pattern[j]<=0; //reset pattern
                patSize<=0; patIdx<=0;
                patMatchIdx<=0; strMatchIdx<=1;
                strIdx<=1;patIdx<=0;

                match_index<=match_index;
                match<=1;
                valid<=1;
            end
            else if((patMatchIdx!=patSize || patMatchIdx != patSize - 1) && strMatchIdx==strSize-1 )begin
                for ( j=0 ;j<8 ;j=j+1 ) pattern[j]<=0;  //reset pattern
                patSize<=0;patIdx<=0;
                patMatchIdx<=0; strMatchIdx<=1;
                strIdx<=1;patIdx<=0;

                match_index<=match_index;
                valid<=1;
                match<=0;
            end
            else begin
                string[strSize-1]<=`blankspace; //set blank as last element
                case(pattern[patMatchIdx])
                    dollar:begin
                        if(string[strMatchIdx]==`blankspace)begin
                            patMatchIdx<=patMatchIdx+1;   
                        end 
                        else begin
                            match_index<=match_index+1;
                            strMatchIdx<=strMatchIdx+1;
                            patMatchIdx<=0;
                        end
                    end
                    caret:begin
                        if(string[strMatchIdx-1]==`blankspace)begin                           
                            patMatchIdx<=patMatchIdx+1;
                        end
                        else begin
                            match_index<=match_index+1;
                            strMatchIdx<=strMatchIdx+1;
                            patMatchIdx<=0;
                        end
                    end
                    period:begin
                        patMatchIdx<=patMatchIdx+1;
                        if(strMatchIdx==0)begin
                            strMatchIdx<=strMatchIdx+2;
                            match_index<=1;
                        end
                        else begin
                            strMatchIdx<=strMatchIdx+1;
                        end
                            
                    end
                    string[strMatchIdx]: begin
                        patMatchIdx<=patMatchIdx+1;
                        strMatchIdx<=strMatchIdx+1;
                    end
                    default:begin
                        patMatchIdx<=0;
                        match_index<=match_index+1;
                        strMatchIdx<=match_index+2;
                    end
                endcase 
            end
        end
        else if(isstring==0 && ispattern==0) matchStr<=1;
    end
end




//control state
always @(*) begin
    case(1)
        isstring: state=StringInput;
        ispattern: state=PatternInput;
        matchStr: state=Matching;
        default: state=IDLE;
    endcase
end

endmodule
