# Traceroute hacking
# Example: traceroute bad.horse 2>/dev/null | awk -f troute.awk

{
    total+=$(NF-1)
}
END{
    print "Total ms: "total
   }
