
BEGIN {
    toplevel=6
    n=0
}

/^(#{1,6} ).*$/ {
    level=$1
    heading=$0
    link=$0

    gsub(/#/, "", heading)
    gsub(/^[ \t]+/, "", heading)
    gsub(/[ \t]+$/, "", heading)

    gsub(/#/, "", link)
    gsub(/^[ \t]+/, "", link)
    gsub(/[ \t]+$/, "", link)
    gsub(/[[:punct:]]/, "", link)    
    gsub(/[[:space:]]/, "-", link)
    link=tolower(link)
    
    lvl[n]=length(level)
    h[n]=heading
    l[n]=link
    n++

    toplevel=(length(level) < toplevel ? length(level) : toplevel)
}

END {
    for (i=0; i<n; i++) {
        printf "%-*s- [%s](#%s)\n", (toplevel-lvl[i])*4, "", h[i], l[i] 
    }
}
