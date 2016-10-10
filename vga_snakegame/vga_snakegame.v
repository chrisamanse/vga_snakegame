module vga_snakegame(CLOCK_50, PB, SW, LEDG, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, HEX0, HEX1, HEX2, HEX3);
parameter N = 5_000_000, length = 63;
input CLOCK_50;
input [3:0] PB;
input [9:0] SW;
output [7:0] LEDG;
output [3:0] VGA_R, VGA_G, VGA_B;
output VGA_HS, VGA_VS;
output [6:0] HEX0, HEX1, HEX2, HEX3;
reg [7:0] LEDG;
reg [3:0] VGA_R, VGA_G, VGA_B;
wire [9:0] posX;
wire [8:0] posY;
wire rgboff;
wire [6:0] blockPosX, blockPosY;

reg [6:0] holderX, holderY;
reg [5:0] snakeLength;
reg [1:0] dir;
reg blockFound;
reg [1:0] gameState; //reset, play, gameover;
wire [25:0] cnt;
wire [37:0] cnt2;
wire border;
wire gaps;
wire gameover_letters;
wire game_g;
wire game_a;
wire game_m;
wire game_e;
wire over_o;
wire over_v;
wire over_e;
wire over_r;

reg [5:0] storedX [0:length - 1];
reg [5:0] storedY [0:length - 1];
reg [5:0] foodX, foodY;
wire [7:0] scoreBCD;
integer i, j;
integer x;

initial begin
	gameState = 1;
	snakeLength = 14;
	dir = 0;
	blockFound = 0;
	
	for (i = 0; i < length; i = i + 1) begin
		storedX[i] = 0;
		storedY[i] = 0;
	end
	foodX = 43;
	foodY = 23;
	storedX[13] = 23;
	storedY[13] = 23;
	storedX[12] = 22;
	storedY[12] = 23;
	storedX[11] = 21;
	storedY[11] = 23;
	storedX[10] = 20;
	storedY[10] = 23;
	storedX[9] = 19;
	storedY[9] = 23;
	storedX[8] = 18;
	storedY[8] = 23;
	storedX[7] = 17;
	storedY[7] = 23;
	storedX[6] = 16;
	storedY[6] = 23;
	storedX[5] = 15;
	storedY[5] = 23;
	storedX[4] = 14;
	storedY[4] = 23;
	storedX[3] = 13;
	storedY[3] = 23;
	storedX[2] = 12;
	storedY[2] = 23;
	storedX[1] = 11;
	storedY[1] = 23;
	storedX[0] = 10;
	storedY[0] = 23;
end

function [6:0] bcdto7seg; //(7seg -> g,f,e,d,c,b,a);
input [4:0] bcd;
	
  case (bcd)
  0 :  bcdto7seg = 7'b1000000; 
  1 :  bcdto7seg = 7'b1111001; 
  2 :  bcdto7seg = 7'b0100100; 
  3 :  bcdto7seg = 7'b0110000; 
  4 :  bcdto7seg = 7'b0011001; 
  5 :  bcdto7seg = 7'b0010010; 
  6 :  bcdto7seg = 7'b0000010; 
  7 :  bcdto7seg = 7'b1111000; 
  8 :  bcdto7seg = 7'b0000000; 
  9 :  bcdto7seg = 7'b0010000; 
  10:  bcdto7seg = 7'b0001000;
  11:  bcdto7seg = 7'b0000011;
  12:  bcdto7seg = 7'b1000110;
  13:  bcdto7seg = 7'b0100001;
  14:  bcdto7seg = 7'b0000110;
  15:  bcdto7seg = 7'b0001110;
  default:  bcdto7seg = 7'b1111111; //blank	
 endcase
endfunction

function [7:0] binarytoBCD;
	input [5:0] binary;
	reg [3:0] digit2, digit1;
	integer i;
	digit2 = 4'b0;
	digit1 = 4'b0;
	for(i = 5; i >= 0; i=i-1) begin
		if(digit1 >= 5) digit1 = digit1 + 3;
		if(digit2 >= 5) digit2 = digit2 + 3;
		
		digit2 = digit2 << 1;
		digit2[0] = digit1[3];
		digit1 = digit1 << 1;
		digit1[0] = binary[i];
	end
	binarytoBCD = {digit2, digit1};
