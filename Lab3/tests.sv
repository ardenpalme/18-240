`default_nettype none;
 
module CalcHit_test();
   logic Big, Hit, error;
   logic [3:0] X, Y;
 
   CalcHit DUT(.*);
   
   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       Big = 1'b0;
       #10;
       if (Hit != 1'b0) begin
           $display("test failed for X=1, Y=1, Big=0");
           error = 1'b1;
       end
       Big = 1'b1;
       #10;
       if (Hit != 1'b1) begin
           $display("test failed for X=1, Y=1, Big=1");
            error = 1'b1;
       end
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (Hit != 1'b0) begin
           $display("test failed for X=8, Y=10, Big=1");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       Big = 1'b0;
       #10;
       if (Hit != 1'b1) begin
           $display("test failed for X=2, Y=9, Big=0");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       Big = 1'b1;
       #10;
       if (Hit != 1'b1) begin
           $display("test failed for X=4, Y=3, Big=1");
           error = 1'b1;
       end

       if (!error) $display("All tests pass for CalcHit");
       #10 $finish;
   end
endmodule: CalcHit_test
 
 
module CalcHitNormal_test();
 
   logic HitNormal, error;
   logic [3:0] X, Y;
   CalcHitNormal DUT(.*);
 
   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (HitNormal != 1'b0) begin
           $display("CalcHitNormal test failed for X=1, Y=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (HitNormal != 1'b0) begin
           $display("CalcHitNormal test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (HitNormal != 1'b1) begin
           $display("CalcHitNormal test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (HitNormal != 1'b1) begin
           $display("CalcHitNormal test failed for X=4, Y=3");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcHitNormal");
       #10 $finish;
   end
endmodule: CalcHitNormal_test
 
 
module CalcHitBig_test();
   logic HitBig, error;
   logic [3:0] X, Y;
 
   CalcHitBig DUT(.*);
   
   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (HitBig != 1'b1) begin
           $display("CalcHitBig test failed for X=1, Y=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (HitBig != 1'b0) begin
           $display("CalcHitBig test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (HitBig != 1'b1) begin
           $display("CalcHitBig test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (HitBig != 1'b1) begin
           $display("CalcHitBig test failed for X=4, Y=3");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcHitBig");
       #10 $finish;
   end
endmodule: CalcHitBig_test
 
 
module CalcMiss_test();
   logic Big, Miss, error;
   logic [3:0] X, Y;
 
   CalcMiss DUT(.*);
   
   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       Big = 1'b0;
       #10;
       if (Miss != 1'b1) begin
           $display("CalcMiss test failed for X=1, Y=1, Big=0");
           error = 1'b1;
       end
 
       Big = 1'b1;
       #10;
       if (Miss != 1'b0) begin
           $display("CalcMiss test failed for X=1, Y=1, Big=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (Miss != 1'b1) begin
           $display("CalcMiss test failed for X=8, Y=10, Big=1");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       Big = 1'b0;
       #10;
       if (Miss != 1'b0) begin
           $display("CalcMiss test failed for X=2, Y=9, Big=0");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       Big = 1'b1;
       #10;
       if (Miss != 1'b0) begin
           $display("CalcMiss test failed for X=4, Y=3, Big=1");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcMiss");
       #10 $finish;
   end
endmodule: CalcMiss_test
 
 
module CalcMissNormal_test();
 
   logic MissNormal, error;
   logic [3:0] X, Y;
 
   CalcMissNormal DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (MissNormal != 1'b1) begin
           $display("CalcMissNormal test failed for X=1, Y=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (MissNormal != 1'b1) begin
           $display("CalcMissNormal test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (MissNormal != 1'b0) begin
           $display("CalcMissNormal test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (MissNormal != 1'b0) begin
           $display("CalcMissNormal test failed for X=4, Y=3");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcMissNormal");
       #10 $finish;
   end
endmodule: CalcMissNormal_test
 
module CalcMissBig_test();
   logic MissBig, error;
   logic [3:0] X, Y;
 
   CalcMissBig DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (MissBig != 1'b0) begin
           $display("CalcMissBig test failed for X=1, Y=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (MissBig != 1'b1) begin
           $display("CalcMissBig test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (MissBig != 1'b0) begin
           $display("CalcMissBig test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (MissBig != 1'b0) begin
           $display("CalcMissBig test failed for X=4, Y=3");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcMissBig");
       #10 $finish;
   end
endmodule: CalcMissBig_test
 
 
module CalcNearMiss_test();
   logic Big, NearMiss, error;
   logic [3:0] X, Y;
 
   CalcNearMiss DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       Big = 1'b0;
       #10;
       if (NearMiss != 1'b1) begin
           $display("CalcNearMiss test failed for X=1, Y=1, Big=0");
           error = 1'b1;
       end
 
       Big = 1'b1;
       #10;
       if (NearMiss != 1'b0) begin
           $display("CalcNearMiss test failed for X=1, Y=1, Big=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (NearMiss != 1'b0) begin
           $display("CalcNearMiss test failed for X=8, Y=10, Big=1");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       Big = 1'b0;
       #10;
       if (NearMiss != 1'b0) begin
           $display("CalcNearMiss test failed for X=2, Y=9, Big=0");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       Big = 1'b1;
       #10;
       if (NearMiss != 1'b0) begin
           $display("CalcNearMiss test failed for X=4, Y=3, Big=1");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0100;
       Big = 1'b0;
       #10;
       if (NearMiss != 1'b1) begin
           $display("CalcNearMiss test failed for X=4, Y=4, Big=0");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcNearMiss");
       #10 $finish;
   end
endmodule: CalcNearMiss_test
 
module CalcNearMissNormal_test();
   logic NearMissNormal, error;
   logic [3:0] X, Y;
 
   CalcNearMissNormal DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (NearMissNormal != 1'b1) begin
           $display("NearMissNormal test failed for X=1, Y=1");
           error = 1'b1;
       end
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (NearMissNormal != 1'b0) begin
           $display("NearMissNormal test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (NearMissNormal != 1'b0) begin
           $display("NearMissNormal test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (NearMissNormal != 1'b0) begin
           $display("NearMissNormal test failed for X=4, Y=3");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0100;
       #10;
       if (NearMissNormal != 1'b1) begin
           $display("NearMissNormal test failed for X=4, Y=4");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcNearMissNormal");
       #10 $finish;
   end
endmodule: CalcNearMissNormal_test
 
module CalcNearMissBig_test();
   logic NearMissBig, error;
   logic [3:0] X, Y;
 
   CalcNearMissBig DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       #10;
       if (NearMissBig != 1'b0) begin
           $display("CalcNearMissBig test failed for X=1, Y=1");
           error = 1'b1;
       end
 
 
       X = 4'b1000;
       Y = 4'b1010;
       #10;
       if (NearMissBig != 1'b0) begin
           $display("CalcNearMissBig test failed for X=8, Y=10");
           error = 1'b1;
       end
 
       X = 4'b0010;
       Y = 4'b1001;
       #10;
       if (NearMissBig != 1'b0) begin
           $display("CalcNearMissBig test failed for X=2, Y=9");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0011;
       #10;
       if (NearMissBig != 1'b0) begin
           $display("CalcNearMissBig test failed for X=4, Y=3");
           error = 1'b1;
       end
 
       X = 4'b0100;
       Y = 4'b0100;
       #10;
       if (NearMissBig != 1'b0) begin
           $display("CalcNearMissBig test failed for X=4, Y=4");
           error = 1'b1;
       end
      
       X = 4'b0100;
       Y = 4'b0101;
       #10;
       if (NearMissBig != 1'b1) begin
           $display("CalcNearMissBig test failed for X=4, Y=5");
           error = 1'b1;
       end
      
       X = 4'b0010;
       Y = 4'b0110;
       #10;
       if (NearMissBig != 1'b1) begin
           $display("CalcNearMissBig test failed for X=2, Y=6");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for CalcNearMissBig");
       #10 $finish;
   end
endmodule: CalcNearMissBig_test
 
module IsSomethingWrong_test();
   logic SomethingIsWrong, error;
   logic [3:0] X, Y;
   logic Big, ScoreThis;
   logic [1:0] BigLeft;
 
   IsSomethingWrong DUT(.*);

   initial begin
       error = 1'b0;
       X = 4'b0001;
       Y = 4'b0001;
       Big = 1'b1;
       ScoreThis = 1'b1;
       BigLeft = 2'b10;
       #10;
       if (SomethingIsWrong != 1'b0) begin
           $display("IsSomethingWrong test failed for normal case");
           error = 1'b1;
       end
       X = 4'b0000;
       #10;
       if (SomethingIsWrong != 1'b1) begin
           $display("IsSomethingWrong test failed for X=0");
           error = 1'b1;
       end
       X = 4'b0001;
       Y = 4'b1111;
       #10;
       if (SomethingIsWrong != 1'b1) begin
           $display("IsSomethingWrong test failed for Y=15");
           error = 1'b1;
       end
       Y = 4'b0001;
       BigLeft = 2'b11;
       #10;
       if (SomethingIsWrong != 1'b1) begin
           $display("IsSomethingWrong test failed for bigleft");
           error = 1'b1;
       end
       BigLeft = 2'b00;
       Big = 1'b1;
       #10;
       if (SomethingIsWrong != 1'b1) begin
           $display("IsSomethingWrong test failed for Big assertion");
           error = 1'b1;
       end
       ScoreThis = 1'b0;
       #10;
       if (SomethingIsWrong != 1'b0) begin
           $display("IsSomethingWrong test failed for ScoreThis");
           error = 1'b1;
       end
       if (!error) $display("All tests pass for IsSomethingWrong");
       #10 $finish;
   end
 
endmodule: IsSomethingWrong_test
