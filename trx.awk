# trx
# Example: awk -v bomb=71004269 -f trx.awk files/trx.dat

BEGIN{FS="="}
$2==bomb && gsub(/^PLU|,.*/,"",$1){b[$1]}
$1 ~ /^REF/ {r[$1]=$2}
END{
    for (i in b){
        for (j in r){
            if (j ~ i){
                print r[j]
            }
        }
    }
}
