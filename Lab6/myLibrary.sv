`default_nettype none
// Library file, for use whenever a standard component is required

// These modules from HW7
module MagComp
  #(parameter WIDTH=4)
  (input  logic [WIDTH-1:0] A, B,
   output logic             AltB, AeqB, AgtB);

  assign AltB = (A < B);
  assign AeqB = (A === B); // Triple equals fails on X values
  assign AgtB = (A > B);

endmodule : MagComp

module Adder
  #(parameter WIDTH=4)
  (input  logic [WIDTH-1:0] A, B,
   input  logic             Cin,
   output logic [WIDTH-1:0] S,
   output logic             Cout);

  assign {Cout,S} = A + B + Cin;

endmodule : Adder

module Multiplexer
  #(parameter WIDTH=4)
  (input  logic         [WIDTH-1:0] I,
   input  logic [$clog2(WIDTH)-1:0] S,
   output logic                     Y);

  assign Y = I[S];

endmodule : Multiplexer

module Mux2to1
  #(parameter WIDTH=4)
  (input  logic [WIDTH-1:0] I0, I1,
   input  logic             S,
   output logic [WIDTH-1:0] Y);

  assign Y = (S==1'b0) ? I0 : I1;

endmodule : Mux2to1

module Decoder
  #(parameter WIDTH=4)
  (input  logic [WIDTH-1:0] I,
   input  logic             en,
   output logic [WIDTH-1:0] D);

  always_comb begin
    D = 'b0;
    if (en)
      D[I] = 1'b1;
  end

endmodule : Decoder

module Register
  #(parameter WIDTH=4)
  (input  logic [WIDTH-1:0] D,
   input  logic             clock, en, clear,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (en)
      Q <= D;
    else if (clear)
      Q <= 'b0;

endmodule : Register

// These modules are graded for HW8

module Counter
  #(parameter WIDTH=4)
  (input  logic             clock, en, clear, load, up,
   input  logic [WIDTH-1:0] D,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (clear)
      Q <= 'd0;
    else if (load)
      Q <= D;
    else if (en & up)
      Q <= Q + 'd1;
    else if (en & ~up)
      Q <= Q - 'd1;

endmodule : Counter

module ShiftRegister
  #(parameter WIDTH = 4)
  (input  logic             clock, left, en, load,
   input  logic [WIDTH-1:0] D,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (en && left)
      Q <= {Q[WIDTH-2:0], 1'b0};
    else if (en && ~left)
      Q <= {1'b0, Q[WIDTH-1:1]};

endmodule : ShiftRegister

module BarrelShiftRegister
  #(parameter WIDTH = 8)
  (input  logic             clock, en, load,
   input  logic [1:0]       by,
   input  logic [WIDTH-1:0] D,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock)
    if (load)
      Q <= D;
    else if (en)
      Q <= Q << by;

endmodule : BarrelShiftRegister

module Memory
 #(parameter DW = 16,
             AW = 8,
             W  = 2**AW)
  (input logic re, we, clock,
   input logic [AW-1:0] Address,
   inout wire  [DW-1:0] Data);

  logic [DW-1:0] M[W];
  logic [DW-1:0] out;

  assign Data = (re) ? out: 'bz;

  always_ff @(posedge clock)
    if (we)
      M[Address] <= Data;

  always_comb
    out = M[Address];

endmodule: Memory
