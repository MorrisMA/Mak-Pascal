PROGRAM Fibonacci (output);

CONST
    max = 23;

VAR
    i, j : INTEGER;
    fn   : ARRAY[0:23] OF INTEGER;
    
FUNCTION FIB(n : INTEGER) : INTEGER;
    VAR i, tmp, fn1, fn2 : INTEGER;
    
    BEGIN
        fn1 := 1;
        fn2 := 0;
        
        IF n < 1 THEN
            FIB := fn2
        ELSE BEGIN
            i := 1;
            REPEAT
                tmp := fn1 + fn2;
                fn2 := fn1;
                fn1 := tmp;
                
                i := i + 1
            UNTIL (i >= n);
            
            FIB := fn1
        END
    END;
    
BEGIN
{
    FOR i := 1 to max DO BEGIN
        j := FIB(i);
    END;
}
    i := max;
    j := FIB(i);
    write('Fib[');
    write(i:2);
    write('] = ');
    write(j:5);
    writeln
END.
