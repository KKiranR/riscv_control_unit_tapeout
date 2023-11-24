// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_control #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    /*input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,*/
   // output wbs_ack_o,
   // output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
 //  input  [127:0] la_data_in,
    //output [127:0] la_data_out,
  //  input  [127:0] la_oenb,

    // IOs
    input  [19:0] io_in,
    output [4:0] io_out,
  //  output [15:0] io_oeb,

    // IRQ
 //   output [2:0] irq
);
    wire clk;
    wire [6:0]funct7;
    wire[2:0]funct3;
    wire [6:0] opcode;
    wire [3:0] alu_control;
    wire regwrite_control;

   assign clk=wb_clk_i;
    assign {funct7,funct3,opcode}=io_in[19:0];
    assign io_out[4:0]={alu_control,regwrite_control};
    CONTROL  dut(clk,funct7,funct3,opcode,alu_control,regwrite_control);

endmodule

module  CONTROL(
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
		writecontrol = 1;

            case (funct3)
                0: begin
                    if(funct7 == 0)
                   alureg= 4'b0010; // ADD
                    else if(funct7 == 32)
                    alureg= 4'b0100; // SUB
                end
                6: alureg = 4'b0001; // OR
                7: alureg = 4'b0000; // AND
                1: alureg = 4'b0011; // SLL
                5: alureg = 4'b0101; // SRL
		2: alureg = 4'b0110; // MUL
		4: alureg = 4'b0111; // XOR
            endcase

      end

    end
assign alu_control=alureg;
assign  regwrite_control=writecontrol;
endmodule
`default_nettype wire
