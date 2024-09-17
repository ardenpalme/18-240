            .ORG $0
            ; MULI rd, rs1 ==> 0110_001 r1, r2, 000  ==> 0110_001 001 010 000
            ; $imm
            LI          r2, $2

            .DW  $6250
            .DW  $A
            STOP
