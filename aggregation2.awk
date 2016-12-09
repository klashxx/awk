# Data aggregation 2
# Compute how many bytes per IP are processed.
# Example: awk klashxx$ awk -f aggregation2.awk files/ips.dat 
#

NR==1{
    next
    }

lip && lip != $1{
    print lip,sum
    sum=0
    }
{
    sum+=$2
    lip=$1
}

END{
    print lip,sum
    }
