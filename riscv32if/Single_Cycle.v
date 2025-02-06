//1 Program Counter

module Program_Counter(clk, reset, PC_in, PC_out);
    input clk, reset;
    input [31:0] PC_in;
    output reg [31:0] PC_out;
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule

module PCplus4(fromPC, NextoPC);
    input [31:0] fromPC;
    output [31:0] NextoPC;
    assign NextoPC = fromPC + 4;
endmodule


module Instruction_Mem(clk, reset, read_address, instructions_out);
    input clk, reset;
    input [31:0] read_address;
    output [31:0] instructions_out;
    
    integer k;
    reg [31:0] IMemory[256:0];  // 256 word

    assign instructions_out = IMemory[read_address[31:2]];

    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin 
            for(k=0; k<64; k=k+1) begin
                IMemory[k] <= 32'b0;
            end
        end
        else 
        begin
            // floating siralama  n değeri register 2'de önceden belirlenmeli
            IMemory[0]  = 32'b00000000000000000000000000000000; // nop
            IMemory[1]  = 32'h00000293;				//addi   x5, x0, 0
			IMemory[2] = 32'h04228263;				//beq    x5, x2, done  #if (i == n) => done		:outer_loop
			IMemory[3] = 32'h00000313;				//addi   x6, x0, 0       # j = 0
			IMemory[4] = 32'h405103b3;				//sub    x7, x2, x5      # x7 = n - i  			:inner_loop
			IMemory[5] = 32'hfff38393;				//addi   x7, x7, -1      # x7 = n - i - 1
			IMemory[6] = 32'h02730663;				//beq    x6, x7, inner_done
			IMemory[7] = 32'h00231413;				//slli   x8, x6, 2       # x8 = j << 2  (j * 4)
			IMemory[8] = 32'h008084b3;				//add    x9, x1, x8      # x9 = base + j*4
			IMemory[9] = 32'h0004a503;				//lw     x10, 0(x9)      # x10 = array[j]
			IMemory[10] = 32'h0044a583;				//lw     x11, 4(x9)      # x11 = array[j+1]
			IMemory[11] = 32'h00A5C473;				//fblt   x11, x10, swap
			IMemory[12] = 32'h00000663;				//beq x0, x0,       no_swap
			IMemory[13] = 32'h00a4a223;				//sw     x10, 4(x9)      # array[j+1] = x10 :swap
			IMemory[14] = 32'h00b4a023;				//sw     x11, 0(x9)      # array[j]   = x11
			IMemory[15] = 32'h00130313;				//addi   x6, x6, 1							:no_swap
			IMemory[16] = 32'hfc0008e3;				//beq x0, x0,      inner_loop
			IMemory[17] = 32'h00128293;				//addi   x5, x5, 1					:inner_done
			IMemory[18] = 32'hfc0000e3;				//beq x0, x0,      outer_loop
			IMemory[19] = 32'h00000063;				//beq x0, x0,      done 			:done
			
			
			
			
        end
    end
endmodule



// Register File