endfunction

assign scoreBCD = binarytoBCD(snakeLength - 14);
assign HEX0 = bcdto7seg(scoreBCD[3:0]);
assign HEX1 = bcdto7seg(scoreBCD[7:4]);
assign HEX2 = bcdto7seg(0);
assign HEX3 = bcdto7seg(0);

assign blockPosX = posX / 10;
assign blockPosY = posY / 10;
assign border = (posX <= 10 || posY <= 10 || posX >= 629 || posY >= 469);
assign gaps = (posX % 10 == 0 || posY % 10 == 0);

assign game_g =	(((blockPosX >= 21 && blockPosX <=23) && blockPosY == 16) ||
				(blockPosX == 20 && (blockPosY >= 17 && blockPosY <= 21)) ||
				((blockPosX >= 21 && blockPosX <=24) && blockPosY == 22) ||
				(blockPosX == 24 && (blockPosY == 20 || blockPosY == 21)) ||
				(blockPosX == 23 && blockPosY == 20) ||
				(blockPosX == 24 && blockPosY == 17)
				);
assign game_a =	(((blockPosX == 26 || blockPosX == 30) && (blockPosY >= 18 && blockPosY <= 22)) ||
				((blockPosX >= 27 && blockPosX <= 29) && blockPosY == 20) ||
				((blockPosX == 27 || blockPosX == 29) && blockPosY == 17) ||
				(blockPosX == 28 && blockPosY == 16)
				);
assign game_m =	(((blockPosX == 32 || blockPosX == 36) && (blockPosY >= 16 && blockPosY <= 22)) ||
				((blockPosX == 33 || blockPosX == 35) && blockPosY == 18) ||
				(blockPosX == 34 && blockPosY == 19)
				);
assign game_e =	((blockPosX == 38 && (blockPosY >= 16 && blockPosY <= 22)) ||
				((blockPosX >= 39 && blockPosX <= 42) && (blockPosY == 16 || blockPosY == 22)) ||
				((blockPosX >= 39 && blockPosX <= 41) && blockPosY == 19)
				);

assign over_o =	(((blockPosX == 20 || blockPosX == 24) && (blockPosY >= 25 && blockPosY <= 29)) ||
				((blockPosX >= 21 && blockPosX <= 23) && (blockPosY == 24 || blockPosY == 30))
				);
assign over_v =	(((blockPosX == 26 || blockPosX == 30) && (blockPosY >= 24 && blockPosY <= 28)) ||
				((blockPosX == 27 || blockPosX == 29) && blockPosY == 29) ||
				(blockPosX == 28 && blockPosY == 30)
				);
assign over_e =	((blockPosX == 32 && (blockPosY >= 24 && blockPosY <= 30)) ||
				((blockPosX >= 33 && blockPosX <= 36) && (blockPosY == 24 || blockPosY == 30)) ||
				((blockPosX >= 33 && blockPosX <= 35) && blockPosY == 27)
				);
assign over_r =	((blockPosX == 38 && (blockPosY >= 24 && blockPosY <= 30)) ||
				((blockPosX >= 39 && blockPosX <= 41) && (blockPosY == 24 || blockPosY == 27)) ||
				(blockPosX == 42 && (blockPosY == 25 || blockPosY == 26)) ||
				(blockPosX == 40 && blockPosY == 28) ||
				(blockPosX == 41 && blockPosY == 29) ||
				(blockPosX == 42 && blockPosY == 30)
				);
				
assign gameover_letters =	(game_g || game_a || game_m || game_e ||
							over_o || over_v || over_e || over_r
							);

