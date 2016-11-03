BEGIN {
    for(i = 1; i < ARGC; i += 1) {
        while(getline <ARGV[i] > 0) {
            count[$1] += $2
        }

        close(ARGV[i])
    }
}

END { for(label in count) printf("%-12s %4d\n", label, count[label]) }