module Reg_File(clk, reset, RegWrite, Rs1, Rs2, Rd, Write_data, read_data1, read_data2);
    input clk, reset, RegWrite;
    input [4:0] Rs1,Rs2,Rd;
    input [31:0] Write_data;
    output [31:0] read_data1, read_data2;
    
    reg [31:0] Registers[31:0];
    integer k;
    
    initial begin
        Registers[0] = 0;  
        Registers[1] = 0;  
        Registers[2] = 8;   //dizideki eleman sayisi
        Registers[3] = 24;
        Registers[4] = 4;  
        Registers[5] = 0;  
        Registers[6] = 0; 
        Registers[7] = 4;
        Registers[8] = 2;  
        Registers[9] = 1;  
        Registers[10] = 23;  
        Registers[11] = 4;
        Registers[12] = 90; 
        Registers[13] = 10; 
        Registers[14] = 20;  
        Registers[15] = 30;
        Registers[16] = 40; 
        Registers[17] = 50; 
        Registers[18] = 60;  
        Registers[19] = 70;
        Registers[20] = 80; 
        Registers[21] = 80; 
        Registers[22] = 90;  
        //x23: ~3.56
        Registers[23] = 32'b01000000001100000000000000000000; 
        //x24: ~1.75
        Registers[24] = 32'b00111111110000000000000000000000; 
        Registers[25] = 32'b01000000100011001100110011001101; 
        // floatlar
        Registers[26] = 32'b01000000000110011001100110011010;   
        Registers[27] = 32'b00111111100000000000000000000000;
        Registers[28] = 12; 
        Registers[29] = 20; 
        Registers[30] = 5;  
        Registers[31] = 10;
    end

    always @(posedge clk) begin
        if(reset)
        begin 
            for(k=0; k<32;k=k+1)
                Registers[k] = 32'b0;
        end
        else if(RegWrite) begin
            if(Rd != 5'b00000)
                Registers[Rd] = Write_data;
        end
    end

    assign read_data1 = Registers[Rs1];
    assign read_data2 = Registers[Rs2];
endmodule


// Immediate Generator
module ImmGen(output reg [31:0] ImmExt, input [6:0] OpCode, input [31:0] instruction);
always @* begin
    case(OpCode)
        7'b0010011: begin
            // shift immediate ile normal i tiplerini ayir
            if (instruction[14:12] == 3'b001 || instruction[14:12] == 3'b101) begin
                // SHIFT immediate
                ImmExt = {27'b0, instruction[24:20]};
            end else begin
                // I tipi aluop
                ImmExt = {{20{instruction[31]}}, instruction[31:20]};
            end
        end 
        7'b0100011 : ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // store
        7'b1100011 : ImmExt = {{19{instruction[31]}}, instruction[31], instruction[7],
                                instruction[30:25], instruction[11:8], 1'b0}; // branch
        7'b1110011 : begin
            // float dallanma
            ImmExt = {{19{instruction[31]}}, instruction[31], instruction[7],
                      instruction[30:25], instruction[11:8], 1'b0};
        end
        default: ImmExt = {{20{instruction[31]}}, instruction[31:20]};
    endcase
end
endmodule


//Control Unit
module Control_Unit(
    input reset,
    input [6:0] OpCode,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

always @(*) begin
    if(reset) begin
        {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} <= 7'b0000000;
    end
    else begin
        case(OpCode)
            7'b0110011 : begin // R tip (integer)
                ALUSrc   <= 0; 
                MemtoReg <= 0; 
                RegWrite <= 1; 
                MemRead  <= 0; 
                MemWrite <= 0; 
                Branch   <= 0; 
                ALUOp    <= 2'b10;   // R-tip integer
            end
            7'b0010011 : begin // I tip (integer immediate)
                ALUSrc   <= 1; 
                MemtoReg <= 0; 
                RegWrite <= 1; 
                MemRead  <= 0; 
                MemWrite <= 0; 
                Branch   <= 0; 
                ALUOp    <= 2'b00;   // I-tip integer
            end
            7'b0000011 : begin // Load
                ALUSrc   <= 1; 
                MemtoReg <= 1; 
                RegWrite <= 1; 
                MemRead  <= 1; 
                MemWrite <= 0; 
                Branch   <= 0; 
                ALUOp    <= 2'b00;   
            end
            7'b0100011 : begin // Store
                ALUSrc   <= 1; 
                MemtoReg <= 0; 
                RegWrite <= 0; 
                MemRead  <= 0; 
                MemWrite <= 1; 
                Branch   <= 0; 
                ALUOp    <= 2'b00;
            end
            7'b1100011 : begin // integer dallanma (beq/bne/blt/bge/bltu/bgeu)
                ALUSrc   <= 0; 
                MemtoReg <= 0; 
                RegWrite <= 0; 
                MemRead  <= 0; 
                MemWrite <= 0; 
                Branch   <= 1;   
                ALUOp    <= 2'b01; 
            end
            7'b1010011: begin  // "F" aritmetik, single-precision float R-tipi (fadd, fsub, fdiv, etc.)
                ALUSrc   <= 0;        
                MemtoReg <= 0;        
                RegWrite <= 1;        
                MemRead  <= 0;
                MemWrite <= 0;
                Branch   <= 0;
                ALUOp    <= 2'b11;    // float işlemleri
            end
            7'b1110011: begin  // float dallanma (fbeq, fblt, fbge, etc.)
                ALUSrc   <= 0;
                MemtoReg <= 0;
                RegWrite <= 0;  // normalde float branch register değiştirir ama bu normal değil
                MemRead  <= 0;
                MemWrite <= 0;
                Branch   <= 1;  // evet branch olmasın
                ALUOp    <= 2'b11; // float işlemleri
            end
            default: begin
                ALUSrc   <= 0;
                MemtoReg <= 0;
                RegWrite <= 1;
                MemRead  <= 0;
                MemWrite <= 0;
                Branch   <= 0;
                ALUOp    <= 2'b10; // default
            end
        endcase
    end
end
endmodule


// ALU
module ALU_unit(
    input  [31:0] A, 
    input  [31:0] B,
    input  [3:0]  Control_in,
    output reg [31:0] ALU_Result,
    output reg zero,

    // dallanama bayrakları:
    output eq,          // (A == B) integer
    output lt_signed,   // signed(A) < signed(B)
    output lt_unsigned
);

// floatlar için
wire [31:0] fp_out;
reg  [1:0]  fpu_op;
wire fp_eq, fp_lt;

// eq, lt_signed, integer için
reg eq_reg, lt_signed_reg;

assign eq = eq_reg;
assign lt_signed = lt_signed_reg;
assign lt_unsigned = (A < B);

Float_Unit FPU (
  .A(A),
  .B(B),
  .fpu_op(fpu_op),
  .R(fp_out),
  .fp_eq(fp_eq),
  .fp_lt(fp_lt)
);

always @(*) begin
    // Default
    ALU_Result = 32'b0;
    zero = 1'b0;
    eq_reg = (A == B);
    lt_signed_reg = ($signed(A) < $signed(B));
    fpu_op = 2'b00;  // default fadd

    case(Control_in)
      // integer ops:
      4'b0000: ALU_Result = A & B;    // AND
      4'b0001: ALU_Result = A | B;    // OR
      4'b0010: ALU_Result = A + B;    // ADD
      4'b0110: ALU_Result = A ^ B;    // XOR
      4'b0111: ALU_Result = A - B;    // SUB
      4'b1000: begin
         // SLT => set less than signed
         ALU_Result = ( $signed(A) < $signed(B) ) ? 32'b1 : 32'b0;
      end
      4'b0011: ALU_Result = A << B[4:0];           // SLL
      4'b0100: ALU_Result = A >> B[4:0];           // SRL
      4'b0101: ALU_Result = $signed(A) >>> B[4:0]; // SRA

      // float arithmetic
      4'b1100: begin
         // FADD
         fpu_op = 2'b00;
         ALU_Result = fp_out;
      end
      4'b1101: begin
         // FSUB
         fpu_op = 2'b01;
         ALU_Result = fp_out;
      end
      4'b1110: begin
         // FDIV
         fpu_op = 2'b10;
         ALU_Result = fp_out;
      end

      // float compares (as assigned in ALU_Control):
      4'b1001: begin
         // fbeq
         // override eq_reg with fp_eq
         eq_reg = fp_eq;
      end
      4'b1010: begin
         // fblt
         lt_signed_reg = fp_lt; 
      end
      4'b1011: begin
         // fbge => !(A < B)
         // sadece "lt_signed_reg = fp_lt" var o yuzden 
         // dallanmada tersi alınacak
         lt_signed_reg = fp_lt;
      end

      default: ALU_Result = A; 
    endcase

    // "zero" beq kontrolü için
    if(ALU_Result == 32'b0)
        zero = 1'b1;
end

endmodule


// ALU Control
module ALU_Control(ALUOp, fun7, fun3, Control_out);

input [6:0] fun7;
input [14:12] fun3;
input [1:0] ALUOp;
output reg [3:0] Control_out;

/*
  
  integer:
    AND = 4'b0000
    OR  = 4'b0001
    ADD = 4'b0010
    SLL = 4'b0011
    SRL = 4'b0100
    SRA = 4'b0101
    XOR = 4'b0110
    SUB = 4'b0111
    SLT = 4'b1000  

  float:
    FADD= 4'b1100
    FSUB= 4'b1101
    FDIV= 4'b1110
    FBEQ= 4'b1001
    FBLT= 4'b1010
    FBGE= 4'b1011
	
*/

always @(*) begin
    Control_out = 4'b1111; // default
    case(ALUOp)
      2'b00: begin
         // I tipi ama shift immediate mi kontrolu de yapilacak
         if (fun3 == 3'b001 && fun7 == 7'b0000000) begin
             // SLLI
             Control_out = 4'b0011; // integer SLL
         end
         else if (fun3 == 3'b101 && fun7 == 7'b0000000) begin
             // SRLI
             Control_out = 4'b0100; // SRL
         end
         else if (fun3 == 3'b101 && fun7 == 7'b0100000) begin
             // SRAI
             Control_out = 4'b0101; // SRA
         end
         else begin
             // Default add
             Control_out = 4'b0010;
         end
      end

      2'b01: begin
         // integer branch:  fun3
         // beq=000 => SUB
         // bne=001 => SUB
         // blt=100 => SLT(signed)
         // bge=101 => SLT(signed) & invert
         // bltu=110 => ??? (SLTU)
         // bgeu=111 => ??? 
         case(fun3)
           3'b000: Control_out = 4'b0111; // SUB (like beq => we check eq=?)
           3'b001: Control_out = 4'b0111; // bne => ayrıca SUB
           3'b100: Control_out = 4'b1000; // SLT(signed)
           3'b101: Control_out = 4'b1000; // bge => SLT(signed) & tersi
           3'b110: Control_out = 4'b0110; // unsigned
           3'b111: Control_out = 4'b0110; // bgeu => tersi
           default: Control_out = 4'b0111; 
         endcase
      end

      2'b10: begin
         // R-type integer
         // decode by fun7/fun3
         if (fun7 == 7'b0000000) begin
            case(fun3)
              3'b000: Control_out = 4'b0010; // ADD
              3'b111: Control_out = 4'b0000; // AND
              3'b110: Control_out = 4'b0001; // OR
              3'b100: Control_out = 4'b0110; // XOR (we said XOR=4'b0110 now)
              3'b001: Control_out = 4'b0011; // SLL
              3'b101: Control_out = 4'b0100; // SRL
              default: Control_out = 4'b0010;
            endcase
         end
         else if (fun7 == 7'b0100000) begin
            case(fun3)
              3'b000: Control_out = 4'b0111; // SUB
              3'b101: Control_out = 4'b0101; // SRA
              default: Control_out = 4'b0111;
            endcase
         end
         else begin
            // default
            Control_out = 4'b0010;
         end
      end

      2'b11: begin
         // floating ops =>  fun7 veya fun3
         // fadd.s => fun7=0000000, fun3=000
         // fsub.s => fun7=0000100, fun3=000
         // fdiv.s => fun7=0001100, fun3=000
         // floating dallanmalar => fbeq=fun3=000, fblt=100, fbge=101
         if (fun7 == 7'b0000000 && fun3 == 3'b000) begin
             Control_out = 4'b1100; // FADD
         end
         else if (fun7 == 7'b0000100 && fun3 == 3'b000) begin
             Control_out = 4'b1101; // FSUB
         end
         else if (fun7 == 7'b0001100 && fun3 == 3'b000) begin
             Control_out = 4'b1110; // FDIV
         end
         else begin
             // float dallanma
             case(fun3)
               3'b000: Control_out = 4'b1001; // fbeq
               3'b100: Control_out = 4'b1010; // fblt
               3'b101: Control_out = 4'b1011; // fbge
               default: Control_out = 4'b1111; // unknown
             endcase
         end
      end

      default: Control_out = 4'b1111; 
    endcase
end
endmodule


module Float_Unit(
    input  [31:0] A, 
    input  [31:0] B,
    input  [1:0]  fpu_op,    // 00=ADD, 01=SUB, 10=DIV, etc.
    output [31:0] R,

    //float karsilastirmalar icin
    output fp_eq,
    output fp_lt
);

wire signA     = A[31];
wire [7:0] expA = A[30:23];
wire [22:0] fracA = A[22:0];

wire signB     = B[31];
wire [7:0] expB = B[30:23];
wire [22:0] fracB = B[22:0];

// normal floatlar için öncül bit
wire [23:0] mantA = (expA == 8'd0) ? {1'b0, fracA} : {1'b1, fracA};
wire [23:0] mantB = (expB == 8'd0) ? {1'b0, fracB} : {1'b1, fracB};


// Arithmetic sonuclar (ADD/SUB/DIV):
reg  signResult;
reg  [7:0]  expResult;
reg  [24:0] mantResult;      
reg  [47:0] product;         
reg  [47:0] approx_recip;    
reg  [47:0] step;            

localparam [47:0] TWO_Q24 = 48'h2000000;  // (2 << 24)

integer i, shift;

always @* begin
    signResult = 1'b0;
    expResult  = 8'b0;
    mantResult = 25'b0;
    
    case(fpu_op)
      2'b00: begin
        // FADD 
        signResult = signA;
        if(expA > expB) begin
            expResult = expA;
            shift = expA - expB;
            if(shift > 24) shift=24;
            mantResult = {1'b0, mantA} + ({1'b0, mantB} >> shift);
        end else if(expB > expA) begin
            expResult = expB;
            shift = expB - expA;
            if(shift > 24) shift=24;
            mantResult = ({1'b0, mantA} >> shift) + {1'b0, mantB};
            signResult = signB;
        end else begin
            // exponents are equal
            expResult = expA;
            mantResult = {1'b0, mantA} + {1'b0, mantB};
        end

        // en yüksek bit taşarsa veya yetersiz kalırsa normalize et
        if(mantResult[24]) begin
            // Overflow => shift right
            mantResult = mantResult >> 1;
            expResult  = expResult + 1;
        end else if(mantResult[23]==0 && mantResult!=0) begin
            // Possibly shift left
            mantResult = mantResult << 1;
            expResult  = expResult - 1;
        end
      end

      2'b01: begin
        // FSUB 
        signResult = signA;
        if(expA > expB) begin
            expResult = expA;
            shift = expA - expB;
            if(shift > 24) shift=24;
            mantResult = {1'b0, mantA} - ({1'b0, mantB} >> shift);
        end else if(expB > expA) begin
            expResult = expB;
            shift = expB - expA;
            if(shift > 24) shift=24;
            mantResult = ({1'b0, mantA} >> shift) - {1'b0, mantB};
            // B A'dan büyükse işaret değiştir
            signResult = ~signA;
        end else begin
            // exponentler aynı
            expResult = expA;
            mantResult = {1'b0, mantA} - {1'b0, mantB};
        end
        // Normalize again:
        if(mantResult[24]) begin
            mantResult = mantResult >> 1;
            expResult  = expResult + 1;
        end else if(mantResult[23]==0 && mantResult!=0) begin
            mantResult = mantResult << 1;
            expResult  = expResult - 1;
        end
      end

      2'b10: begin
        // FDIV newton raphson, ama sonuclar cok farkli
        signResult = signA ^ signB;
        expResult = expA - expB + 8'd127;
        if (mantB == 24'd0) begin
            // sifira bolme var
            mantResult = 25'd0;
        end else begin
            // mantB reciprocal
            approx_recip = (48'd12582912 << 24) / mantB;  
            for(i=0; i<4; i=i+1) begin
                product = (mantB * approx_recip) >> 24;
                step = TWO_Q24 - product; 
                product = (approx_recip * step) >> 24;
                approx_recip = product;  
            end
            // mantA * reciprocal
            product = mantA * approx_recip; 
            mantResult = product[47:24];

            // Normalize
            if(mantResult[24]) begin
                mantResult = mantResult >> 1;
                expResult  = expResult + 1;
            end else if(mantResult[23]==0 && mantResult!=0) begin
                mantResult = mantResult << 1;
                expResult  = expResult - 1;
            end
        end
      end

      default: begin
        // baska seyler
        signResult = 1'b0;
        expResult  = 8'd0;
        mantResult = 25'd0;
      end
    endcase
end

//float karsilastirmalar

reg eq_reg, lt_reg;

always @* begin
    // Default
    eq_reg = 1'b0;
    lt_reg = 1'b0;

    // bitler esitse => eq
    if(A == B) begin
      eq_reg = 1'b1;
      lt_reg = 1'b0;
    end
    else begin
      // eger isaret biti farkliysa negatif olan kücük
      if(signA != signB) begin
         // If A is negative and B is not => A < B
         if(signA == 1'b1) lt_reg = 1'b1;
         else lt_reg = 1'b0;
         eq_reg = 1'b0;
      end
      else begin
         // Same sign => if sign=1 => “exponenti büyük daha az”
         // önce exponent sonra fraction karşılaştırması 
         // invert sign=1 ise
         if(expA == expB) begin
            // fraction karşılaştır
            if(mantA == mantB) begin
               eq_reg = 1'b1; // yukarıda denendi burada olmaz
               lt_reg = 1'b0;
            end
            else if(mantA < mantB) begin
               // if sign=0 => A < B => lt=1
               // if sign=1 => A < B => A daha mı az negatif
               lt_reg = (signA==1'b0) ? 1'b1 : 1'b0;
            end
            else begin
               lt_reg = (signA==1'b0) ? 1'b0 : 1'b1;
            end
         end
         else begin
            // exponentler farkli
            if(expA < expB) begin
               lt_reg = (signA==1'b0) ? 1'b1 : 1'b0;
            end
            else begin
               // expA > expB
               lt_reg = (signA==1'b0) ? 1'b0 : 1'b1;
            end
         end
      end
    end
end

//dallanma output
assign fp_eq = eq_reg;
assign fp_lt = lt_reg;

//R output
wire [22:0] outFrac = mantResult[22:0];
wire [7:0]  outExp  = expResult;
wire        outSign = signResult;
assign R = {outSign, outExp, outFrac};

endmodule


// Data Memory
module Data_Memory(clk, reset, MemWrite, MemRead, address, Write_data, MemData_out);
    input clk, reset, MemWrite, MemRead;
    input [31:0] address, Write_data;
    output [31:0] MemData_out;

    reg [31:0] D_Memory[63:0];
    integer k;


    assign MemData_out = (MemRead) ? D_Memory[address[31:2]] : 32'b0;

    always @(posedge clk or posedge reset) begin
   if(reset) begin
      for(k=0; k<64; k=k+1)
          D_Memory[k] = 32'b0;

      // 8 float degeri
      D_Memory[0]  = 32'h40400000; // 3.0
      D_Memory[1]  = 32'b10111111100011001100110011001101; // -1.1
      D_Memory[2]  = 32'h40c00000; // 6.0
      D_Memory[3]  = 32'b00000000000000000000000000000000; // 0.0
      D_Memory[4]  = 32'h40900000; // 4.5
      D_Memory[5]  = 32'b11000000010110011001100110011010; // -3.4
      D_Memory[6]  = 32'h40a00000; // 5.0
	  D_Memory[7]  = 32'b01000000101001001100110011001101; //5.15
   end
   else if(MemWrite) begin
      D_Memory[address[31:2]] = Write_data;
   end
end
endmodule


// MUXlar ALU
module Mux1(sel1, A1, B1, Mux1_out);
    input sel1;
    input [31:0] A1,B1;
    output [31:0] Mux1_out;

    assign Mux1_out = (sel1 == 1'b0) ? A1 : B1;
endmodule



//MUX 3 Memory
module Mux3(sel3, A3, B3, Mux3_out);
    input sel3;
    input [31:0] A3,B3;
    output [31:0] Mux3_out;

    assign Mux3_out = (sel3 == 1'b0) ? A3 : B3;
endmodule


// AND logicti Branch Decision oldu
module BranchDecision(
    input  branch_en,   // from Control Unit
    input  [2:0] funct3,// instruction[14:12]
    input  eq,          // ALU says (A == B) or float eq
    input  lt_signed,   // ALU says (A < B) or float lt
    input  lt_unsigned, // integer (A < B) unsigned
    output reg branch_taken
);

always @(*) begin
    if(!branch_en) begin
        branch_taken = 1'b0;
    end
    else begin
        // int ve float dallanmalar
        case(funct3)
          3'b000: branch_taken = eq;            // beq or fbeq
          3'b001: branch_taken = ~eq;           // bne 
          3'b100: branch_taken = lt_signed;     // blt or fblt
          3'b101: branch_taken = ~lt_signed;    // bge or fbge
          3'b110: branch_taken = lt_unsigned;   // bltu
          3'b111: branch_taken = ~lt_unsigned;  // bgeu
          default: branch_taken = 1'b0;
        endcase
    end
end

endmodule


// Adder
module Adder(in_1, in_2, Sum_out);
    input [31:0] in_1, in_2;
    output [31:0] Sum_out;
    assign Sum_out = in_1 + in_2;
endmodule


//Modül instantiation

module top(clk, reset);
    input clk, reset;

    // PC, instruction
    wire [31:0] PC_top, instruction_top;
    // register file outputs
    wire [31:0] Rd1_top, Rd2_top;
    // immediate
    wire [31:0] ImmExt_top;
    // ALU signals
    wire [31:0] mux1_top, address_top;
    wire zero_top;
    wire eq_flag, lt_signed_flag, lt_unsigned_flag;
    // data mem
    wire [31:0] Memdata_top;
    wire [31:0] WriteBack_top;
    // control signals
    wire RegWrite_top, ALUSrc_top, branch_top;
    wire MemtoReg_top, MemWrite_top, MemRead_top;
    wire [1:0] ALUOp_top;
    wire [3:0] control_top;
    // branch decision
    wire branch_taken;
    // next PC
    wire [31:0] Sum_out_top, NextoPC_top, PCin_top;

    // 1) Program Counter
    Program_Counter PC(
      .clk(clk), 
      .reset(reset), 
      .PC_in(PCin_top), 
      .PC_out(PC_top)
    );

    // 2) PC + 4
    PCplus4 PC_Adder(
      .fromPC(PC_top), 
      .NextoPC(NextoPC_top)
    );

    // 3) Instruction Memory
    Instruction_Mem Inst_Memory(
      .clk(clk), 
      .reset(reset), 
      .read_address(PC_top), 
      .instructions_out(instruction_top)
    );

    // 4) Register File
    Reg_File Reg_File(
      .clk(clk), 
      .reset(reset), 
      .RegWrite(RegWrite_top),
      .Rs1(instruction_top[19:15]), 
      .Rs2(instruction_top[24:20]), 
      .Rd(instruction_top[11:7]), 
      .Write_data(WriteBack_top), 
      .read_data1(Rd1_top), 
      .read_data2(Rd2_top)
    );

    // 5) Immediate Generator
    ImmGen ImmGen(
      .ImmExt(ImmExt_top),
      .OpCode(instruction_top[6:0]), 
      .instruction(instruction_top)
    );

    // 6) Control Unit
    Control_Unit Control_Unit(
      .reset(reset), 
      .OpCode(instruction_top[6:0]), 
      .Branch(branch_top), 
      .MemRead(MemRead_top), 
      .MemtoReg(MemtoReg_top),
      .MemWrite(MemWrite_top),
      .ALUSrc(ALUSrc_top), 
      .RegWrite(RegWrite_top),
      .ALUOp(ALUOp_top)
    );

    // 7) ALU Control
    ALU_Control ALU_Control(
      .ALUOp(ALUOp_top), 
      .fun7(instruction_top[31:25]), 
      .fun3(instruction_top[14:12]), 
      .Control_out(control_top)
    );

    // 8) ALU
    ALU_unit ALU(
      .A(Rd1_top), 
      .B(mux1_top), 
      .Control_in(control_top), 
      .ALU_Result(address_top), 
      .zero(zero_top),
      .eq(eq_flag), 
      .lt_signed(lt_signed_flag), 
      .lt_unsigned(lt_unsigned_flag)
    );

    // 9) MUX for ALU input (Rs2 or Imm)
    Mux1 ALU_mux(
      .sel1(ALUSrc_top), 
      .A1(Rd2_top), 
      .B1(ImmExt_top), 
      .Mux1_out(mux1_top)
    );

    // 10) branch icin adder
    Adder BranchAdder(
      .in_1(PC_top), 
      .in_2(ImmExt_top), 
      .Sum_out(Sum_out_top)
    );

    // 11) Branch decision
    BranchDecision bdec(
      .branch_en(branch_top), 
      .funct3(instruction_top[14:12]),
      .eq(eq_flag),
      .lt_signed(lt_signed_flag),
      .lt_unsigned(lt_unsigned_flag),
      .branch_taken(branch_taken)
    );

    // next PC: PC+4 mu branch adres mi
    assign PCin_top = (branch_taken) ? Sum_out_top : NextoPC_top;

    // 12) Data Memory
    Data_Memory Data_mem(
      .clk(clk), 
      .reset(reset), 
      .MemWrite(MemWrite_top), 
      .MemRead(MemRead_top), 
      .address(address_top), 
      .Write_data(Rd2_top), 
      .MemData_out(Memdata_top)
    );

    // 13) writeback için mux
    Mux3 Memory_mux(
      .sel3(MemtoReg_top), 
      .A3(address_top),   // ALU sonuç
      .B3(Memdata_top),   // yüklenen veriss
      .Mux3_out(WriteBack_top)
    );

endmodule



//testbench
module tb_top;

reg clk, reset;

top uut(.clk(clk), .reset(reset));

initial begin
clk=0;
reset=1;
#5;
reset=0;
#400;
end

always begin
#5 clk = ~clk;
end

endmodule