hvsyncgenerator hvsyncgenerate(CLOCK_50, 1, VGA_HS, VGA_VS, rgboff, posX, posY);
counter #(26, 1) cnt50M(CLOCK_50, 1, 1, N, 0, cnt, (DIR_PE || DIR_NE), N);
counter #(38, 1) cnt180B(CLOCK_50, 1, 1, 180_000_000_000, 0, cnt2, 0, 0);

edgedetect pb0ne(CLOCK_50, PB[0],,PB0_NE);
edgedetect pb3ne(CLOCK_50, PB[3],,PB3_NE);
edgedetect dirEdge(CLOCK_50, dir[0], DIR_PE, DIR_NE);

// control direction
always @(posedge CLOCK_50) begin
	if (dir == 0 || dir == 2) begin
		if (PB3_NE)
			dir <= 3;
		else if (PB0_NE)
			dir <= 1;
	end
	else if (dir == 1 || dir == 3) begin
		if (PB3_NE)
			dir <= 2;
		else if (PB0_NE)
			dir <= 0;
	end
	if (SW[9])
		dir <= 0;
end

// move snake
always @(posedge CLOCK_50) begin
	if (SW[9]) begin
		gameState <= 0;
		for (i = 0; i < length; i = i + 1) begin
			storedX[i] <= 0;
			storedY[i] <= 0;
		end
		
		foodX <= 43;
		foodY <= 23;
		storedX[13] <= 23;
		storedY[13] <= 23;
		storedX[12] <= 22;
		storedY[12] <= 23;
		storedX[11] <= 21;
		storedY[11] <= 23;
		storedX[10] <= 20;
		storedY[10] <= 23;
		storedX[9] <= 19;
		storedY[9] <= 23;
		storedX[8] <= 18;
		storedY[8] <= 23;
		storedX[7] <= 17;
		storedY[7] <= 23;
		storedX[6] <= 16;
		storedY[6] <= 23;
		storedX[5] <= 15;
		storedY[5] <= 23;
		storedX[4] <= 14;
		storedY[4] <= 23;
		storedX[3] <= 13;
		storedY[3] <= 23;
		storedX[2] <= 12;
		storedY[2] <= 23;
		storedX[1] <= 11;
		storedY[1] <= 23;
		storedX[0] <= 10;
		storedY[0] <= 23;
		snakeLength <= 14;
	end
	else
		if (gameState != 2)
			gameState <= 1;
	
	if (cnt == N && gameState == 1 && !SW[8]) begin
		if (foodY == 0 || foodY > 45)
			foodY <= 23;
		case (dir)
			// right
			0:	begin
					if (storedX[snakeLength - 1] < 62) begin
						if (storedX[snakeLength - 1] + 1 == foodX && storedY[snakeLength - 1] == foodY) begin
							storedX[snakeLength] <= foodX;
							storedY[snakeLength] <= foodY;
							snakeLength <= snakeLength + 1;
							foodX <= (cnt2 % 61) + 1;
							foodY <= ((cnt2 + (snakeLength * cnt)) % 45) + 1;
						end
						else begin
							for (x = 0; x < length - 1; x = x + 1) begin
								storedX[x] <= storedX[x + 1];
								storedY[x] <= storedY[x + 1];
								if	(storedX[x + 1] == storedX[snakeLength - 1] + 1 && 
									storedY[x + 1] == storedY[snakeLength - 1])
									begin
										gameState <= 2;
										disable break;
									end
							end
							storedX[snakeLength - 1] <= storedX[snakeLength - 1] + 1;
							storedY[snakeLength - 1] <= storedY[snakeLength - 1];
						end
					end
					else
						gameState <= 2;
				end
				
			// down
			1:	begin
					if (storedY[snakeLength - 1] < 46) begin
						if (storedX[snakeLength - 1] == foodX && storedY[snakeLength - 1] + 1 == foodY) begin
							storedX[snakeLength] <= foodX;
							storedY[snakeLength] <= foodY;
							snakeLength <= snakeLength + 1;
							foodX <= (cnt2 % 61) + 1;
							foodY <= ((cnt2 + (snakeLength * cnt)) % 45) + 1;
						end
						else begin
							for (x = 0; x < length - 1; x = x + 1) begin
								storedX[x] <= storedX[x + 1];
								storedY[x] <= storedY[x + 1];
								if	(storedX[x + 1] == storedX[snakeLength - 1] && 
									storedY[x + 1] == storedY[snakeLength - 1] + 1)
									begin
										gameState <= 2;
										disable break;
									end
							end
							storedX[snakeLength - 1] <= storedX[snakeLength - 1];
							storedY[snakeLength - 1] <= storedY[snakeLength - 1] + 1;
						end
					end
					else
						gameState <= 2;
				end
				
			// left
			2:	begin
					if (storedX[snakeLength - 1] > 1) begin
						if (storedX[snakeLength - 1] - 1 == foodX && storedY[snakeLength - 1] == foodY) begin
							storedX[snakeLength] <= foodX;
							storedY[snakeLength] <= foodY;
							snakeLength <= snakeLength + 1;
							foodX <= (cnt2 % 61) + 1;
							foodY <= ((cnt2 + (snakeLength * cnt)) % 45) + 1;
						end
						else begin
							for (x = 0; x < length - 1; x = x + 1) begin
								storedX[x] <= storedX[x + 1];
								storedY[x] <= storedY[x + 1];
								if	(storedX[x + 1] == storedX[snakeLength - 1] - 1 && 
									storedY[x + 1] == storedY[snakeLength - 1])
									begin
										gameState <= 2;
										disable break;
									end
							end
							storedX[snakeLength - 1] <= storedX[snakeLength - 1] - 1;
							storedY[snakeLength - 1] <= storedY[snakeLength - 1];
						end
					end
					else
						gameState <= 2;
				end
				
			// up
			3:	begin
					if (storedY[snakeLength - 1] > 1) begin
						if (storedX[snakeLength - 1] == foodX && storedY[snakeLength - 1] - 1 == foodY) begin
							storedX[snakeLength] <= foodX;
							storedY[snakeLength] <= foodY;
							snakeLength <= snakeLength + 1;
							foodX <= (cnt2 % 61) + 1;
							foodY <= ((cnt2 + (snakeLength * cnt)) % 45) + 1;
						end
						else begin
							for (x = 0; x < length - 1; x = x + 1) begin
								storedX[x] <= storedX[x + 1];
								storedY[x] <= storedY[x + 1];
								if	(storedX[x + 1] == storedX[snakeLength - 1] && 
									storedY[x + 1] == storedY[snakeLength - 1] - 1)
									begin
										gameState <= 2;
										disable break;
									end
							end
							storedX[snakeLength - 1] <= storedX[snakeLength - 1];
							storedY[snakeLength - 1] <= storedY[snakeLength - 1] - 1;
						end
					end
					else
						gameState <= 2;
				end
			
		endcase
	end
