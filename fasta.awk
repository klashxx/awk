# FASTA File processing
# Example: awk -f fasta.awk files/fasta.dat 
#
# We need the total length of each sequence, and a final resume.

/^>/ {
    if (seqlen) {
        print seqlen
        }
    print
    seqtotal+=seqlen
    seqlen=0
    seq+=1
    next
    }
{
    seqlen += length($0)
}
END{
    print seqlen
    print seq" sequences, total length " seqtotal+seqlen
    }