
`timescale 1ns / 1ps

module RISCV_pipeline(
    input clk,
    input rst,
    
     //added for the fpga testing
    input [1:0] ledSel,
    input [3:0] ssdSel,
    output reg [15:0] leds,
    output reg [12:0] ssdData
);


wire [31:0] PCIn;
wire [31:0] PCout;
wire [31:0] PCAdder1Out;
wire [31:0] inst;
wire [31:0] EX_MEM_BranchAddOut;
wire and_out;
wire PC_Write, IF_ID_Write, Stall_IF, stall;
wire [31:0] ALUSrc1, ALUSrc2_mux;
wire [31:0] EX_MEM_ALUresult, EX_MEM_PCPlus4;
wire [4:0]  EX_MEM_Ctrl, EX_MEM_Rd;
assign PCAdder1Out = PCout + 32'd4;

NBit_Mux2x1 PCMux(
    PCAdder1Out,
    EX_MEM_BranchAddOut,
    and_out,
    PCIn
);

NBitRegister #(.N(32)) PCreg(
    .clk(clk),
    .rst(rst),
    .load(PC_Write),                           // now updating the PC is determined by whether we stall or not (the signal coming from the hazard detection unit)
    .D(PCIn),
    .Q(PCout)
);





wire [31:0] IF_ID_PC;
wire [31:0] IF_ID_Inst;

// add 
wire [31:0] IF_ID_NextInst;

assign IF_ID_NextInst =(and_out || Stall_IF)? 32'h00000013  : inst;

NBitRegister #(.N(64)) IF_ID(
    .clk(clk),
    .rst(rst),
    .load(IF_ID_Write),                   // IF_ID is 0 when we stall (hazard detection unit)
    .D({PCout, IF_ID_NextInst}),
    .Q({IF_ID_PC, IF_ID_Inst})
);



wire [31:0] IF_ID_ReadData1;
wire [31:0] IF_ID_ReadData2;
wire [31:0] IF_ID_immgenout;
wire [31:0] WriteData;

wire Branch;
wire MemRead;

// to suppory all 6 and jump inst 
wire Jump;
wire JalrSel;

wire ID_EX_Jump;
wire ID_EX_JalrSel;
wire [31:0] ID_EX_Target;

wire EX_MEM_Jump;
wire [31:0] EX_MEM_Target;
wire EX_MEM_BranchTaken;



wire MemtoReg;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire [1:0] ALUOp;

// Writeback signals
wire [4:0] MEM_WB_Rd;
wire [1:0] MEM_WB_Ctrl;

RegisterFile RG(
    clk,
    rst,
    IF_ID_Inst[19:15],
    IF_ID_Inst[24:20],
    MEM_WB_Rd,
    WriteData,
    MEM_WB_Ctrl[1],
    IF_ID_ReadData1,
    IF_ID_ReadData2
);

wire Halt;

ControlUnit CU1(
    IF_ID_Inst,
    Branch,
    MemRead,
    MemtoReg,
    ALUOp,
    MemWrite,
    ALUSrc,
    RegWrite, 
    Jump, 
    JalrSel, 
    Halt
);

ImmGen immg1(
    IF_ID_Inst,
    IF_ID_immgenout
);


wire [31:0] ID_EX_PC;

// for jal/jalr writeback 
wire [31:0] ID_EX_PCPlus4;
assign ID_EX_PCPlus4 = ID_EX_PC + 32'd4;



wire [31:0] ID_EX_ReadData1;
wire [31:0] ID_EX_ReadData2;
wire [31:0] ID_EX_Imm;

wire [7:0] ID_EX_Ctrl;
wire [3:0] ID_EX_Func;
wire [4:0] ID_EX_Rs1;
wire [4:0] ID_EX_Rs2;
wire [4:0] ID_EX_Rd;

wire ID_EX_IsRType; 

wire IsRType;

assign IsRType = (IF_ID_Inst[6:0] == 7'b0110011);

wire IsAuipc;

assign IsAuipc = (IF_ID_Inst[6:0] == 7'b0010111);
wire ID_EX_IsAuipc;

//======================bonus =============================================
wire IsMType;
wire IsLui;
wire ID_EX_IsLui;

assign IsLui = (IF_ID_Inst[6:0] == 7'b0110111);
// M-Extension shares the R-type opcode, but funct7 (bit 25) is 1
assign IsMType = (IF_ID_Inst[6:0] == 7'b0110011) && (IF_ID_Inst[25] == 1'b1);
// ==================================================================================






// Branch redirect must have priority over stalls
// PC_Write only allows updates if we are not Halting
assign PC_Write = (and_out || !(stall || Stall_IF)) && !Halt;



// Hold IF/ID only for a load-use dependency.
// Structural hazards will insert a bubble instead.
assign IF_ID_Write = (and_out || !stall) && !Halt;
                        // IF_ID_Rs1 , IF_ID_Rs2
HazardDetectionUnit  hdu(IF_ID_Inst[19:15],IF_ID_Inst[24:20],ID_EX_Rd,ID_EX_Ctrl[4],stall);




// ========================================================




//  ====================  control signals  ===================


wire [7:0] raw_control_signals = {RegWrite, MemtoReg, Branch, MemRead, MemWrite, ALUSrc, ALUOp};
wire [7:0] muxed_control_signals;
// added this 
assign muxed_control_signals = (stall || and_out) ? 8'b0 : raw_control_signals;




// fix no of bits 
// added jump and jalr
// Increased N from 158 to 159
wire ID_EX_IsMType;
NBitRegister #(.N(161)) ID_EX(   
    .clk(clk),
    .rst(rst),
    .load(1'b1),

    .D({
        muxed_control_signals, 
        (Jump && !stall && !and_out),
        (JalrSel && !stall && !and_out),                // become zero upon stalling
        (IsRType && !stall && !and_out), // added here 
        (IsMType && !stall && !and_out), // Added IsMType
        (IsAuipc && !stall && !and_out),
        (IsLui && !stall && !and_out),
        IF_ID_PC,
        IF_ID_ReadData1,
        IF_ID_ReadData2,
        IF_ID_immgenout,
        IF_ID_Inst[30],
        IF_ID_Inst[14:12],
        IF_ID_Inst[19:15],
        IF_ID_Inst[24:20],
        IF_ID_Inst[11:7]
    }),

    .Q({
        ID_EX_Ctrl,
        ID_EX_Jump, 
        ID_EX_JalrSel, 
        ID_EX_IsRType, // added 
        ID_EX_IsMType, // Added IsMType
        ID_EX_IsAuipc,
        ID_EX_IsLui,
        ID_EX_PC,
        ID_EX_ReadData1,
        ID_EX_ReadData2,
        ID_EX_Imm,
        ID_EX_Func,
        ID_EX_Rs1,
        ID_EX_Rs2,
        ID_EX_Rd
    })
);



wire [31:0] ID_EX_shiftleftout;
wire [31:0] ID_EX_sum;
wire [31:0] ID_EX_mux;
wire [31:0] ID_EX_ALUresult;

wire ID_EX_ZeroFlag;
wire [3:0] ID_EX_ALUSel;

NBitShitLeft1 sll(
    ID_EX_Imm,
    ID_EX_shiftleftout
);

// was shifting twice 
assign ID_EX_sum = ID_EX_PC + ID_EX_Imm;
// pc relative branches/jal and jalr 
assign ID_EX_Target = ID_EX_JalrSel? ((ALUSrc1 + ID_EX_Imm) & 32'hFFFFFFFE): ID_EX_sum;


ALUControlUnit ALUCU(
    ID_EX_Ctrl[1:0],
    ID_EX_Func[2:0],
    ID_EX_Func[3],
    ID_EX_IsRType,
    ID_EX_ALUSel
);

ALU alu(
    ALUSrc1,
    ID_EX_mux,
    ID_EX_ALUSel,
    ID_EX_ALUresult,
    ID_EX_ZeroFlag
);




// ==============bonus====================


wire [31:0] MulDivResult;
MultiplierDivider mult_div(
    .A(ALUSrc1),
    .B(ALUSrc2_mux),
    .funct3(ID_EX_Func[2:0]),
    .Result(MulDivResult)
);


//===========================================
// Mux between ALU and Multiplier/Divider
wire [31:0] EX_FinalResult;
assign EX_FinalResult =
    ID_EX_IsLui   ? ID_EX_Imm :
    ID_EX_IsAuipc ? ID_EX_sum :
    ID_EX_IsMType ? MulDivResult :
                    ID_EX_ALUresult; 


wire [1:0] forwardA; 
wire [1:0] forwardB; 
wire [31:0] EX_MEM_ForwardData; //added 

assign EX_MEM_ForwardData = EX_MEM_Jump ? EX_MEM_PCPlus4 : EX_MEM_ALUresult;

ForwardingUnit fu( 
ID_EX_Rs1,
ID_EX_Rs2,
EX_MEM_Ctrl[4],
MEM_WB_Ctrl[1],
EX_MEM_Rd,
MEM_WB_Rd,
forwardA,
forwardB);



mux4x1 forward_A_mux( 
  ID_EX_ReadData1, 
  WriteData, 
  EX_MEM_ForwardData, 
  32'b0, 
  forwardA,
  ALUSrc1 
  
  ); 
  
  mux4x1 forward_B_mux( 
  ID_EX_ReadData2, 
  WriteData, 
  EX_MEM_ForwardData, 
  32'b0, 
  forwardB,
  ALUSrc2_mux 
  
  ); 
  
  // all branch comparisosns
 wire BranchCondition; 
 
 assign BranchCondition = (ID_EX_Func[2:0] == 3'b000 && ALUSrc1 == ALUSrc2_mux) || (ID_EX_Func[2:0] == 3'b001 && ALUSrc1 != ALUSrc2_mux) || (ID_EX_Func[2:0] == 3'b100 && $signed(ALUSrc1) < $signed(ALUSrc2_mux)) || (ID_EX_Func[2:0] == 3'b101 && $signed(ALUSrc1) >= $signed(ALUSrc2_mux)) || (ID_EX_Func[2:0] == 3'b110 && ALUSrc1 < ALUSrc2_mux) || (ID_EX_Func[2:0] == 3'b111 && ALUSrc1 >= ALUSrc2_mux);
 
NBit_Mux2x1 Data2Mux(
    ALUSrc2_mux,
    ID_EX_Imm,
    ID_EX_Ctrl[2],
    ID_EX_mux
);  
  

















wire [31:0] EX_MEM_ReadData2;
wire EX_MEM_Zero;
wire [2:0] EX_MEM_Funct3; //added for ex/mem memory controls
wire [4:0]x1;
wire x2;


assign  x1=and_out ? 5'd0 : ID_EX_Ctrl[7:3];
assign x2= and_out ? 1'b0 : ID_EX_Jump;
 
//added 3 bits for func3
// added the jump bit and branch condition 
// adjusted again for pc+4 
NBitRegister #(.N(143)) EX_MEM(
    .clk(clk),
    .rst(rst),
    .load(1'b1),
.D({
    x1,
    ID_EX_Func[2:0],
    x2,
    ID_EX_Target,
    BranchCondition,
    EX_FinalResult,          // Replaced ID_EX_ALUresult with EX_FinalResult
    ALUSrc2_mux,
    ID_EX_PCPlus4, 
    ID_EX_Rd
}),

.Q({
    EX_MEM_Ctrl,
    EX_MEM_Funct3,
    EX_MEM_Jump,
    EX_MEM_BranchAddOut,
    EX_MEM_BranchTaken,
    EX_MEM_ALUresult,          // This now contains either the ALU or Mul/Div result
    EX_MEM_ReadData2,
    EX_MEM_PCPlus4,
    EX_MEM_Rd
})
);


wire [31:0] EX_MEM_ReadDataOut;
// add the new wires 
wire IF_Request;
wire MEM_Request;
wire [31:0] SharedMemoryAddress;
wire Grant_IF;
wire Grant_MEM;
//wire Stall_IF;
// shared memory controls
wire SharedInstrFetch;
wire SharedMemRead;
wire SharedMemWrite;
wire [31:0] SharedMemoryData;


// IF normally requests the next instruction
assign IF_Request = 1'b1;

// MEM requests the port for a load or store
assign MEM_Request =
    EX_MEM_Ctrl[1] | EX_MEM_Ctrl[0];

// Enable only the granted operation
assign SharedInstrFetch = Grant_IF;

assign SharedMemRead =
    Grant_MEM & EX_MEM_Ctrl[1];

assign SharedMemWrite =
    Grant_MEM & EX_MEM_Ctrl[0];

// Select which stage gets the memory address
MemoryArbiter arbiter (
    .IF_Request(IF_Request),
    .IF_Address(PCout),
    .MEM_Request(MEM_Request),
    .MEM_Address(EX_MEM_ALUresult),

    .Memory_Address(SharedMemoryAddress),
    .Grant_IF(Grant_IF),
    .Grant_MEM(Grant_MEM),
    .Stall_IF(Stall_IF)
);

// One shared physical memory
UnifiedMemory shared_memory (
    .clk(clk),

    .InstrFetch(SharedInstrFetch),
    .MemRead(SharedMemRead),
    .MemWrite(SharedMemWrite),

    // Temporary: word accesses only
    .MemSize(EX_MEM_Funct3[1:0]),
    .LoadUnsigned(EX_MEM_Funct3[2]),

    .addr(SharedMemoryAddress),
    .data_in(EX_MEM_ReadData2),
    .data_out(SharedMemoryData)
);

// now we return the fetched instruction to the IF stage
assign inst = Grant_IF
            ? SharedMemoryData
            : 32'h00000013;

// Return loaded data to the MEM stage
assign EX_MEM_ReadDataOut =
    (Grant_MEM && EX_MEM_Ctrl[1])
    ? SharedMemoryData
    : 32'b0;




// Branch decision
assign and_out =(EX_MEM_Ctrl[2] && EX_MEM_BranchTaken)|| EX_MEM_Jump;



wire [31:0] MEM_WB_ReadDataOut;
wire [31:0] MEM_WB_ALUresult;
wire MEM_WB_Jump;
wire [31:0] MEM_WB_PCPlus4;


NBitRegister #(.N(104)) MEM_WB(
    .clk(clk),
    .rst(rst),
    .load(1'b1),

    .D({
        EX_MEM_Ctrl[4:3],
        EX_MEM_Jump, 
        EX_MEM_ReadDataOut,
        EX_MEM_ALUresult,
        EX_MEM_PCPlus4,
        EX_MEM_Rd
    }),

    .Q({
        MEM_WB_Ctrl,
        MEM_WB_Jump, 
        MEM_WB_ReadDataOut,
        MEM_WB_ALUresult,
        MEM_WB_PCPlus4, 
        MEM_WB_Rd
    })
);




assign WriteData = MEM_WB_Jump ? MEM_WB_PCPlus4 : 
                   MEM_WB_Ctrl[0] ? MEM_WB_ReadDataOut : 
                   MEM_WB_ALUresult;





always @(*) begin
    case (ledSel)
        2'b00: leds = inst[15:0];

        2'b01: leds = inst[31:16];

        2'b10: leds = {
            2'b00,
            Branch,
            MemRead,
            MemtoReg,
            MemWrite,
            ALUSrc,
            RegWrite,
            ALUOp,
            ID_EX_ALUSel,
            ID_EX_ZeroFlag,
            and_out
        };

        2'b11: leds = {
            12'b0,
            forwardA,
            forwardB
        };

        default: leds = 16'b0;
    endcase
end




always @(*) begin
    case (ssdSel)
        4'b0000: ssdData = PCout[12:0];

        4'b0001: ssdData = PCAdder1Out[12:0];

        4'b0010: ssdData = EX_MEM_BranchAddOut[12:0];

        4'b0011: ssdData = PCIn[12:0];

        4'b0100: ssdData = IF_ID_ReadData1[12:0];

        4'b0101: ssdData = IF_ID_ReadData2[12:0];

        4'b0110: ssdData = WriteData[12:0];

        4'b0111: ssdData = IF_ID_immgenout[12:0];

        4'b1000: ssdData = ID_EX_shiftleftout[12:0];

        4'b1001: ssdData = ID_EX_mux[12:0];

        4'b1010: ssdData = ID_EX_ALUresult[12:0];

        4'b1011: ssdData = EX_MEM_ReadDataOut[12:0];

        4'b1100: ssdData = {8'b0, MEM_WB_Rd};

        4'b1101: ssdData = ALUSrc1[12:0];

        4'b1110: ssdData = ALUSrc2_mux[12:0];

        4'b1111: ssdData = EX_MEM_ALUresult[12:0];

        default: ssdData = 13'b0;
    endcase
end




endmodule
