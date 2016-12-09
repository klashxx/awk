# Redirecting odd records to a file and even ones to another
# Example: awk -f even_odd.awk files/lorem.dat
#
# The modulo function (%) finds the remainder after division for the current Record Number NR divided by two.
# As far as we now yet, in awk 1 is True and 0 False. We redirect our output evaluating this fact.

BEGIN{
  EVEN="files/even.dat.tmp"
  ODD="files/odd.dat.tmp"
  }

NR%2{print > EVEN
     next
     }
{print > ODD}