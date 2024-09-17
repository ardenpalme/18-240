`default_nettype none

module task2_tb ();
    logic [11:0] guess;
    logic [2:0] feedback0, feedback1, feedback2, feedback3;
    logic [3:0] round_number;
    logic start_game, grade_it, won, lost, clock, reset;

    Task2 DUT(.*);

    initial begin
        $display("[start_game, grade_it]");
        $monitor($time,,
                 "%s [%b%b] guess=%o, pattern=%o, feedback=%o, round_number=%h [%b%b]",
                 DUT.control.currState.name, start_game, grade_it, guess, DUT.pattern,
                 {feedback0, feedback1, feedback2, feedback3},
                 round_number, won, lost);
        clock= 0;
        forever #5 clock= ~clock;
    end

    initial begin
        start_game <= 1;
        reset= 1;
        grade_it= 0;
        @ (posedge clock);
        reset <= 0;

        guess <=12'o1100;
        grade_it <= 1;
        repeat(12)
            @ (posedge clock);

        grade_it <=0;
        guess <=12'o0501;
        grade_it <= 1;
        repeat(12)
            @ (posedge clock);

        grade_it <=0;
        guess <=12'o1101;
        grade_it <= 1;
        repeat(12)
            @ (posedge clock);

        $finish;
    end
endmodule : task2_tb
