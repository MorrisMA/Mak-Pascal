PROGRAM Fibonacci (output);

CONST
    max = 23;

VAR
    FN1, FN2 : INTEGER;
    tmp, i   : INTEGER;
    
BEGIN
    FN1 := 1;
    FN2 := 0;
    
    FOR i := 2 to max DO BEGIN
        tmp := FN1 + FN2;
        FN2 := FN1;
        FN1 := tmp;
    END;
    write('Fib[');
    write(i:2);
    write('] = ');
    write(FN1:5);
    writeln;
END.
