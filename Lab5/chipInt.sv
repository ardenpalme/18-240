default_nettype none

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

  /*FSM*/
  FSM control (.*);

  /*Datapath*/
  NeopixelController NPC (.*);

endmodule : ChipInterface


