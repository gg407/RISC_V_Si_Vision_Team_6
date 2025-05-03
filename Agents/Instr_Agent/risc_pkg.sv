package risc_pkg;

                             
     localparam [6:0] R_TYPE   = 7'b0110011, // R_TYPE Intger : add sub xor or and sll srl sra slt sltu 
                                                 // R_TYPE M      : mul mulh mulsu mulu div divu rem remu 

                     I_TYPE_0 = 7'b0010011, // I_TYPE_0: addi xori ori andi slli srli srai slti sltiu
                     I_TYPE_1 = 7'b0000011, // I_TYPE_1: lb lh lw lbu lhu 
                     I_TYPE_2 = 7'b1100111, // I_TYPE_2: jalr ---> Jump And Link Reg
                     S_TYPE   = 7'b0100011, // S_TYPE  : sb sh sw 
                     B_TYPE   = 7'b1100011, // B_TYPE  : beq bne blt bge bltu bgeu
                     U_TYPE_0 = 7'b0110111, // U_TYPE_0: lui   ---> Load Upper Imm
                     U_TYPE_1 = 7'b0010111, // U_TYPE_1: auipc ---> Add Upper Imm to PC 
                     J_TYPE   = 7'b1101111; // J_TYPE  : jal   ---> Jump And Link

 
	// R_TYPE Intger funct3 :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

    localparam [2:0] add = 3'h0, sll = 3'h1, slt = 3'h2, sltu = 3'h3, Xor = 3'h4, srx = 3'h5, Or = 3'h6, And = 3'h7;

    // R_TYPE M funct3       :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

     localparam [2:0] mul = 3'h0, mulh = 3'h1, mulsu = 3'h2, mulu = 3'h3, div = 3'h4, divu = 3'h5, rem = 3'h6, remu = 3'h7;

     // I_TYPE_0 funct3      :    0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7

    localparam [2:0] addi = 3'h0, sllI = 3'h1, sltI = 3'h2, sltIu = 3'h3, xorI = 3'h4, srxI = 3'h5, orI = 3'h6, AndI = 3'h7;

     // I_TYPE_1 funct3      :    0x0, 0x1, 0x2, 0x4, 0x5

     localparam [2:0] lb = 3'h0, lh = 3'h1, lw = 3'h2, lbu = 3'h4, lhu = 3'h5;

     // S_TYPE  funct3       :    0x0, 0x1, 0x2

     localparam [2:0] sb = 3'h0, sh = 3'h1, sw = 3'h2;

     // B_TYPE  funct3       :    0x0, 0x1, 0x4, 0x5, 0x6, 0x7

     localparam [2:0] beq = 3'h0, bne = 3'h1, blt = 3'h4, bge = 3'h5, bltu = 3'h6, bgeu = 3'h7;

     // INISTRUCTIONS RISC-VIM32
     typedef enum logic [5:0] { MUL  , MULH , MULSU, MULU , DIV , DIVU, REM , REMU,
                                ADD  , SUB  , SLL  , SLT  , SLTU, XOR , SRL , SRA , OR  , AND,
                                ADDI , SLLI , SLTI , SLTIU, XORI, SRLI, SRAI, ORI , ANDI,
                                LB   , LH   , LW   , LBU  , LHU ,
                                SB   , SH   , SW   ,
                                BEQ  , BNE  , BLT  , BGE  , BLTU, BGEU,  
                                JAL  , JALR , AUIPC, LUI  ,
                                RESET, 
                                UNKNOWN} instr_type;


endpackage 