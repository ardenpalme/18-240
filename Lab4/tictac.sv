module dFlipFlop
    (output logic q,
     input logic d, clock, reset);

    always @(posedge clock)
    if (reset == 1)
        q <= 0;
    else
        q <= d;
endmodule: dFlipFlop

module myStructuralFSM
    (input logic [3:0] hMove,
     output logic [3:0] cMove,
     output logic win,
     input logic clock, reset);

logic q0, q1, q2;
logic d0, d1, d2;

dFlipFlop ff2(.d(d2), .q(q2), .clock, .reset),
          ff1(.d(d1), .q(q1), .clock, .reset),
          ff0(.d(d0), .q(q0), .clock, .reset);

logic tmp, tmp1, tmp2, tmp3;
assign tmp= (~q2 & ~q1 & ~q0) &
            ((hMove[3]                                  ) |
            (~hMove[3] & ~hMove[2]                      ) |
            (~hMove[3] & hMove[2] & ~hMove[1]           ) |
            (~hMove[3] & hMove[2] & hMove[1] & hMove[0] ));

assign tmp1= (~q2 & ~q1 & q0) &
            ((~hMove[3] & ~hMove[2] & ~hMove[1]          ) |
            (~hMove[3] & hMove[2] & ~hMove[1] & hMove[0]) |
            (~hMove[3] & hMove[2] & hMove[1] & ~hMove[0]) |
            (hMove[3] & ~hMove[2] & hMove[1]            ) |
            (hMove[3] & hMove[2]                        ));

assign tmp2= (~q2 & ~q1 & q0) &
           ((~hMove[3] & ~hMove[2] & hMove[1]            ) |
           (~hMove[3] & hMove[2] & ~hMove[1] & ~hMove[0] ) |
           (~hMove[3] & hMove[2] & hMove[1] & hMove[0] ) |
           (hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0]));

assign tmp3=(~q2 & q1 & ~q0) &
            ((~hMove[3] & ~hMove[2] & ~hMove[1]           ) |
            (~hMove[3] & ~hMove[2] & hMove[1] & hMove[0] ) |
            (~hMove[3] & hMove[2] & ~hMove[1] & hMove[0] ) |
            (~hMove[3] & hMove[2] & hMove[1] & ~hMove[0] ) |
            (hMove[3] & ~hMove[2] & ~hMove[1] & hMove[0] ) |
            (hMove[3] & ~hMove[2] & hMove[1]             ) |
            (hMove[3] & hMove[2]                         ));

/* Next State Logic */
assign d2= (~hMove[3] & ~hMove[2] & hMove[1] & ~hMove[0] & ~q2 & q1 & ~q0) |
           (~hMove[3] & hMove[2] & ~hMove[1] & ~hMove[0] & ~q2 & q1 & ~q0) |
           (~hMove[3] & hMove[2] & hMove[1] & hMove[0]   & ~q2 & q1 & ~q0) |
           (hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0] & ~q2 & q1 & ~q0) |
           (q2 & ~q1 & ~q0) |
           (q2 & ~q1 & q0);

assign d1= (hMove[3] & ~hMove[2] & ~hMove[1] & hMove[0]  & ~q2 & ~q1 & q0) |
           tmp2 |
           tmp3 |
           (~q2 & q1 & q0);

assign d0= (~hMove[3] & hMove[2] & hMove[1] & ~hMove[0]  & ~q2 & ~q1 & ~q0) |
           tmp1 |
           tmp2 |
           (~hMove[3] & ~hMove[2] & hMove[1] & ~hMove[0] & ~q2 & q1 & ~q0) |
           (~q2 & q1 & q0) |
           (q2 & ~q1 & q0);


/* Output Logic */
assign cMove[3]= ~q2 & q1 & q0;

assign cMove[2]= (~hMove[3] & hMove[2] & hMove[1] & ~hMove[0] & ~q2 & ~q1 & ~q0)
                 | tmp |
                 (q2 & ~q1 & q0);

assign cMove[1]= tmp3 |
                 (~hMove[3] & ~hMove[2] & hMove[1] & ~hMove[0] & ~q2 & q1 & ~q0)
                 | (~hMove[3] & hMove[2] & ~hMove[1] & ~hMove[0] & ~q2 & q1 &
                 ~q0) | (~hMove[3] & hMove[2] & hMove[1] & hMove[0]   & ~q2 & q1
                 & ~q0) | (hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0] & ~q2 &
                 q1 & ~q0) | (q2 & ~q1 & ~q0) | (q2 & ~q1 & q0);

assign cMove[0]= ~(q2 & ~q1 & ~q0);

assign win= (~q2 & q1 & q0) |
            (q2 & ~q1 & ~q0) |
            (q2 & ~q1 & q0);

endmodule : myStructuralFSM
