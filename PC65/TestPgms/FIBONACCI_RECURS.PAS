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
    fn[0] := 1;
    fn[1] := 1;
    FOR i := 2 to max DO fn[i] := 0;

{     FOR i := 0 to max DO BEGIN
        j := FIB(i);
        write('Fib[');
        write(i:2);
        write('] = ');
        write(j:5);
        writeln
    END
 }
    i := max;
    j := FIB(22);
    write('Fib[');
    write(i:2);
    write('] = ');
    write(j:5);
    writeln
 
 END.
