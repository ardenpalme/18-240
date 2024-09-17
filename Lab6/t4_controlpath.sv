/*
 * File: controlpath.v
 * Created: 4/5/1998
 * Modules contained: controlpath
 *
 * The condition codes are ordered as ZCNV
 *
 * Changelog:
 * 9 June 1999 : Added stack pointer
 * 4/16/2001: Reverted to base code (verBurg)
 * 4/16/2001: Added the "addsp" instruction. (verBurg)
 * 11/26/06: Removed old Altera-specific code that Xilinx tool had trouble with (P. Milder)
 * 07 Oct 2009: Cleaned up coding style somewhat and made minor changes (mcbender)
 * 08 Oct 2009: Fixed minor errors (mcbender)
 * 12 Oct 2009: Minor naming changes for consistency with modules.v (mcbender)
 * 13 Oct 2009: Removed tabs and fixed spacing (mcbender)
 * 18 Oct 2009: Changed some constant names (mcbender)
 * 23 Oct 2009: Renamed from paths.v to controlpath.v, moved datapath to datapath.v
 * 13 Oct 2010: Updated always to always_comb and always_ff. Removed #1 before finish,
 *              as timing controls not allowed in always_comb. Renamed to .sv. (abeera)
 * 17 Oct 2010: Updated to use enums instead of define's (iclanton)
 * 24 Oct 2010: Updated to use struct (abeera)
 * 9  Nov 2010: Slightly modified variable names (abeera)
 * 13 Nov 2010: Modified to use static instead of dynamic casting (abeera)
 * 23 Apr 2012: Modified to have two stop states, the first decrements PC, per ISA (leifan)
 * 8  Mar 2019: Modified to match RISC240 spec (pbannai)
 * 9  Apr 2019: Updated ordering of SLT/SLTI microinstructions, updated STOP
                microinstructions (saugatag)
 * 14 Apr 2019: Updated LI states to ADDI (saugatag)
 */

`include "constants.sv"

/*
 * module controlpath
 *
 * This is the FSM for the RISC240.  Any modifications to the ISA
 * or even the base implementation will most likely affect this module.
 * (Hint, hint.)
 */
module controlpath (
   input [3:0]       CCin,
   input [15:0]      IRIn,
   output controlPts out,
   output opcode_t currState,
   output opcode_t nextState,
   input logic       mul_done,
   input             clock,
   input             reset_L);

   logic Z, C, N, V;
   assign {Z, C, N, V} = CCin;

   always_ff @(posedge clock or negedge reset_L)
     if (~reset_L)
       currState <= FETCH;
     else
       currState <= nextState;

   // order of control points:
   // {ALU fn, AmuxSel, BmuxSel, DestDecode, CCLoad, RE, WE}

   always_comb begin
      case (currState)
        FETCH: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH1;
         end
        FETCH1: begin
           out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = FETCH2;
         end
        FETCH2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_IR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = DECODE;
        end
        DECODE: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = opcode_t'(IRIn[15:9]);
         //  $cast(nextState, IRIn[15:6]);
        end
        STOP: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = STOP1;
        end
        STOP1: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START}; // same as above
           nextState = STOP1; // This is to avoid a latch
`ifndef synthesis
           $display("STOP occurred at time %d", $time);
            $finish;