end

// game states + VGA_RGB
always @(posedge CLOCK_50) begin
	case (gameState)
		0:	begin // reset to initial
				if (rgboff) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
				else if (border) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end
				else begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
			end
		1:	begin
				//holderX <= blockPosX;
				//holderY <= blockPosY;
				blockFound <= 0;
				
				for (i = 0; i < length; i = i + 1) begin
					if (storedX[i] == blockPosX && storedY[i] == blockPosY)
						blockFound <= 1;
				end
				
				if (rgboff) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
				else if (border && (foodX == blockPosX && foodY == blockPosY)) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
				else if (border && !SW[7]) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end
				else if (gaps) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end/*
				else if (storedX[0] == blockPosX && storedY[0] == blockPosY) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end*/
				else if (blockFound && (foodX == blockPosX && foodY == blockPosY)) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b1000;
					VGA_B <= 4'b1111;
				end
				else if (blockFound && (storedX[snakeLength - 1] == blockPosX && storedY[snakeLength - 1] == blockPosY)) begin
					VGA_R <= 4'b1000;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b0000;
				end
				else if (blockFound || (foodX == blockPosX && foodY == blockPosY)) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end
				else begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
			end
		2:	begin //show gameover
				if (rgboff) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
				else if (border) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end
				else if (gaps) begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
				else if (gameover_letters) begin
					VGA_R <= 4'b1111;
					VGA_G <= 4'b1111;
					VGA_B <= 4'b1111;
				end
				else begin
					VGA_R <= 4'b0000;
					VGA_G <= 4'b0000;
					VGA_B <= 4'b0000;
				end
			end
	endcase
