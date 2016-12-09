# File record substitution
# Example: awk -f record_replace.awk files/lorem.dat
#
# Third line must become: This not latin
# Fifth: Neither this
NR==3{print "This is not latin";next}
NR==5{$0="Neither this"}
1
