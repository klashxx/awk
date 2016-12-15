# SQL order just want columns inside the brackets.
# Example: awk -f sql_order.awk files/ddl.sql

BEGIN{PROCINFO["sorted_in"] = "@ind_str_asc"}
/^\(/{f=1}
/^\)/{f=0
      for (i in a)
        print a[i]
      delete a}
f{a[$1]=$0}
!f
