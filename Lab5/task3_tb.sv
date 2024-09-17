`default_nettype none

module task3_tb ();
    /* Inputs */
    logic [2:0] color_to_load;
    logic [1:0] color_location;
    logic [11:0] guess;
    logic start_game, grade_it, load_color;
    logic clock, reset;

    /* Outputs */
    logic [3:0] round_number;
    logic neopixel_data;
    logic won, lost;

    Task3 DUT(.*);

    initial begin
        $monitor($time,,
                 "%s @ #%d, guess=%o, color_to_load=%b color_location=%b %b %b %d %b // %b",
                 DUT.control.currState.name, round_number,
                 guess, color_to_load, color_location, DUT.loaded1, DUT.tmp2, DUT.color_ind, DUT.done, DUT.neoReady);
        clock= 0;
        forever #5 clock= ~clock;
    end

    initial begin
        start_game <= 1;
        reset= 1;
        grade_it= 0;
        @ (posedge clock);
        reset <= 0;

        guess <=12'o1111;
        @ (posedge clock);
        color_location <= 2'o0;
        color_to_load <= 3'o0;
        @ (posedge clock);
        @ (posedge clock);

        color_location <= 2'o1;
        color_to_load <= 3'o1;
        @ (posedge clock);
        @ (posedge clock);

        color_location <= 2'o2;
        color_to_load <= 3'o2;
        @ (posedge clock);
        @ (posedge clock);

        color_location <= 2'o3;
        color_to_load <= 3'o3;
        load_color <= 1;
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);
        @ (posedge clock);

        $finish;
    end
endmodule : task3_tb
