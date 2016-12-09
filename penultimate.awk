# Penultimate word of a Record
# Example: awk -f penultimate.awk files/lorem.dat
#
# Not too much to explain here, NF stores the number of fields in the current record
# NF-1 points to field before last and $(NF-1) will be its value.
{print $(NF-1)}