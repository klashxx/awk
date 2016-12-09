 # Example: awk -v ors="<<\n" -v ofs="-" -f ofs_ors.awk files/lorem.dat
BEGIN{ORS=ors;OFS=ofs}
{$1=$1}
{print}
