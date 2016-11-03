($1 !~ /;/) && ($2 ~ /;/) { printf("\t\t\t%-8s\n", $1)                           }
($1 !~ /;/) && ($3 ~ /;/) { printf("\t\t\t%-8s%-s\n", $1, $2)                    }
($2 ~/PROC/             ) { printf("%-s\t.SUB\n",  $1)                           }
($1 ~ /^L_[0-9]{3}:/    ) { printf("%-s\t.LBL\n", substr($1, 1, length($1) - 1)) }
($1 ~ /^S_[0-9]{3}$/    ) { split($0, strdef, "\"")
                            split(strdef[1], strlit, " ")
                            printf("%-s\t.%-4s", strlit[1], strlit[2])
                            printf(" \"%s\"\n", strdef[2])
                            next
                          }
($1 ~ /^[a-zA-Z][a-zA-Z_0-9]*_[0-9]{3}$/) { printf("%-s\t.%-4s %-s\n", $1, $2, $3) }

