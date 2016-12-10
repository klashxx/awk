# Get total weight in mega bytes.
# Example: awk -f space_transformation.awk files/space.dat
#
{
    total+= $1 / ($2=="kb" ? 1024: 1)
}
END{
    print total
    }
