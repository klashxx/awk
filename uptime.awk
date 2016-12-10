#
# Example:
#
# get the total load average mean

BEGIN{FS="(:|,) +"}
{printf "Load average mean: %0.2f\n", ($(NF-2)+$(NF-1)+$(NF))/3 }
