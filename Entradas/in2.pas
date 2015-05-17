program Fatorial;
var
  n, x, Contador, fatorial:integer;
begin
  write ("Entre com um inteiro nao-negativo: ");
  read (n);
 
  fatorial := 1;
  Contador := 1;
  repeat
    fatorial := fatorial*Contador;
    Contador := Contador+1;
  until Contador > n;
end.
