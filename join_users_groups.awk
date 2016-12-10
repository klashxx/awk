# Passwd and Group
# Example: awk -f join_users_groups.awk files/group files/passwd
#
# 


BEGIN{
    FS=":"
    }
NR == FNR{g[$3]=$1;next}
$4 in g{print $1""FS""g[$4]}