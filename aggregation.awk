# Data aggregation
# Compute how many bytes per IP are processed.
# Example: awk klashxx$ awk -f aggregation.awk files/ips.dat 
#

NR>1{
    ips[$1]+=$2
    }
END{
    for (ip in ips){
        print ip, ips[ip]
        }
    }
