#!/usr/bin/awk -f
# ARGV[1] = number of expected checks

# Comments can be added to interactive debug instruction stream
# and checked using this script.
# The checking convention is: CHECK <id> <regexp>
# regexp and have multiple \n characters but not a trailing \n

BEGIN {
    rc=ARGV[1]; ARGV[1]=""
    count=0; lines=""; check=-1
}
/# CHECK [0-9]+ / {
    lines="";
    check=$4;
    re=substr($0,index($0,$5));
    count=gsub(/\\n/,"\\n",re) + 1; //assumes no trailing newline
}
{ if (check==-1) {next}; 
    lines = sprintf("%s\n%s",lines,$0);
    if (count-- <= 0) {
        print check; 
        printf("TEST[%d] %s\n",check,lines);
        # printf("RE[%d] %s\n", check, re);
        if (!match(lines,re)) {
            printf("ERROR: Failed TEST[%d]\n",check);
            rc = 42
            exit rc;
        }
        rc--; check=-1;
    }
}
END { exit rc; }
