module  CONTROL(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
input clk,
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] opcode,
    output  [3:0] alu_control,
    output  regwrite_control
);
reg [3:0]alureg;
reg writecontrol;
always @(posedge clk)
    begin
        if (opcode == 7'b0110011) 
        begin // R-type instructions
		writecontrol <= 1;

            case (funct3)
                0: begin
                    if(funct7 == 0)
                   alureg<= 4'b0010; // ADD
                    else if(funct7 == 32)
                    alureg<= 4'b0100; // SUB
                end
                6: alureg<= 4'b0001; // OR
                7: alureg <= 4'b0000; // AND
                1: alureg <= 4'b0011; // SLL
                5: alureg <= 4'b0101; // SRL
		2: alureg <= 4'b0110; // MUL
		4: alureg <= 4'b0111; // XOR
            endcase

      end

    end
assign alu_control=alureg;
assign  regwrite_control=writecontrol;
endmodule
