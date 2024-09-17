            .ORG $0
            BRA     START
            .ORG $200
START       LW      r1, r0, A
            LW      r2, r0, B
            LW      r3, r0, Y
            LI      r3, $0


step2       SLT     r4, r2, r0      ; if r4 == 1, B is orig neg
            BRN     negate
            BRA     loopBegin
negate      NOT     r2, r2
            ADDI    r2, r2, $1      ; r2 <- absB

loopBegin   LI      r7, $0
step3       LI      r5, $1
            AND     r6, r2, r5
            SLTI    r0, r6, $1
            BRZ     addA
            BRA     step4
addA        ADD     r3, r3, r1

step4       SRAI    r2, r2, $1
            SLLI    r1, r1, $1

            ADDI    r7, r7, $1
            SLTI    r0, r7, $9
            BRN     step3

step6       SLTI    r0, r4, $1
            BRZ     negateAns
            BRA     done
negateAns   NOT     r3, r3
            ADDI    r3, r3, $1

done        SW      r0, r3, Y
            STOP

            .ORG $100
A           .DW $FFFB
B           .DW $0071
Y           .DW $0