`endif
        end
        // Arithmetic functions:
        ADD: begin
           out = {F_A_PLUS_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        SUB: begin
           out = {F_A_MINUS_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        // Branch functions:
        BRA: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = BRA1;
        end
        BRA1: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = BRA2;
        end
        BRA2: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRN: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           if (N)
             nextState = BRN2;
           else
             nextState = BRN1;
        end
        BRN1: begin
           out = {F_A_PLUS_2, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRN2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = BRN3;
        end
        BRN3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRZ: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           if (Z)
             nextState = BRZ2;
           else
             nextState = BRZ1;
        end
        BRZ1: begin
           out = {F_A_PLUS_2, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRZ2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = BRZ3;
        end
        BRZ3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRC: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           if (C)
             nextState = BRC2;
           else
             nextState = BRC1;
        end
        BRC1: begin
           out = {F_A_PLUS_2, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRC2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = BRC3;
        end
        BRC3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRV: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           if (V)
             nextState = BRV2;
           else
             nextState = BRV1;
        end
        BRV1: begin
           out = {F_A_PLUS_2, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRV2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = BRV3;
        end
        BRV3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        BRNZ: begin
            out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
            if(N | Z)
              nextState = BRNZ2;
            else
              nextState = BRNZ1;
        end
        BRNZ1: begin
            out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
            nextState = FETCH;
        end
        BRNZ2: begin
            out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
            nextState = BRNZ3;
        end
        BRNZ3: begin
            out = {F_A, MUX_MDR, 2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR, NO_START};
            nextState = FETCH;
        end
        // Logical functions:
        AND: begin
           out = {F_A_AND_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        NOT: begin
           out = {F_A_NOT, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        OR: begin
           out = {F_A_OR_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        XOR: begin
           out = {F_A_XOR_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        // Shift functions:
        SLL: begin
          out = {F_A_SHL, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SLLI: begin
          out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = SLLI1;
        end
        SLLI1: begin
          out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
          nextState = SLLI2;
        end
        SLLI2: begin
          out = {F_A_SHL, MUX_REG, MUX_MDR, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SRA: begin
          out = {F_A_ASHR, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SRAI: begin
          out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = SRAI1;
        end
        SRAI1: begin
          out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
          nextState = SRAI2;
        end
        SRAI2: begin
          out = {F_A_ASHR, MUX_REG, MUX_MDR, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SRL: begin
          out = {F_A_LSHR, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SRLI: begin
          out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = SRLI1;
        end
        SRLI1: begin
          out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
          nextState = SRLI2;
        end
        SRLI2: begin
          out = {F_A_LSHR, MUX_REG, MUX_MDR, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        // CC Setting functions:
        SLT: begin
          out = {F_A_MINUS_B, MUX_REG, MUX_REG, DEST_NONE, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = SLT1;
        end
        SLT1: begin
          out = {F_A_LT_B, MUX_REG, MUX_REG, DEST_REG, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        SLTI: begin
          out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = SLTI1;
        end
        SLTI1: begin
          out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
          nextState = SLTI2;
        end
        SLTI2: begin
          out = {F_A_MINUS_B, MUX_REG, MUX_MDR, DEST_NONE, LOAD_CC, NO_RD, NO_WR, NO_START};
          nextState = SLTI3;
        end
        SLTI3: begin
          out = {F_A_LT_B, MUX_REG, MUX_MDR, DEST_REG, NO_LOAD, NO_RD, NO_WR, NO_START};
          nextState = FETCH;
        end
        // Data movement functions:
        MV: begin
           out = {F_A, MUX_REG, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        ADDI: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = ADDI1;
        end
        ADDI1: begin
           out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = ADDI2;
        end
        ADDI2: begin
           out = {F_A_PLUS_B, MUX_REG, MUX_MDR, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        LW: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = LW1;
        end
        LW1: begin
           out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = LW2;
        end
        LW2: begin
           out = {F_A_PLUS_B, MUX_REG, MUX_MDR, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = LW3;
        end
        LW3: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = LW4;
        end
        LW4: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        SW: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = SW1;
        end
        SW1: begin
           out = {F_A_PLUS_2, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR, NO_START};
           nextState = SW2;
        end
        SW2: begin
           out = {F_A_PLUS_B, MUX_REG, MUX_MDR, DEST_MAR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = SW3;
        end
        SW3: begin
           out = {F_B, 2'bxx, MUX_REG, DEST_MDR, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = SW4;
        end
        SW4: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, MEM_WR, NO_START};
           nextState = FETCH;
        end
        MUL: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, START};
           nextState = MUL1;
        end
        MUL1: begin
           out = mul_done ? {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START} : {4'bxxxx, 2'bxx, 2'bxx, LD_MUL, NO_LOAD, NO_RD, NO_WR, START};
           nextState = mul_done ? MUL2 : MUL1;
        end
        MUL2: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        MULI: begin
           out = {4'b0010, 2'b01, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR, START};
           nextState = MULI1;
        end
        MULI1: begin
           out = {4'b0100, 2'b01, 2'bxx, DEST_PC, NO_LOAD, RD, NO_WR, START};
           nextState = MULI2;
        end
        MULI2: begin
           out = mul_done ? {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR, NO_START} : {4'bxxxx, 2'bxx, 2'bxx, LD_MUL, NO_LOAD, NO_RD, NO_WR, START};
           nextState = mul_done ? MULI3 : MULI2;
        end
        MULI3: begin
           out = {4'b0100, 2'b01, 2'bxx, DEST_PC, NO_LOAD, RD, NO_WR, NO_START};
           nextState = FETCH;
        end
        default: begin
           out = 14'bx;
           nextState = FETCH;

        end
     endcase
   end

endmodule
