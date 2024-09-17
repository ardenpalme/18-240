`default_nettype none

module ChipInterface
  (output logic [6:0] HEX9, HEX8,
   output logic [7:0] LEDG, LEDR,
   output logic NEO_DATA,
   input logic [17:0] SW,
   input logic [7:0]  KEY,
   input logic CLOCK_50);

   logic reset, load, go, ready, neopixel_data, start, done;
   assign reset = ~KEY[3];
   assign start = ~KEY[0];
   assign LEDR[2] = ready;
   assign NEO_DATA = neopixel_data;

    logic [11:0] guess, feedback, pattern;
    logic [3:0] loaded_i;

    assign guess= 12'o1111;
    assign feedback= 12'o2222;
    assign pattern= {SW[14:12], SW[9:1]};
    assign loaded_i= 4'b1101;

    neopixelGameController DUT(.st(SW[17:16]), .done(LEDG[1]), .*);
endmodule : ChipInterface
