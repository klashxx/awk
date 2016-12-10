# Records between two patterns
# Example: awk -v begin="^OUTPUT" -v end="^END" -f patterns.awk files/pat.dat

$0 ~ end{flag=0}
flag
$0 ~ begin{flag=1}