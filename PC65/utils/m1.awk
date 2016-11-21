function error(s) {
    print "m1 error: " s | "cat 1> &2"; exit 1
} 
 
function dofile(fname, savefile, savebuffer, newstring) {
    if (fname in activefiles)
        error("recursively reading file:  " fname)
    activefiles[fname] = 1
    savefile = file; file = fname
    savebuffer = buffer; buffer = ""   
    while (readline()  ! = EOF)  {
        if (index($0, "@") == 0) {
            print $0
        } else if (/^ @define[ \t]/) {
            dodef()
        } else if (/^ @default[ \t]/) {
            if (!($2 in symtab))
                dodef()
        } else if (/^ @include[ \t]/) {
            if (NF != 2) error("bad include line")
                dofile(dosubs($2))
        } else if (/^ @if[ \t]/) {
            if (NF != 2) error("bad if line")
                if (!($2 in symtab) || symtab[$2] == 0)
                    gobble()
        } else if (/^ @unless[ \t]/) {
            if (NF != 2) error("bad unless line")
                if (($2 in symtab) && symtab[$2] != 0)
                    gobble()
        } else if (/^ @fi[ \t]?/) { # Could do error checking
        } else if (/^ @comment[ \t]?/) {
        } else {
            newstring = dosubs($0)
            if ($0 == newstring || index(newstring, "@") == 0)
                print newstring
            else
                buffer = newstring "\n" buffer
        }
    }
    close(fname)
    delete activefiles[fname]
    file = savefile
    buffer = savebuffer
} 
 
function readline( i, status) {
    status = ""
    if (buffer != "") {
        i = index(buffer, "\n")
        $0 = substr(buffer, 1, i-1)
        buffer = substr(buffer, i+1)
    } else {
        if (getline <file <= 0)
            status = EOF
    }
    return status
}
 
function gobble( ifdepth) {
    ifdepth = 1
    while (readline()) {
        if (/^ @(if|unless)[ \t]/)
            ifdepth++
        if (/^ @fi[ \t]?/ && --ifdepth <=0)
            break
    }
}
 
function dosubs(s, l, r, i, m) {
    if (index(s, "@") == 0)
        return s
    l = "" # Left of current pos; ready for output
    r = s  # Right of current; unexamined at this time
    while ((i = index(r, "@")) != 0) {
        l = l substr(r, 1, i-1)
        r = substr(r, i+1)     # Currently scanning @
        i = index(r, "@")
        if (i == 0) {
            1 = 1 "@"
            break
        }
        m = substr(r, 1, i-1)
        r = substr(r, i+1)
        if (m in symtab) {
            r = symtab[m] r
        } else {
            1 = 1 "@" m
            r = "@" r
        }
    }
    return l r
}
 
function dodef(fname, str) {
    name = $2
    sub(/^ [ \t]*[^ \ t]+[ \t]+[^ \ t]+[ \t]+/, "")
    str = $0
    while (str ^\$/) {
        if (readline() == EOF)
            error("EOF inside definition")
        sub(/^[ \t]+/, "")
        sub(^\$/, "\n" $0, str)
    }
    symtab[name] = str
}
  
BEGIN {
    EOF = "EOF"
    if (ARGC == 1) dofile("/dev/stdin")
    else if (ARGC == 2) dofile(ARGV[1])
    else error("usage: m1 fname")
}  