end

endmodule

module counter(clk, rst, en, target, u_d, q, pLoadControl, pLoad);
parameter N = 4, initialq = 0;
input clk, rst, en, u_d, pLoadControl;
input [N-1:0] target, pLoad;
output [N-1:0] q;
reg [N-1:0] q;

initial q = initialq;
always @(posedge clk)
	if (!rst)          q <= initialq;
	else if (pLoadControl) begin
		if (pLoad > target) q <= target;
		else q <= pLoad;
	end
	else
		if (en) begin
			if (q == target && !u_d) q <= initialq;
			else if(q == initialq && u_d) q <= target;
			else
				if(!u_d) q <= q + 1;
				else q <= q - 1;
     end
  
endmodule

module hvsyncgenerator(clk, rst, hsync, vsync, rgboff, posX, posY);
input clk, rst;
output hsync, vsync, rgboff;
output [9:0] posX;
output [8:0] posY;
reg hsync, vsync, hrgboff, vrgboff;
reg [1:0] state, vstate;
reg [10:0] cnt;
reg [8:0] posY;

initial begin
	hsync = 0;
	vsync = 0;
	hrgboff = 1;
	vrgboff = 1;
	cnt = 1;
	posY = 0;
	state = 0;
	vstate = 0;
end

assign rgboff = hrgboff | vrgboff;
assign posX = (cnt + 1)/2;

always @(posedge clk) begin
	if (!rst) begin
		hsync <= 1;
		hrgboff <= 1;
		cnt <= 1;
		state <= 0;
	end
	else begin
		if (cnt > 1270) cnt <= 1;
		else cnt <= cnt + 1;
	end
	
	case (state)
		0:	begin
				hsync <= 0;
				if (cnt == 190) begin
					hsync <= 1;
					hrgboff <= 1;
					cnt <= 1;
					state <= 1;
				end
			end
		1:	begin
				if (cnt == 95) begin
					hrgboff <= 0;
					cnt <= 1;
					state <= 2;
				end
			end
		2:	begin
				if (cnt == 1270) begin
					hrgboff <= 1;
					cnt <= 1;
					state <= 3;
				end
			end
		3:	begin
				if (cnt == 30) begin
					hsync <= 0;
					cnt <= 1;
					state <= 0;
				end
			end
	endcase
end

always @(posedge hsync) begin
	if (!rst) begin
		vsync <= 1;
		vrgboff <= 1;
		posY <= 0;
	end
	else begin
		if (posY > 480) posY <= 1;
		else posY <= posY + 1;
	end
	
	case (vstate)
		0:	begin
				vsync <= 0;
				if (posY == 2) begin
					vsync <= 1;
					vrgboff <= 1;
					posY <= 1;
					vstate <= 1;
				end
			end
		1:	begin
				if (posY == 33) begin
					vrgboff <= 0;
					posY <= 1;
					vstate <= 2;
				end
			end
		2:	begin
				if (posY == 480) begin
					vrgboff <= 1;
					posY <= 1;
					vstate <= 3;
				end
			end
		3:	begin
				if (posY == 10) begin
					vsync <= 0;
					posY <= 1;
					vstate <= 0;
				end
			end
	endcase
end

endmodule

module edgedetect(clk, input1, out_posedge, out_negedge);
input clk, input1;
output out_posedge, out_negedge;
reg out_posedge, out_negedge, input1n;

always @(posedge clk) begin
	input1n <= ~input1;
	out_posedge <= input1n & input1;
	out_negedge <= ~(input1n | input1);
end

endmodule
