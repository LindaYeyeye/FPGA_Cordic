`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/04 11:23:19
// Design Name: 
// Module Name: cordic_serial
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


module cordic_serial(
    input signed [31:0]    x,
    input signed [31:0]    y,
    input           clk,
    output reg [31:0]   phase
    );

    //FSM_parameter
    localparam IDLE = 2'd0;
    localparam WORK = 2'd1;
    localparam DONE = 2'd2;

    reg     [1:0]state ;
    reg     [1:0]next_state;

    reg     [6:0]counter;

    wire   [31:0] rot[15:0];

//旋转角度查找表
assign  rot[0]  = 32'd2949120 ;     //45度*2^16
assign  rot[1]  = 32'd1740992 ;     //26.5651度*2^16
assign  rot[2]  = 32'd919872  ;     //14.0362度*2^16
assign  rot[3]  = 32'd466944  ;     //7.1250度*2^16
assign  rot[4]  = 32'd234368  ;     //3.5763度*2^16
assign  rot[5]  = 32'd117312  ;     //1.7899度*2^16
assign  rot[6]  = 32'd58688   ;     //0.8952度*2^16
assign  rot[7]  = 32'd29312   ;     //0.4476度*2^16
assign  rot[8]  = 32'd14656   ;     //0.2238度*2^16
assign  rot[9]  = 32'd7360    ;     //0.1119度*2^16
assign  rot[10] = 32'd3648    ;     //0.0560度*2^16
assign  rot[11] = 32'd1856    ;     //0.0280度*2^16
assign  rot[12] = 32'd896     ;     //0.0140度*2^16
assign  rot[13] = 32'd448     ;     //0.0070度*2^16
assign  rot[14] = 32'd256     ;     //0.0035度*2^16
assign  rot[15] = 32'd128     ;     //0.0018度*2^16

    always @(posedge clk) begin
        state<=next_state;
        case(state)
        IDLE:next_state<=WORK;
        WORK:next_state<= counter==14?DONE:WORK;
        DONE:next_state<=IDLE;

        default:next_state<=IDLE;
        endcase
    end

    reg signed [31:0] x_shift;
    reg signed [31:0] y_shift;
    reg signed [31:0] z_rot;

    wire     D_sign;
    assign   D_sign=~y_shift[31];

    always @(posedge clk ) begin
        case(state)
        IDLE:
        begin
            x_shift<=x;
            y_shift<=y;
            z_rot<=0;
        end

        WORK:if(D_sign)
        begin
            x_shift       <= x_shift + (y_shift>>>counter);
            y_shift       <= y_shift - (x_shift>>>counter);
            z_rot         <= z_rot  + rot[counter];
        end
        else begin
            x_shift       <= x_shift - (y_shift>>>counter);
            y_shift       <= y_shift + (x_shift>>>counter);
            z_rot         <= z_rot  - rot[counter];
        end
        
        DONE:
        begin
            phase<=z_rot;
        end
        default : ;
        endcase
    end

    always @(posedge clk ) begin
        if(state==IDLE && next_state==WORK)
            counter<=0;
        else if(state==WORK)begin
        if(counter<4'd14)
            counter<=counter+1;
            else
            counter<=counter;
        end
        else
            counter<=0;
    end



endmodule
