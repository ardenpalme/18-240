`default_nettype none

module mult_tb ();
    logic [7:0] a, b;
    logic start, done;
    logic clock, reset;
    logic [15:0] out;

    mult DUT(.*);

    initial begin
        $monitor($time,,
                 "%s A: %h, B: %h, out: %h, i= %d done: %b",
                  DUT.control.cs.name, DUT.w1, DUT.bAbs, out, DUT.w7, done);
        clock= 0;
        reset= 1;
        start= 0;
        forever #5 clock= ~clock;
    end

    initial begin
        a= -128;
        b= 127;
        $display("initial values: A= %h, B= %h", a, b);
        @ (posedge clock);
        reset<= 0;
        start<= 1;
        repeat(33)
            @ (posedge clock);
        $finish;
    end
endmodule : mult_tb
