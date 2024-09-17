`default_nettype none

module ChipInterface
  (output logic [6:0] HEX9, HEX8,
   output logic [7:0] LEDG, LEDR,
   output logic NEO_DATA,
   input logic [17:0] SW,
   input logic [7:0]  KEY,
   input logic CLOCK_50);

   logic reset, load, go, neopixel_data, ready, start;
   assign reset = ~KEY[3];
   assign start = ~KEY[0];
   assign LEDR[2] = ready;
   assign NEO_DATA = neopixel_data;

   logic [7:0] red, green, blue;
   logic [2:0] pixel;
    logic ld_color, cl_color, sel1, sel2, sel3;

  /*FSM*/
  FSM control (.*);

  /*Datapath*/
  logic [2:0] rgb, w6, w7;
  logic [11:0] tmp, w2, w3, w4;

  Mux2to1 #(3)  mux4(.I0(w6), .I1(w7), .S(pixel[1]), .Y(rgb));
  Mux2to1 #(3)  mux5(.I0(tmp[2:0]), .I1(tmp[5:3]), .S(pixel[0]), .Y(w6));
  Mux2to1 #(3)  mux6(.I0(tmp[8:6]), .I1(tmp[11:9]), .S(pixel[0]), .Y(w7));

  logic [11:0] guess, feedback, pattern, loaded_white;
  assign guess= 12'o4321;
  assign feedback= 12'o1234;
  assign pattern= 12'o2222;
  assign loaded_white= 12'o1111;444

  Mux2to1 #(12) mux1(.I0(w4), .I1(w3), .S(sel1), .Y(w2)),
                mux2(.I0(guess), .I1(feedback), .S(sel2), .Y(w3)),
                mux3(.I0(pattern), .I1(loaded_white), .S(sel3), .Y(w4));

  Register #(12) reg1(.en(ld_color), .D(w2), .Q(tmp), .clock(CLOCK_50), .clear(cl_color));

  RGB aa(.*);

  NeopixelController NPC (.*);
endmodule : ChipInterface

module RGB
    (input logic [2:0] rgb,
     output logic [7:0] red, green, blue);

    always_comb begin
        case(rgb)
           3'b000: begin red= 8'd32; green= 8'd32; blue= 8'd32; end
           3'b001: begin red= 8'd0; green= 8'd32; blue= 8'd0; end
           3'b010: begin red= 8'd32; green= 8'd32; blue= 8'd0; end
           3'b011: begin red= 8'd32; green= 8'd0; blue= 8'd0; end
           3'b100: begin red= 8'd0; green= 8'd0; blue= 8'd32; end
           default: begin red= 8'd0; green= 8'd0; blue= 8'd0; end
        endcase
    end
endmodule : RGB

module FSM
  (input logic ready, reset, CLOCK_50, start,
   output logic [2:0] pixel,
   output logic load, go, sel1, sel2, sel3, ld_color, cl_color);

  enum {waiting, pix0, pix1, pix2, pix3, pix4, pix5, pix6, pix7, lights} cs, ns;

  //Next State Logic
  always_comb begin
    unique case(cs)
      waiting: ns = start ? pix0 : waiting;
      pix0: ns = pix1;
      pix1: ns = pix2;
      pix2: ns = pix3;
      pix3: ns = pix4;
      pix4: ns = pix5;
      pix5: ns = pix6;
      pix6: ns = pix7;
      pix7: ns = lights;
      lights: ns = ready ? waiting : lights;
    endcase
  end


  //Output Logic
  always_comb begin
    load = 1'd1;
     {sel1, sel2, sel3}= 3'b000;
     cl_color= 0; ld_color=0;
    go = 1'd0;
    pixel = 3'd0;
    unique case(cs)
      waiting: begin load = 1'd0; sel1= 1; sel2= 1; ld_color= 1; end
      pix0: pixel = 3'd0;
      pix1: pixel = 3'd1;
      pix2: pixel = 3'd2;
      pix3: begin pixel = 3'd3; ld_color= 1; sel1= 1; end
      pix4: pixel = 3'd4;
      pix5: pixel = 3'd5;
      pix6: pixel = 3'd6;
      pix7: pixel = 3'd7;
      lights: begin
        load = 1'd0;
        go = 1'd1;
      end
    endcase
  end

  always_ff @(posedge CLOCK_50, posedge reset)
    if(reset)
     cs = pix0;
    else
     cs = ns;

endmodule: FSM


