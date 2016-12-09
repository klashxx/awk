# Example: awk -v ending="<<" -f line_ending.awk files/lorem.dat
BEGIN{ORS=ending}
{print}
