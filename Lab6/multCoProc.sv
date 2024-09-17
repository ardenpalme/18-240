`default_nettype none

module mult
    (input logic [7:0] a,
     input logic [7:0] b,
     input logic start,
     output logic [15:0] out,
     output logic done,
     input clock, reset);

    /* Status Points */
    logic allScanned;

    /* ControlPoints */
    logic negb, ldA, ldB, ldY, enA, enB, clY, en_ct, cl_ct;

    logic [7:0] bAbs;
    FSM control(.BLSB(bAbs[0]), .bNEG(b[7]), .*);

    /* Datapath */
    logic [7:0] w4, w5, w6, w7;
    logic [15:0] w1, w2, w3, w8, w9, w10;

    ShiftRegister #(16) sreg1(.Q(w1), .D(w10), .left(1'b1), .en(enA), .load(ldA), .clock);
    ShiftRegister #(8) sreg2(.Q(bAbs), .D(w6), .left(1'b0), .en(enB), .load(ldB), .clock);

    Adder #(16) add1(.S(w2), .A(w1), .B(w3), .Cin(1'b0), .Cout());
    Adder #(16) add3(.S(w9), .A(w8), .B(16'd1), .Cin(1'b0), .Cout());
    Adder #(8)  add2(.S(w5), .A(w4), .B(8'd1), .Cin(1'b0), .Cout());

    assign w4= ~b; //NOT gate TODO
    assign w8= ~w3;

    Mux2to1 #(8) mux2(.Y(w6), .I0(b), .I1(w5), .S(negb));
    Mux2to1 #(16) mux3(.Y(out), .I0(w3), .I1(w9), .S(b[7]));
    Mux2to1 #(16) mux1(.Y(w10), .I0({8'h00,a}), .I1({8'hff,a}), .S(a[7]));

    Register #(16) reg1(.Q(w3), .D(w2), .en(ldY), .clear(clY), .clock);

    Counter #(8) ct1(.Q(w7), .D(), .up(1'b1), .en(en_ct), .clear(cl_ct), .load(), .clock);
    MagComp #(8) mag1(.AeqB(allScanned), .A(w7), .B(8'd8), .AltB(), .AgtB());

endmodule : mult

module FSM
    (input logic allScanned, bNEG, BLSB, start,
     output logic negb, ldA, ldB, ldY, enA, enB, clY, en_ct, cl_ct, done,
     input logic clock, reset);

    enum {Wait, Abs, loop, addA, shift, complete} cs, ns;

    /* Next State Logic */
    always_comb begin
        case(cs)
            Wait: ns= start ? Abs : Wait;
            complete: ns= Wait;
            Abs: ns= loop;
            addA: ns= shift;
            loop: ns= allScanned ? complete : (BLSB ? addA : shift);
            shift: ns= loop;
        endcase
    end

    /* Output Logic */
    always_comb begin
        {negb, ldA, ldB, ldY, enA, enB, clY, en_ct, cl_ct, done}= 11'd0;
        case(cs)
            Wait: cl_ct= start ? 1 : 0;
            Abs: begin
                clY= 1;
                if(bNEG) {negb, ldA, ldB}= 3'b111;
                else     {ldB, ldA}= 2'b11;
            end
            loop: begin
                done= allScanned ? 1 : 0;
                ldY= BLSB ? 1 : 0;
            end
            shift: {enA, enB, en_ct}= 3'b111;
        endcase
    end

    always_ff @ (posedge clock, posedge reset)
        if(reset)
            cs <= Wait;
        else
            cs <= ns;
endmodule : FSM
