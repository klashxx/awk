# Last field should become first and first become last.
# Example: awk -f field_swap.awk files/passwd
#
# We are playing with an intermediate variable used to store the first field value

BEGIN{
    FS=":"
    OFS=FS
    }
{
    last=$1
    $1=$NF
    $NF=last
}
{
    print 
}

