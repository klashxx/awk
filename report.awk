# Complex reporting
# Example: awk -f report.awk files/report.dat
#
# Create a report to visualize snaps and instance but only when snap first counter tag is greater than zero.

{
    $1=$1
}
/snaps1/ && $NF>0{print;f=1}
f &&  /Instance/ {print;f=0}
