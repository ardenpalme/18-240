`default_nettype none

module neopixelGameController
  (input logic [11:0] pattern, guess, feedback,
    input logic [3:0] loaded_i,
    input logic [1:0] st,
    input logic start, clock, reset,
    output logic neopixel_data, done);

   logic ld_color, sel, sel1, sel2, sel3;

  logic [7:0] red, green, blue;
  logic [2:0] pixel;
  logic ready, load, go;
  NeopixelController NPC(.CLOCK_50(clock), .*);

  /*FSM*/
  FSM control (.*);

  /*Datapath*/
  logic [2:0] rgb, w6, w7;
  logic [11:0] tmp, w1, w2, w3, w4;

  //indexes into tmp 12 bit variable based on which pixel is currently being set
  Mux2to1 #(3)  mux1(.I0(w6), .I1(w7), .S(pixel[1]), .Y(rgb));
  Mux2to1 #(3)  mux2(.I0(tmp[2:0]), .I1(tmp[5:3]), .S(pixel[0]), .Y(w6));
  Mux2to1 #(3)  mux3(.I0(tmp[8:6]), .I1(tmp[11:9]), .S(pixel[0]), .Y(w7));

  logic [11:0] loaded_white;
  Mux2to1 #(12) mux4(.I0(w4), .I1(w3), .S(sel1), .Y(w2)),
                mux5(.I0(guess), .I1(feedback), .S(sel2), .Y(w3)),
                mux6(.I0(pattern), .I1(loaded_white), .S(sel3), .Y(w4)),
                mux7(.I0(w2), .I1(12'o7777), .S(sel), .Y(w1));

  Register #(12) reg1(.en(ld_color), .D(w1), .Q(tmp), .clock(clock), .clear());
  RGB aa(.*);
  loadedToWhite bb(.*);
endmodule : neopixelGameController

//calculates which LEDs should display white, to match validity of pattern
module loadedToWhite
    (input logic [3:0] loaded_i,
     output logic [11:0] loaded_white);

    always_comb begin
        case(loaded_i)
            4'b0000: loaded_white= 12'o7777;
            4'b0001: loaded_white= 12'o7770;
            4'b0010: loaded_white= 12'o7707;
            4'b0011: loaded_white= 12'o7700;
            4'b0100: loaded_white= 12'o7077;
            4'b0101: loaded_white= 12'o7070;
            4'b0110: loaded_white= 12'o7007;
            4'b0111: loaded_white= 12'o7000;
            4'b1000: loaded_white= 12'o0777;
            4'b1001: loaded_white= 12'o0770;
            4'b1010: loaded_white= 12'o0707;
            4'b1011: loaded_white= 12'o0700;
            4'b1100: loaded_white= 12'o0077;
            4'b1101: loaded_white= 12'o0070;
            4'b1110: loaded_white= 12'o0007;
            4'b1111: loaded_white= 12'o0000;
        endcase
    end
endmodule : loadedtowhite

// converts an encoded color value to its [red, green, blue] vector,
// variable for intensity
module rgb
    (input logic [2:0] rgb,
     output logic [7:0] red, green, blue);

     logic [7:0] tmp;
     assign tmp= 8'd1;

    always_comb begin
        case(rgb)
           3'b000: begin red= tmp; green= tmp; blue= tmp; end
           3'b001: begin red= 8'd0; green= tmp; blue= 8'd0; end
           3'b010: begin red= tmp; green= tmp; blue= 8'd0; end
           3'b011: begin red= tmp; green= 8'd0; blue= 8'd0; end
           3'b100: begin red= 8'd0; green= 8'd0; blue= tmp; end
           default: begin red= 8'd0; green= 8'd0; blue= 8'd0; end
        endcase
    end
endmodule : RGB

module FSM
  (input logic ready, reset, clock, start,
   input logic [1:0] st,
   output logic [2:0] pixel,
   output logic load, go, sel, sel1, sel2, sel3, ld_color, done);

  enum {waiting, pix0, pix1, pix2, pix3, pix4, pix5, pix6, pix7, lights} cs, ns;

  //Next State Logic
  always_comb begin
    unique case(cs)
      waiting: ns = start ? pix0 : waiting;
      /*set all pixels in order 0->7*/
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
    {sel, sel1, sel2, sel3}= 4'b0;
    ld_color=1'b0;
    go = 1'd0;
    pixel = 3'd0;
    done= 1'b0;
    unique case(cs)
      waiting: begin
                done=1;
                if(start) begin
                    load = 1'd0; ld_color= 1;
                    //selecting which pattern should be loaded into top row
                    case(st)
                         2'b11: begin sel1=1; sel2=1; end
                         2'b10: sel3=1;
                         2'b01: sel=1;
                         2'b00: sel=1;
                    endcase
                end
        end
      pix0: pixel = 3'd0;
      pix1: pixel = 3'd1;
      pix2: pixel = 3'd2;
      pix3: begin
            pixel = 3'd3; ld_color= 1;
            //selecting which pattern should be loaded into bottom row
            case(st)
                2'b11: sel1= 1;
                2'b00: sel=1;
            endcase
        end
      pix4: pixel = 3'd4;
      pix5: pixel = 3'd5;
      pix6: pixel = 3'd6;
      pix7: pixel = 3'd7;
      lights: begin
        load = 1'd0;
        go = 1'd1;
        done= ready ? 1 : 0;
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset)
    if(reset)
     cs = waiting;
    else
     cs = ns;

endmodule: FSM
