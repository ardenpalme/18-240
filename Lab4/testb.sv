
module abstractFSM_test();
  logic [3:0] cMove, hMove;
  logic       win, clock, reset;

  myStructuralFSM DUT (.*);

  initial begin
    $monitor($time,, "state=%d, hMove=%d, cMove=%d, win=%b",
            {DUT.q2, DUT.q1, DUT.q0}, hMove, cMove, win);
    clock = 0;
    forever #5 clock = ~clock;
  end

  initial begin
    // Initialize Values
    hMove <= 4'b0000; reset <= 1;

    @(posedge clock);

    // Release reset
    reset <= 0;
    // Start test path for cStart
    hMove <= 4'd0;
    @(posedge clock);
    hMove <= 4'd1;
    @(posedge clock);
    hMove <= 4'd2;
    @(posedge clock);
    hMove <= 4'd3;
    @(posedge clock);
    hMove <= 4'd4;
    @(posedge clock);
    hMove <= 4'd5;
    @(posedge clock);
    hMove <= 4'd7;
    @(posedge clock);
    hMove <= 4'd8;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    hMove <= 4'd10;
    @(posedge clock);
    hMove <= 4'd11;
    @(posedge clock);
    hMove <= 4'd12;
    @(posedge clock);
    hMove <= 4'd13;
    @(posedge clock);
    hMove <= 4'd14;
    @(posedge clock);
    hMove <= 4'd15;
    @(posedge clock);

    hMove <= 4'd6;
    @(posedge clock); // To first

    // Start testing First
    hMove <= 4'd0;
    @(posedge clock);
    hMove <= 4'd1;
    @(posedge clock);
    hMove <= 4'd5;
    @(posedge clock);
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd10;
    @(posedge clock);
    hMove <= 4'd11;
    @(posedge clock);
    hMove <= 4'd12;
    @(posedge clock);
    hMove <= 4'd13;
    @(posedge clock);
    hMove <= 4'd14;
    @(posedge clock);
    hMove <= 4'd15;
    @(posedge clock);

    // To win1
    hMove <= 4'd2;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    hMove <= 4'd3;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    hMove <= 4'd4;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    hMove <= 4'd7;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    hMove <= 4'd8;
    @(posedge clock);

    // Start testing win1
    for (logic [3:0] i = 4'd0; i < 4'b1111; i++) begin
      hMove <= i;
      @(posedge clock);
    end
    hMove <= 4'b1111;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    hMove <= 4'd6;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;

    // Start testing second
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    reset <= 1;
    @(posedge clock); // test reset
    reset <=0;
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    hMove <= 4'd0;
    @(posedge clock); // test invalid cases
    hMove <= 4'd1;
    @(posedge clock);
    hMove <= 4'd3;
    @(posedge clock);
    hMove <= 4'd5;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    hMove <= 4'd10;
    @(posedge clock);
    hMove <= 4'd11;
    @(posedge clock);
    hMove <= 4'd12;
    @(posedge clock);
    hMove <= 4'd13;
    @(posedge clock);
    hMove <= 4'd14;
    @(posedge clock);
    hMove <= 4'd15;
    @(posedge clock);

    hMove <= 4'd2;
    @(posedge clock); // to win3

    // Test win3
    for (logic [3:0] i = 4'd0; i < 4'b1111; i++) begin
      hMove <= i;
      @(posedge clock);
    end
    hMove <= 4'b1111;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    hMove <= 4'd4;
    @(posedge clock);

    reset <= 1;
    @(posedge clock);
    reset <= 0;
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock);
    hMove <= 4'd7;
    @(posedge clock);

    reset <= 1;
    @(posedge clock);
    reset <= 0;
    hMove <= 4'd6;
    @(posedge clock);
    hMove <= 4'd9;
    @(posedge clock); // return to second
    hMove <= 4'd8;
    @(posedge clock);

    // Test win2
    for (logic [3:0] i = 4'd0; i < 4'b1111; i++) begin
      hMove <= i;
      @(posedge clock);
    end
    hMove <= 4'b1111;
    @(posedge clock);
    reset <= 1;
    @(posedge clock);
    reset <= 0;
    @(posedge clock);
    #1 $finish;
  end
endmodule: abstractFSM_test
