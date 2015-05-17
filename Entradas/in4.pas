program arrayprog;

(* Demonstrate array usage. *)

var
      a: integer;
      b: array [0..3] of integer;
      i,j,k: integer;
      array1D : array [1..5] of integer;
      array3D : array [1..5,2..3,0..2] of integer;

begin
   for i := 1 to 5 do
      for j := 2 to 3 do
         for k := 0 to 2 do
             a[i,j,k] := i;

   for i := 0 to 3 do
      for j := 1 to 5 do
         b[i,j] := i+j;



   for i := 5 downto 1 do
      for j := 3 downto 2 do begin
         for k := 0 to 2 do
            write(a[i,j,k], " ");
	 writeln();
      end;
   writeln();



   for i := 0 to 3 do begin
      for j := 1 to 5 do
         write(b[i,j], " ");
      writeln();
   end;
end.


