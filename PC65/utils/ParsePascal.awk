BEGIN {
    FS = "[ \t]+"           
}
($2 ~ /[\.]sub/         ) { printf("%-s\t.SUB\n",  $1);         next }
($2 ~ /[\.]equ/         ) { printf("%-s\t.EQU\t%-s\n", $1, $3); next }
($2 ~ /[\.]byt/         ) { printf("%-s\t.BYT\t%-s\n", $1, $3); next }
($2 ~ /[\.]flt/         ) { printf("%-s\t.FLT\t%-s\n", $1, $3); next }
($2 ~ /[\.]str/         ) { split($0, strdef, "\"")
                            split(strdef[1], strlit, " ")
                            printf("%-s\t.STR", strlit[1])
                            printf(" \"%s\"\n", strdef[2])
                            next
                          }
($1 ~ /^L_[0-9]{3}$/    ) { printf("%-s\t.LBL\n", 
                                   substr($1, 1, length($1)))
                            next
                          }

#($1 ~ /^S_[0-9]{3}$/    ) { split($0, strdef, "\"")
#                            split(strdef[1], strlit, " ")
#                            printf("%-s\t%-4s", strlit[1], strlit[2])
#                            printf(" \"%s\"\n", strdef[2])
#                            next
#                          }

($1 !~ /;/) && ($3 ~ /;/) { if ($2 != "")
                                printf("\t\t%-s\n", $2)
                            next
                          }
($1 !~ /;/) && ($2 ~ /./) { printf("\t\t%-4s\t%-s\n", $2, $3); next }

