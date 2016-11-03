BEGIN {
    # Conditional/Unconditional 8-bit PC-relative Branch Instructions
	branch["bra"] = 2
	branch["beq"] = 2
	branch["bne"] = 2
	branch["bgt"] = 3
	branch["bge"] = 3
	branch["blt"] = 3
	branch["ble"] = 3

    # Conditional/Unconditional 16-bit PC-relative Jump Instructions
	jump["jra"] = 4
	jump["jeq"] = 3
	jump["jne"] = 3
	jump["jgt"] = 4
	jump["jge"] = 4
	jump["jlt"] = 4
	jump["jle"] = 4
}

($1 !~ /^[\._/]{1}/) && ($1 !~ /_[0-9]{3}$/) {
    #count[$1] += 1 }
	if(NF < 2) count[$1 "_imp"] += 1
	else if($2 ~ /^[aA]$/) count[$1 "_A"] += 1
	else if($2 ~ /^[xX]$/) count[$1 "_X"] += 1
	else if($2 ~ /^[yY]$/) count[$1 "_Y"] += 1
	else if(($2 ~ /^[#]/) && ($1 ~ /[wW]$/)) count[$1 "_imm16"] += 1
	else if($2 ~ /^[#]/)          count[$1 "_imm"]   += 1
	else if($2 ~ /,[sS]$/)        count[$1 "_sp"]    += 1
	else if($2 ~ /,[sS])$/)       count[$1 "_spI"]   += 1
	else if($2 ~ /,[sS]),[yY]$/)  count[$1 "_spIY"]  += 1
	else if($2 ~ /,[bB]$/)        count[$1 "_bp"]    += 1
	else if($2 ~ /,[bB])$/)       count[$1 "_bpI"]   += 1
	else if($2 ~ /,[bB]),[yY]$/)  count[$1 "_bpIY"]  += 1
	else if($1 in branch)         count[$1 "_rel"]   += 1
	else if($1 in jump)           count[$1 "_rel16"] += 1
	else if($1 == "jmp")          count[$1 "_abs"]   += 1
	else if($1 == "jsr")          count[$1 "_abs"]   += 1
	else if($2 ~ /_[0-9]{3}\+2$/) count[$1 "_abs"]   += 1
	else if($2 ~ /_[0-9]{3}$/)    count[$1 "_abs"]   += 1
	else count[$1 "_" $2] += 1
}

END { for(label in count) printf("%-12s %4d\n", label, count[label]) }

