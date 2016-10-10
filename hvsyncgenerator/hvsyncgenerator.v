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
		hrgboff <= 0;
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
		1:  begin
				if (posY == 33) begin
					vrgboff <= 0;
					posY <= 1;
					vstate <= 2;
				end
			end
		2:  begin
				if (posY == 480) begin
					vrgboff <= 1;
					posY <= 1;
					vstate <= 3;
				end
			end
		3:  begin
				if (posY == 10) begin
					vsync <= 0;
					posY <= 1;
					vstate <= 0;
				end
			end
	endcase
end

endmodule
