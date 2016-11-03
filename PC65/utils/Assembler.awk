BEGIN {
    op_file = ARGV[1]       # Opcode file
    srcfile = ARGV[2]       # Source file
    ARGV[2] = ""            # Any other argument list files are data files
    
    split(srcfile, fn_ext, ".")
    tmpfile = fn_ext[1] ".p01"      # Temporary file
    outfile = fn_ext[1] ".out"      # Output file

    printf("\n\n----------------------------------------------------------\n\n")
    printf("%-s => %-s : %-s => %-s", srcfile, fn_ext[1], fn_ext[2], tmpfile)
    printf("\n")
    printf("%-s => %-s : %-s => %-s", srcfile, fn_ext[1], fn_ext[2], outfile)
    printf("\n\n----------------------------------------------------------\n\n")
    printf("Opcode Table")
    printf("\n\n----------------------------------------------------------\n\n")
    while(getline <op_file > 0) {
        op_len[$1] = $3 + $4        # Total length - instruction + data lengths
        dt_len[$1] = $4             # Data Length
        opcode[$1] = $5             # Instruction (prefix + opcode)
        
        printf("%-12s: %-12s %2d %2d\n", $1, opcode[$1], op_len[$1], dt_len[$1])
    }
    close(op_file)          # Close opcode file

    # Conditional/Unconditional 8/16-bit PC-relative Branch/Jump Instructions
	
	branch["bra"] = 2;  jump["jra"] = 4     # branch/jump relative always
	branch["beq"] = 2;  jump["jeq"] = 3     # branch/jump relative if( Z)
	branch["bne"] = 2;  jump["jne"] = 3     # branch/jump relative if(!Z)
	branch["bgt"] = 3;  jump["jgt"] = 4     # branch/jump relative if()
	branch["bge"] = 3;  jump["jge"] = 4     # branch/jump relative if()
	branch["blt"] = 3;  jump["jlt"] = 4     # branch/jump relative if()
	branch["ble"] = 3;  jump["jle"] = 4     # branch/jump relative if()

    # Set field separator: one or more spaces or tabs
    
    FS = "[ \t]+"           

    # Assembler Pass 1
    
    printf("\n\n----------------------------------------------------------\n\n")
    printf("Assembler Pass 1")    
    printf("\n\n----------------------------------------------------------\n\n")
    
    while(getline <srcfile > 0) {
        sub(/;.*/, "")          # strip comments from the input line
        symtab[$1] = nextmem
        if($1 == "") {
            op = $2
            if(op !~ /^[\._/]{1}/) {
	            if($3 == "") op = op "_imp"
	            else if($3 ~ /^[aA]$/) op = op "_A"
	            else if($3 ~ /^[xX]$/) op = op "_X"
	            else if($3 ~ /^[yY]$/) op = op "_Y"
	            else if(($3 ~ /^[#]/) && ($2 ~ /[wW]$/)) op = op "_imm16"
	            else if($3 ~ /^[#]/)          op = op "_imm"
	            else if($3 ~ /,[sS]$/)        op = op "_sp"
	            else if($3 ~ /,[sS])$/)       op = op "_spI"
	            else if($3 ~ /,[sS]),[yY]$/)  op = op "_spIY"
	            else if($3 ~ /,[bB]$/)        op = op "_bp"
	            else if($3 ~ /,[bB])$/)       op = op "_bpI"
	            else if($3 ~ /,[bB]),[yY]$/)  op = op "_bpIY"
	            else if(op in branch)         op = op "_rel"
	            else if(op in jump)           op = op "_rel16"
	            else if(op == "jmp")          op = op "_abs"
	            else if(op == "jsr")          op = op "_abs"
	            else if($3 ~ /_[0-9]{3}\+2$/) op = op "_abs"
	            else if($3 ~ /_[0-9]{3}$/)    op = op "_abs"
	            else op = "XXXXXXXXXXX"
	            
                if(length($2) < 4) { 
                    print op "\t\t" $3 > tmpfile
                    printf("%04X: %-11s %2d\t%-4s\t%-s\n", 
                           nextmem, op, op_len[op], $2, $3)
                } else {
                    print op "\t" $3 > tmpfile
                    printf("%04X: %-11s %2d\t%-4s\t%-s\n",
                           nextmem, op, op_len[op], $2, $3)
                }
                nextmem += op_len[op]
            }
        } else {
            if($2 == ".ORG") {                  #define memory start address
                nextmem = $3
            } else if($2 == ".EQU") {           #define constants
                symtab[$1] = $3
            } else if($2 == ".DB") {            #define variables
                nextmem += ($3 * 1)
            } else if($2 == ".DD") {            #define float literals
                nextmem += 4
            } else if($2 == ".DS") {            #define string literals
                split($0, string, "\"")
                nextmem += length(string[2])
            }
        }
    }
    close(tmpfile)

    printf("\n\n----------------------------------------------------------\n\n")
    printf("Assembler Symbol Table")    
    printf("\n\n----------------------------------------------------------\n\n")
    
    for(i in symtab) printf("%-20s => %04X\n", i, symtab[i])
    
    # Assembler Pass 2
    
    printf("\n\n----------------------------------------------------------\n\n")
    printf("Assembler Pass 2")    
    printf("\n\n----------------------------------------------------------\n\n")
    
    nextmem = 0
    while(getline <tmpfile > 0) {
        op      = $1
        operand = $2
        
        split(op, instruction_operand, "_")
        op_code = instruction_operand[1]
        addr_md = instruction_operand[2]
        
        op_val = -1
        if(operand in symtab) {
            op_val = symtab[operand]
        } else if(operand ~ /^[#]/) {
            op_val = substr(operand, 2)
            if(op_val !~ /^[0-9]+$/) {
                op_val = symtab[op_val]
            }
        }

        len = dt_len[op]
        if(len == 1) {
            if(op_val < 0) {
                op_val *= -1
                lo = (256 - (op_val % 256))
            } else {
                lo = (op_val % 256)
            }
            instruction = sprintf("%s%02X", opcode[op], lo)
        } else if(len == 2) {
            if(op_val < 0) {
                op_val *= -1
                lo = (256 - (op_val % 256))
                hi = (256 - ((op_val / 256) % 256))
            } else {
                lo = (op_val % 256)
                hi = (op_val / 256) % 256
            }
            instruction = sprintf("%s%02X%02X", opcode[op], lo, hi)
        } else {
            instruction = sprintf("%s", opcode[op])
        }
        
        printf("%04X: %-8s\t; %-6s\t%-s\n",
               nextmem, instruction, op, operand)

        printf("%04X: %-8s\t; %-6s\t%-s\n",
               nextmem, instruction, op, operand) > outfile
               
        nextmem += op_len[op]
    }
    close(tmpfile)
    close(outfile)
}

