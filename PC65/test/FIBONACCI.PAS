PROGRAM Fibonacci (output);

CONST
    max = 22;

VAR
    FN, FN1, FN2 : INTEGER;
    i            : INTEGER;
    
BEGIN
    FN1 := 1;
    FN2 := 0;
    
    FOR i := 2 to max DO BEGIN
        FN  := FN1 + FN2;
        FN2 := FN1;
        FN1 := FN;
    END;
    
    write('Fibonacci[');
    write(max:2);
    write('] = ');
    write(FN:5);
    writeln;
END.
