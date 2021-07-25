PROGRAM Fibonacci (output);

CONST
    max = 23;

VAR
    i, j : INTEGER;
    fn   : ARRAY[0..max] OF INTEGER;
    
FUNCTION FIB(n : INTEGER) : INTEGER;
    BEGIN
        IF fn[n] = 0 THEN
            fn[n] := FIB(n-1) + fn[n-2];
        FIB := fn[n];
    END;
    
BEGIN
    fn[0] := 0;
    fn[1] := 1;
    FOR i := 2 to max DO fn[i] := 0;
    
    j := FIB(max);

    FOR i := 0 to max DO BEGIN
        write('Fib[');
        write(i:2);
        write('] = ');
        write(fn[i]:5);
        writeln
    END;
    
    writeln;
    write('*****************************');
    writeln;
    writeln;
    write('Fib[');
    write(max:2);
    write('] = ');
    write(FIB(max):5);
    writeln;
    writeln;
    write('*****************************');
    writeln;
    writeln
END.
