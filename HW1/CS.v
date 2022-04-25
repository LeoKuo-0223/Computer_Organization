`timescale 1ns/10ps
module CS(Y, X, reset, clk);

  input clk, reset; 
  input 	[7:0] X;
  output 	reg[9:0] Y;
  reg [7:0]arr[8:0];
  reg [3:0]i;
  reg [3:0]j;
  reg [11:0]sum;
  reg [9:0]compute_avg;
  reg [11:0]closest_element;
  reg [3:0]counter;

  always@(posedge clk)begin
    if(!reset)begin
      for(i=0;i<8;i=i+1) 
       arr[i+1]<=arr[i];
      arr[0]<=X;
      sum<=sum+X-arr[8];
    end
    else begin
      for(i=0;i<9;i=i+1) 
       arr[i]<=0;
      sum<=0;
      Y<=0;
      closest_element<=0;
      compute_avg<=0;
      counter<=1;
    end
  end

  always@(sum) begin
    if(!reset)begin
      if(counter<=9) counter=counter+1; 
      if(counter>9)begin
        compute_avg=sum/9;
        closest_element=X;
        for(j=0;j<9;j=j+1)begin
          if(compute_avg-arr[j]>=0)begin
            if( (compute_avg-arr[j]) < (compute_avg-closest_element) )
              closest_element=arr[j];
          end
        end
        Y=(sum+closest_element*9)/8;
      end
    end
  end

endmodule
