program ABasicProgram;

var
   UserChoice : CHAR; 
   UserInput  : REAL; 
   Answer     : REAL; 

procedure ShowTheMenu();
begin
     writeln();
     writeln("     A Basic Program");
     writeln("     ---------------");
     writeln(" a) Celcius to Fahrenheit");
     writeln(" b) Fahrenheit to Celcius");
     writeln();
     writeln(" x) To exit the program");
     writeln();
end;

procedure GetUserChoice();
begin
    write("Enter your choice:       ");
    readln(UserChoice);
end;

procedure GetNumberToConvert();
begin
   write("Enter number to convert: ");
   readln(UserInput);
end;

procedure Wait();
begin
    write("Press RETURN to continue ...");
    readln();
end;

function ToFahrenheit(x: REAL): REAL;
begin
     ToFahrenheit := 9/5 * x + 32;
end;

function ToCelcius(x: REAL): REAL;
begin
     ToCelcius := 5/9 * (x - 32);
end;


procedure DoTheConversion();
begin
     if (UserChoice =  a) then
        answer := ToFahrenheit(UserInput);
     if (UserChoice = b) then
	begin
        answer := ToCelcius(UserInput);
	end;
end;


procedure DisplayTheAnswer();
begin
     writeln();
     writeln("        Degree");
     if (UserChoice = "a") then
        writeln("Celcius    | Fahrenheit");
     if (UserChoice = "b") then
        writeln("FahrenHeit |   Celcius");
     writeln("------------------------");
     writeln();
     writeln();
end;


begin
   UserChoice := "q";
   while (UserChoice <> "x") do
      begin
         ShowTheMenu();
         GetUserChoice();
         if (UserChoice = "a") or
            (UserChoice = "b") then
           begin
              GetNumberToConvert();
              DoTheConversion();
              DisplayTheAnswer();
              Wait();
           end;
      end;
end.
