# Group records in blocks of num_col
# Example: awk -v num_col=3 -f rec2col.awk files/group.dat
#

ORS = NR % num_col ? FS : RS
END{
    print "\n"
   }
