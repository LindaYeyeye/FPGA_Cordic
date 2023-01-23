`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/30 14:29:47
// Design Name: 
// Module Name: cordic_vec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//Xn+1 = Xn-dn(2^(-i)Yn)
//Yn+1 = Yn+dn(2^(-i)Xn)
//Zn+1=Zn-dn(theta)

module cordic_vec(

    input [31:0]    x,
    input  [31:0]    y,
    input           clk,
    output [31:0]   phase
    );

//旋转角度查找表
`define rot0  32'd2949120       //45度*2^16
`define rot1  32'd1740992       //26.5651度*2^16
`define rot2  32'd919872        //14.0362度*2^16
`define rot3  32'd466944        //7.1250度*2^16
`define rot4  32'd234368        //3.5763度*2^16
`define rot5  32'd117312        //1.7899度*2^16
`define rot6  32'd58688         //0.8952度*2^16
`define rot7  32'd29312         //0.4476度*2^16
`define rot8  32'd14656         //0.2238度*2^16
`define rot9  32'd7360          //0.1119度*2^16
`define rot10 32'd3648          //0.0560度*2^16
`define rot11 32'd1856          //0.0280度*2^16
`define rot12 32'd896           //0.0140度*2^16
`define rot13 32'd448           //0.0070度*2^16
`define rot14 32'd256           //0.0035度*2^16
`define rot15 32'd128           //0.0018度*2^16

parameter K = 32'h09b74;  //K=0.607253*2^16,32'h09b74,16位定点小数

localparam STG = 16;
reg signed [31:0] X [0:STG-1];
reg signed [31:0] Y [0:STG-1];
reg signed [31:0] Z [0:STG-1]; // 32bit

always @(posedge clk ) begin
        X[0] <= x; 
        Y[0] <= y; 
        Z[0] <= 32'd0;            //z0赋初值0
end

//开始迭代
 genvar i;

   generate
   for (i=0; i < (STG); i=i+1)
   begin: XYZ
      
      wire signed  [31 :0] X_shr, Y_shr; 
      wire                   Z_sign;
      assign X_shr = X[i] >>> i; // 移位次数由迭代次数决定
      assign Y_shr = Y[i] >>> i;
   
      //Z加或者减由Y的大小决定。
      assign Z_sign = ~Y[i][31]; // Z_sign = 1 if Z[i] < 0
   
      always @(posedge clk)
      begin
         // add/subtract shifted data
         X[i+1] <= Z_sign ? X[i] + Y_shr         : X[i] - Y_shr;
         Y[i+1] <= Z_sign ? Y[i] - X_shr         : Y[i] + X_shr;
      end

        always @(posedge clk ) begin
        case(i)
        15'd0: Z[i+1] <= Z_sign ? Z[i] + `rot0 : Z[i] - `rot0;
        15'd1: Z[i+1] <= Z_sign ? Z[i] + `rot1 : Z[i] - `rot1;
        15'd2: Z[i+1] <= Z_sign ? Z[i] + `rot2 : Z[i] - `rot2;
        15'd3: Z[i+1] <= Z_sign ? Z[i] + `rot3 : Z[i] - `rot3;
        15'd4: Z[i+1] <= Z_sign ? Z[i] + `rot4 : Z[i] - `rot4;
        15'd5: Z[i+1] <= Z_sign ? Z[i] + `rot5 : Z[i] - `rot5;
        15'd6: Z[i+1] <= Z_sign ? Z[i] + `rot6 : Z[i] - `rot6;
        15'd7: Z[i+1] <= Z_sign ? Z[i] + `rot7 : Z[i] - `rot7;
        15'd8: Z[i+1] <= Z_sign ? Z[i] + `rot8 : Z[i] - `rot8;
        15'd9: Z[i+1] <= Z_sign ? Z[i] + `rot9 : Z[i] - `rot9;
        15'd10: Z[i+1] <= Z_sign ? Z[i] + `rot10 : Z[i] - `rot10;
        15'd11: Z[i+1] <= Z_sign ? Z[i] + `rot11 : Z[i] - `rot11;
        15'd12: Z[i+1] <= Z_sign ? Z[i] + `rot12 : Z[i] - `rot12;
        15'd13: Z[i+1] <= Z_sign ? Z[i] + `rot13 : Z[i] - `rot13;
        15'd14: Z[i+1] <= Z_sign ? Z[i] + `rot14 : Z[i] - `rot14;
        15'd15: Z[i+1] <= Z_sign ? Z[i] + `rot15 : Z[i] - `rot15;
      

        endcase
   end

   end

 
   endgenerate
   
    assign phase = Z[STG-1];

endmodule
