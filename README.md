# AWK
#### Examples from my practical [Guide](https://klashxx.github.io/awk-power-for-your-cmd)


### A beginner\'s guide to the *nix swiss army knife

## :warning: Disclaimer :warning:

This text refers only to `awk`'s **GNU** implementation known as _`gawk`_ witch is the most used one and comes with any modern *Linux* / *Unix* distribution.

[The GNU Awk User’s Guide][gnu-awk] is its reference, for the *examples* I used real world cases taken mainly from my [Stackoverflow][so] answers.


<hr>

> AWK is a language similar to PERL, only considerably more elegant.
>
> - Arnold Robbins

#### *What ??*

> AWK is a programming language designed for text processing and typically used as a data extraction and reporting tool.
> It is a standard feature of most Unix-like operating systems.

#### `awk`award name ...

> its name is derived from the surnames of its authors – Alfred **A**ho, Peter **W**einberger, and Brian **K**ernighan.


### So `awk` ...

* Searchs for lines that contain certain patterns in files or the standard input.

* Mostly used for data extraction and reporting like summarizing information from the output of other utility programs.

* `C-like` syntax.

* Data Driven: it's describe the data you want to work with and then what action to do when you find it.


```` shell
pattern { action }
pattern { action }
````

<hr>

### The Basics

#### How to Run it

If the program is **short**:

```` shell
awk 'program' input-file1 input-file2
````
**Note:** Beware of shell quoting issues[^1].


```` shell
cmd | awk 'program'
````
**Note:** The `pipe` redirects the output of the *left-hand* command (`cmd`) to the **input** of the `awk` command[^2].

When the code is **long**, it is usually more convenient to put it in a file and run it with a command like this:

```` shell
awk -f program-file input-file1 input-file2

cmd | awk -f program-file
````

Or just make it executable like a `shebang`:

```` shell
#!/bin/awk -f

BEGIN { print "hello world!!" }
````

#### Other useful flags

`-F fs` Set the `FS` variable to `fs`.

`-v var=val` Set the variable `var` to the value `val` before execution of the program begins. 

:point_right: **Note**: it can be used more than once, *setting* another variable each time.

#### BEGIN and END

These special patterns or blocks supply *startup* and *cleanup* actions for `awk` programs. 

```` shell
BEGIN{
    // initialize variables
}
{
    /pattern/ { action }
}
END{
    // cleanup
}
````

:warning: **WARNING**: Both rules are executed **once only**, `BEGIN` before the first input record is read, `END` after all the input is consumed.

```` shell
$ echo "hello"| awk 'BEGIN{print "BEGIN";f=1}
                    {print $f}
                    END{print "END"}'
BEGIN
hello
END
````

<hr>

#### Why _`grepping`_ if you have `awk` ??


```` shell
$ cat lorem_ipsum.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim orci, euismod id nisi eget, interdum cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

```` shell
$ grep dolor lorem_ipsum.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
````

```` shell
$ awk '/dolor/' lorem_ipsum.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
````
:point_right: **Note:** If the action is not given the **default action** is to print the record that matches the given pattern.

But... how can we find out the *first* and *last* word of each line?

Of course `grep` can, but needs two steps:

```` shell 
$ grep -Eo '^[^ ]+' lorem_ipsum.dat 
Lorem
Maecenas
Nunc
Curabitur
Lorem
Aliquam
````

```` shell
$ grep -Eo '[^ ]+$' lorem_ipsum.dat 
elit.
condimentum.
ex.
tellus.
elit.
ultrices.
````

Let\'s see `awk` in action here:

```` shell
$ awk '{print $1,$NF}' lorem_ipsum.dat 
Lorem elit.
Maecenas condimentum.
Nunc ex.
Curabitur tellus.
Lorem elit.
Aliquam ultrices.
````

<hr>

### Isn't this better :sunglasses:? Yeah, but... HTF does this works?

`awk` divides the input for your program into *Records* and *Fields*.

#### Records

*Records* are separated by a character called the *record separator* `RS`.  *By default*, the record separator is the *unix* newline character `\n`. 

This is why records are, **by default**, *single lines*.

Additionally `awk` has `ORS` *Output Record Separator* to control the way records are presented to the `stdout`.

`RS` and `ORS` should be enclosed in **quotation marks**, which indicate a string *constant*. 

To use a different character or a *regex* simply assign it to the `RS` or / and  `ORS` variables:

- Often, the right time to do this is at the beginning of execution `BEGIN`, before any input is processed, so that the very first record is read with the proper separator. 
- Another way to change the record separator is on the command line, using the variable-assignment feature.

Examples:


```` shell
$ awk 'BEGIN{RS=" *, *";ORS="<<<---\n"}
       {print $0}' lorem_ipsum.dat 
Lorem ipsum dolor sit amet<<<---
consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim orci<<<---
euismod id nisi eget<<<---
interdum cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet<<<---
consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat<<<---
et facilisis neque ultrices.
<<<---
````

```` shell
$ awk '{print $0}' RS=" *, *" ORS="<<<---\n" lorem_ipsum.dat 
Lorem ipsum dolor sit amet<<<---
consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim orci<<<---
euismod id nisi eget<<<---
interdum cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet<<<---
consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat<<<---
et facilisis neque ultrices.
<<<---
````

#### Fields

`awk` records are automatically parsed or separated into *chunks* called **fields**. 

By default, fields are separated by **whitespace** (any string of one or more spaces, TABs, or newlines), like words in a line.

To refer to a field in an `awk` program, you use a dollar `$` sign followed by the number of the field you want. 

Thus, `$1` refers to the first field, `$2` to the second, and so on. 

:point_right: **IMPORTANT**: `$0` represents the whole input record.

```` shell
$ awk '{print $3}' lorem_ipsum.dat 
dolor
erat
orci,
dapibus
dolor
mauris
````

`NF` is a predefined variable it\'s value is the **number of fields in the current record**. So, `$NF` will be always the last field of the record.

```` shell
$ awk '{print NF}' lorem_ipsum.dat 
8
7
10
4
8
10
````

`FS` holds the valued of the *field separator*, this value is a single-character string or a `regex` that matches the separations between fields in an input record. 

The default value is `"  "`, a string consisting of a single space. As a special exception, this value means that any sequence of *spaces*, *TABs*, and/or *newlines* is a single separator.

In the same fashion that `ORS` we have a `OFS` variable to manage how our fields are going to be send to the output stream.

```` shell
$ cat /etc/group
nobody:*:-2:
nogroup:*:-1:
wheel:*:0:root
daemon:*:1:root
kmem:*:2:root
sys:*:3:root
tty:*:4:root
````

```` shell
$ awk '!/^(_|#)/&&$1=$1' FS=":" OFS="<->" /etc/group
nobody<->*<->-2<->
nogroup<->*<->-1<->
wheel<->*<->0<->root
daemon<->*<->1<->root
kmem<->*<->2<->root
sys<->*<->3<->root
tty<->*<->4<->root
````

**Note**: Ummm ... `$1=$1` ????[^3]

<hr>

Keeping *records* and *fields* in mind, were now ready to understand our previous code:

```` shell
$ awk '{print $1,$NF}' lorem_ipsum.dat 
Lorem elit.
Maecenas condimentum.
Nunc ex.
Curabitur tellus.
Lorem elit.
Aliquam ultrices.
````

#### NR and FNR

These are two useful built-in variables:

`NR` : number of input records `awk` has processed since the beginning of the program’s execution.

`FNR` : current record number in the current file, `awk` resets `FNR` to *zero* each time it starts a new input file.

```` shell
$ cat n1.dat 
one
two
````

```` shell
$ cat n2.dat 
three
four
````

```` shell
$ awk '{print NR,FNR,$0}' n1.dat n2.dat 
1 1 one
2 2 two
3 1 three
4 2 four
````

#### Fancier Printing

The format string is very similar to that in the *ISO C*.

Syntax:

`printf format, item1, item2, …`

```` shell
$ awk '{printf "%20s <-> %s\n",$1,$NF}' lorem_ipsum.dat 
               Lorem <-> elit.
            Maecenas <-> condimentum.
                Nunc <-> ex.
           Curabitur <-> tellus.
               Lorem <-> elit.
             Aliquam <-> ultrices.
````


#### Redirecting Output

Output from `print` and `printf` is directed to the *standard output* by default but we can use redirection to change the destination.

Redirections in `awk` are written just like redirections in *shell* commands, except that they are written inside the `awk` program.

```` shell
$ awk 'BEGIN{print "hello">"hello.dat"}'
````

```` shell
$ awk 'BEGIN{print "world!">>"hello.dat"}'
````

```` shell
$ cat hello.dat 
hello
world!
````

It is also possible to send output to another program through a *PIPE*:

```` shell
$ awk 'BEGIN{sh="/bin/sh";print "date"|sh;close(sh)}'
dom nov 13 18:36:25 CET 2016
````

The [streams] can be pointed to the `stdin`, the `stdout` and the `stderr`.

For example,  we can write an error message to the `stderr` like this:

```` shell
$ awk 'BEGIN{print "Serious error detected!" > "/dev/stderr"}'
Serious error detected!
````
<hr>

#### Working with arrays

In awk the arrays are **associative**, each one is a collection of *pairs*, **index** – **value**, where the any number or string can be an index.

No declaration is needed; new pairs can be added at any time.

Index  | Value
-------|---------
"perro" | "dog"
"gato"  | "cat"
"uno" | "one"
1  | "one"
2  | "two"

To refer an array:

`array[index-expression]`

To assign values:

`array[index-expression] = value`

To check if a key is indexed:

`indx in array`

To iterate it:

```` shell
for (var in array) {
    var, array[var]
    }
````

Using numeric values as indexes and preserving the order:

```` shell
for (i = 1; i <= max_index; i++) {
    print array[i]
    }
````

A complete example:

```` shell
$ cat dict.dat
uno one
dos two
tres three
cuatro four
````

```` shell
awk '{dict[$1]=$2}
     END{if ("uno" in dict)
           print "Yes we have uno in dict!"
         if (!("cinco" in dict))
           print "No , cinco is not in dict!"
         for (esp in dict){
            print esp, "->" ,dict[esp]
            }
     }'  dict.dat
````

Gives you:

```` shell
Yes we have uno in dict!
No , cinco is not in dict!
uno -> one
dos -> two
tres -> three
cuatro -> four
````

`gawk` does not sort arrays by default:

```` shell
awk 'BEGIN{
      a[4]="four"
      a[1]="one"
      a[3]="three"
      a[2]="two"
      a[0]="zero"
      exit
      }
      END{for (idx in a){
             print idx, a[idx]
             }
      }'
````

```` shell
4 four
0 zero
1 one
2 two
3 three
````

But you can take advantage of [PROCINFO] for sorting:

```` shell
awk 'BEGIN{
      PROCINFO["sorted_in"] = "@ind_num_asc"
      a[4]="four"
      a[1]="one"
      a[3]="three"
      a[2]="two"
      a[0]="zero"
      exit
      }
      END{for (idx in a){
             print idx, a[idx]
             }
      }'
````

```` shell
0 zero
1 one
2 two
3 three
4 four
````

<hr>

### Build-in functions

`gensub(regexp, replacement, how [, target])` : Is the most advanced function for string replacing.

And their simpler alternatives:

`gsub(regexp, replacement [, target])`

`sub(regexp, replacement [, target])`

Having this file:

```` shell
$ cat lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim orci, euismod id nisi eget, interdum cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

We\'re going to swap the position of the words placed at the *left* and the *right* of each comma.

```` shell
$ awk '{print gensub(/([^ ]+)( *, *)([^ ]+)/,
                     "\\3\\2\\1", "g")}' lorem.dat
Lorem ipsum dolor sit consectetur, amet adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim euismod, orci id nisi interdum, eget cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit consectetur, amet adipiscing elit.
Aliquam interdum mauris volutpat nisl et, placerat facilisis.
````

Using `gensub` we capture *three groups* and then we swap the order.

To illustrate a simpler action let\'s change *dots* for *commas*:

```` shell
awk '$0=gensub(/\./, ",", "g")' lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
Maecenas pellentesque erat vel tortor consectetur condimentum,
Nunc enim orci, euismod id nisi eget, interdum cursus ex,
Curabitur a dapibus tellus,
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
Aliquam interdum mauris volutpat nisl placerat, et facilisis,
````

Using `gsub` alternative:

```` shell
awk 'gsub(/\./, ",")' lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
Maecenas pellentesque erat vel tortor consectetur condimentum,
Nunc enim orci, euismod id nisi eget, interdum cursus ex,
Curabitur a dapibus tellus,
Lorem ipsum dolor sit amet, consectetur adipiscing elit,
Aliquam interdum mauris volutpat nisl placerat, et facilisis,
````
This option seems better when no *group capture* is needed.

Other interesting functions are `index` and `substr`.

`index(in, find)`

`substr(string, start [, length ])`

Works like this:

```` shell
$ awk 'BEGIN{t="hello-world";print index(t, "-")}'
6
````

```` shell
$ awk 'BEGIN{t="hello-world";print substr(t,index(t, "-")+1)}'
world
````

The `split` *function* is used to create an array from a string dividing it by a *separator char*, it returns the number of elements of the created array.

`split(string, array [, fieldsep [, seps ] ])`

```` shell
$ cat passwd
jd001:x:1032:666:Javier Diaz:/home/jd001:/bin/rbash
ag002:x:8050:668:Alejandro Gonzalez:/home/ag002:/bin/rbash
jp003:x:1000:666:Jose Perez:/home/jp003:/bin/bash
ms004:x:8051:668:Maria Saenz:/home/ms004:/bin/rbash
rc005:x:6550:668:Rosa Camacho:/home/rc005:/bin/rbash
````

```` shell
$ awk 'n=split($0, a, ":"){print n, a[n]}' passwd
7 /bin/rbash
7 /bin/rbash
7 /bin/bash
7 /bin/rbash
7 /bin/rbash
````
:point_right: **Note**: This could be done in a much more simpler way:

```` shell
$ awk '{print NF,$NF}' FS=':' passwd
7 /bin/rbash
7 /bin/rbash
7 /bin/bash
7 /bin/rbash
7 /bin/rbash
````

<hr>

### Custom functions

Write a custom function is quite simple:

```` shell
awk 'function test(m)
     {
        printf "This is a test func, parameter: %s\n", m
     }
     BEGIN{test("param")}'
````

Give us:

```` shell
This is a test func, parameter: param
````

We can also give back an expression using a `return` statement:


```` shell
awk 'function test(m)
     {
        return sprintf("This is a test func, parameter: %s", m)
     }
     BEGIN{print test("param")}'
````

Parsing by parameter is the only way to make a local variable inside a function.

Scalar values are passed by value  and arrays by reference, so any change made to an array inside a function will be reflected in the global scope:

```` shell
 awk 'function test(m)
      {
       m[0] = "new"
      }
      BEGIN{m[0]=1
            test(m)
            exit
      }
      END{print m[0]}'
````

Outputs:

```` shell
new
````
<hr>

# Now let\'s have some fun :godmode:

**Our challenges**:

[01](#penultimate-word-of-a-record). Penultimate word of a Record.

[02](#replacing-a-record). Replacing a Record.

[03](#place-a-semicolon-at-the-end-of-each-record). Place a semicolon at the end of each Record.

[04](#place-a-comma-between-every-word). Place a comma between every word.

[05](#all-together). All together?

[06](#redirecting-odd-records-to-a-file-and-even-ones-to-another). Redirecting odd records to a file and even ones to another.

[07](#given-a-password-file-get-the-missing-field). Given a password file get the missing field.

[08](#field-swapping). Field swapping.

[09](#traceroute-hacking). Traceroute hacking.

[10](#where-are-my-children). Where are my children?

[11](#data-aggregation). Data aggregation.

[12](#records-between-two-patterns). Records between two patterns.

[13](#field-transformation). Field transformation.

[14](#records-to-columns). Records to columns.

[15](#fasta-file-processing). FASTA File processing.

[16](#complex-reporting). Complex reporting.

[17](#files-joiner). Files joiner.

[18](#passwd-and-group). Passwd and Group.

[19](#user-connections). User connections.

[20](#uptime-total-load-average). Uptime total load average.

<hr>

### 01. Penultimate word of a Record

Having this *source* file:

```` shell
$ cat lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
Nunc enim orci, euismod id nisi eget, interdum cursus ex.
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

```` shell
$ awk '{print $(NF-1)}' lorem.dat
adipiscing
consectetur
cursus
dapibus
adipiscing
neque
````

Not too much to explain here, `NF` stores the *number of fields* in the current record, so `NF-1` points to field before last and `$(NF-1)` will be its value.

<hr>

### 02. Replacing a record

Our task, file record substitution, the third line must become:

`This not latin`

Nothing more simple, just play around `NR` (*number of record*).

Code:

```` shell
$ awk 'NR==3{print "This is not latin";next}{print}' lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
This is not latin
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

Alternative solution to avoid `next` statement: assign the new line to the complete record `$0`.

Example:

```` shell
$ awk 'NR==3{$0="This is not latin"}1' lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas pellentesque erat vel tortor consectetur condimentum.
This is not latin
Curabitur a dapibus tellus.
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

<hr>

### 03. Place a semicolon at the end of each record

```` shell
$ awk '1' ORS=";\n" lorem.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.;
Maecenas pellentesque erat vel tortor consectetur condimentum.;
Nunc enim orci, euismod id nisi eget, interdum cursus ex.;
Curabitur a dapibus tellus.;
Lorem ipsum dolor sit amet, consectetur adipiscing elit.;
Aliquam interdum mauris volutpat nisl placerat, et facilisis neque ultrices.;
````

As the default `RS` is the unix break line `\n`  we just need to *prefix* the semicolon to the Output Record Separator `OFS`. 

:warning: **ATENCION**: What about that strange `1`?[^4]

<hr>

### 04. Place a comma between every word

```` shell
$ awk '{$1=$1}1' OFS=',' lorem.dat
Lorem,ipsum,dolor,sit,amet,,consectetur,adipiscing,elit.
Maecenas,pellentesque,erat,vel,tortor,consectetur,condimentum.
Nunc,enim,orci,,euismod,id,nisi,eget,,interdum,cursus,ex.
Curabitur,a,dapibus,tellus.
Lorem,ipsum,dolor,sit,amet,,consectetur,adipiscing,elit.
Aliquam,interdum,mauris,volutpat,nisl,placerat,,et,facilisis,neque,ultrices.
````

The most significant part of this code is how it forces a record reconstruction with `$1=$1` for the current value of the `OFS`.

<hr>

### 05. All together?

```` shell
$ awk '{$1=$1}1' OFS=',' ORS=';\n' lorem.dat
Lorem,ipsum,dolor,sit,amet,,consectetur,adipiscing,elit.;
Maecenas,pellentesque,erat,vel,tortor,consectetur,condimentum.;
Nunc,enim,orci,,euismod,id,nisi,eget,,interdum,cursus,ex.;
Curabitur,a,dapibus,tellus.;
Lorem,ipsum,dolor,sit,amet,,consectetur,adipiscing,elit.;
Aliquam,interdum,mauris,volutpat,nisl,placerat,,et,facilisis,neque,ultrices.;
````

As *simply* as playing with output vars: `OFS` and `ORS`.

<hr>

### 06. Redirecting odd records to a file and even ones to another

Let\'s start  with the final solution:

```` shell
$ awk 'NR%2{print > "even.dat";next}
           {print > "odd.dat"}' lorem.dat
````

```` shell
$ cat even.dat
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Nunc enim orci, euismod id nisi eget, interdum cursus ex.
Lorem ipsum dolor sit amet, consectetur adipiscing elit
````

```` shell
$ cat odd.dat
Maecenas pellentesque erat vel tortor consectetur condimentum.
Curabitur a dapibus tellus.
Aliquam interdum mauris volutpat nisl placerat, et facilisis.
````

The [modulo] function (`%`) *finds* the remainder after division for the current Record Number `NR` divided by two:

```` shell
$ awk '{print NR%2}' lorem.dat
1
0
1
0
1
0
````

As far as we now yet, in `awk` `1` is **True** and `0` **False**. We  redirect our output evaluating this fact.

`next` requires an special attention, it *forces* `awk` to **immediately** stop the current record process and pass to next one.

In this way we elude a double condition that would look like this:

```` shell
awk  'NR % 2{print > "even.dat"}
     !NR % 2{print > "odd.dat"}' lorem.dat
````

<hr>

### 07. Given a password file get the missing field

```` shell
$ cat /etc/passwd
jd001:x:1032:666:Javier Diaz::/bin/rbash
ag002:x:8050:668:Alejandro Gonzalez::/bin/rbash
jp003:x:1000:666:Jose Perez::/bin/bash
ms004:x:8051:668:Maria Saenz::/bin/rbash
rc005:x:6550:668:Rosa Camacho::/bin/rbash
````

Let\'s assume the home directory by prefixing the fixed string `"/home/"` to the *username*:

```` shell
$ awk '$6="/home/"$1' FS=':' OFS=':' /etc/passwd
jd001:x:1032:666:Javier Diaz:/home/jd001:/bin/rbash
ag002:x:8050:668:Alejandro Gonzalez:/home/ag002:/bin/rbash
jp003:x:1000:666:Jose Perez:/home/jp003:/bin/bash
ms004:x:8051:668:Maria Saenz:/home/ms004:/bin/rbash
rc005:x:6550:668:Rosa Camacho:/home/rc005:/bin/rbash
````

Our first step should be considering the field separator, a colon, for input as well as for output.  

Then we need to find the void field position, `6` for this example. 

Finally, we compose the required value using the given string and the user login stored in the first field.

:warning: **IMPORTANT**: `print` is not needed because `$6` assignation return value will always be *True* and `awk` default action is to print the affected record.

<hr>

### 08. Field swapping

Our goal: last field should become first and first become last.

Final code:

```` shell
$ awk -F\: '{last=$1;$1=$NF;$NF=last}1' FS=":" OFS=':' /etc/passwd
/bin/rbash:x:1032:666:Javier Diaz:/home/jd001:jd001
/bin/rbash:x:8050:668:Alejandro Gonzalez:/home/ag002:ag002
/bin/bash:x:1000:666:Jose Perez:/home/jp003:jp003
/bin/rbash:x:8051:668:Maria Saenz:/home/ms004:ms004
/bin/rbash:x:6550:668:Rosa Camacho:/home/rc005:rc005
````

We are playing with an *intermediate* variable used to store the first field value, the we swap its value with the last one, finally we assign `last` variable to `$NF` (`$NF=last`).

<hr>

### 09. Traceroute hacking

Having this output:

```` shell
$  traceroute -q 1 google.com 2>/dev/null
 1  hitronhub.home (192.168.1.1)  5.578 ms
 2  217.217.0.1.dyn.user.ono.com (217.217.0.1)  9.732 ms
 3  10.127.54.181 (10.127.54.181)  10.198 ms
 4  62.42.228.62.static.user.ono.com (62.42.228.62)  35.519 ms
 5  72.14.235.20 (72.14.235.20)  26.003 ms
 6  216.239.50.133 (216.239.50.133)  25.678 ms
 7  mad01s24-in-f14.1e100.net (216.58.211.238)  25.019 ms
````

We need to compute the package *travelling* total time.

```` shell
$ traceroute -q 1 google.com 2>/dev/null|\
  awk '{total+=$(NF-1)}
       END{print "Total ms: "total}'
Total ms: 153.424
````

Because no condition is specified, the action is executed **for all records**.

`total+=$(NF-1)`: `total` variable is used to *accumulate* the value of each *Record* penultimate *Field* `$(NF-1)`.

Finally, we use the `END` rule to show the final `total` value.

<hr>

### 10. Where are my children?

Our job: get our `shell` *dependent* processes.

```` shell
$ echo $$
51026
````

**First thing**: Launch the background processes.

```` shell
$ sleep 10 & sleep 15 & sleep 20 &
[1] 86751
[2] 86752
[3] 86753
````

Using `ps` *utility*, `awk` will look for the third field known as the `PPID`.

:point_right: **Note**: We\'re using `-v` to set *ppid* var before execution of the program begins. 

```` shell
$ ps -ef|awk -v ppid=$$ '$3==ppid'
  501 86751 51026   0  7:57PM ttys001    0:00.00 sleep 10
  501 86752 51026   0  7:57PM ttys001    0:00.00 sleep 15
  501 86753 51026   0  7:57PM ttys001    0:00.00 sleep 20
    0 86754 51026   0  7:57PM ttys001    0:00.00 ps -ef
  501 86755 51026   0  7:57PM ttys001    0:00.00 awk $3==51026
````

We just need the _**sleeps**_:

```` shell
$ ps -ef|awk -v ppid=$$ '$3 == ppid && /slee[p]/ 
                         {print $2" -> "$5}'
86751 -> 7:57PM
86752 -> 7:57PM
86753 -> 7:57PM
````

The solution needs a new condition to add: find the *sleep* pattern in our current record `/slee[p]/`.

The *triggered* action will be to print the second field `$2` with stands for the `PID` and the fifth `$5`, *the time stamp*.

<hr>

### 11. Data aggregation

Having this file:

```` shell
$ cat ips.dat
IP            BYTES
81.220.49.127 328
81.220.49.127 328
81.220.49.127 329
81.220.49.127 367
81.220.49.127 5302
81.226.10.238 328
81.227.128.93 84700
````

Our task is to compute how many *bytes* per `IP` are processed.

```` shell
$ awk 'NR>1{ips[$1]+=$2}
       END{for (ip in ips){print ip, ips[ip]}}' ips.dat
81.220.49.127 6654
81.227.128.93 84700
81.226.10.238 328
````

Bunch of things here to explain.

`NR>1{ips[$1]+=$2}`: The action `ips[$1]+=$2` is only executed when the current record number is greater than one `NR>1`. This is needed to avoid the header.

`ips` is an array indexed by the *ip value* (the `$1` field), for each key we are going to accumulate in the value of the second field.

Take notice of an **important fact**, *if a key is not present in the array*, `awk` adds a new element to the *structure*, otherwise is going to update the previous value pointed by that key (as in our example).

The `END` *rule* is just used to iterate the array by indexes and values.

**This code could be rewritten** in complete different manner to avoid the use of arrays and preserve the order taken advantage of the sorted *IPs* file:

```` shell
awk 'NR==1{next}
    lip && lip != $1{print lip,sum;sum=0}
    {sum+=$2;lip=$1}
    END{print lip,sum}' ips.dat
81.220.49.127 6654
81.226.10.238 328
81.227.128.93 84700
````

`NR==1{next}`: Bypass the header.

`lip && lip != $1{print lip,sum;sum=0}`: Here we use a var named `lip` (*last-ip*). `lip && lip != $1` When `lip` is not null **and** it\'s value not equal to the first field (that holds the current ip) the triggered action will be to print `lip` and `sum` the total amount of bytes for the last IP. Then we initialize it `sum=0`.

The *trick* is clear, **every time IP (`$1`) changes** we show the stats of the previous one.

`{sum+=$2;lip=$1}`: To update the bytes counter `sum+=$2` and assign the current *IP* to `lip`: `lip=$1`. It is the last step of our record processing.

The `END` block is used to print the *pending values*.

This code preserves the order, but *in my opinion*, this comes at the expense of significantly increased complexity.

<hr>

### 12. Records between two patterns

Our task is two extract the lines **between** and `OUTPUT` and `END`.

```` shell
$ cat pat.dat
test -3
test -2
test -1
OUTPUT
top 2
bottom 1
left 0
right 0
page 66
END
test 1
test 2
test 3
````

This is a *classic example* used to *illustrate* how **pattern matching** works in `awk` and its associate actions which I dedicated a complete [post].

```` shell
$ awk '/END/{flag=0}flag;/OUTPUT/{flag=1}' pat.dat
top 2
bottom 1
left 0
right 0
page 66
````

Its based in the `flag` variable value, it will be *True* (`1`) when the starting pattern `OUTPUT` is found and *False* (`0`) when `END` *tag* is reached.

To avoid an additional step, **the action order is very important**, if we follow the *logic sequence*:

```` shell
$ awk '/OUTPUT/{flag=1}flag;/END/{flag=0}' pat.dat
OUTPUT
top 2
bottom 1
left 0
right 0
page 66
END
````

Pattern tags are shown through the output. 

The reason: after `OUTPUT` pattern is found the *flag* gets activated, as the *next* action depends of this flag the record is printed.

We can avoid this behavior *placing the flag activation* as the **last step** of the flow. 

<hr>

### 13. Field transformation

Let\'s suppose this file:

```` shell
$ cat space.dat
10.80 kb
60.08 kb
35.40 kb
2.20 MB
1.10 MB
40.80 kb
3.15 MB
20.50 kb
````

Our job will be to calculate our records **total weight** in *mega bytes*:

```` shell
$ awk '{total+= $1 / ($2=="kb" ? 1024: 1)}
       END{print total}'  space.dat
6.61365
````

To understand *how it works* one concept must be clear, the **[ternary] operator** (subject of an old post).

`total` will be used to *accumulate*  the divison of the first field `$1` by the second `$2` that will hold the value given by the *ternary operator*: `1024` when `$2` is equal to `kb` and `1` if no transformation needed.

Finally, we print `total` value in the `END` block.

<hr>

### 14. Records to columns

Original source:

```` shell
$ cat group.dat
string1
string2
string3
string4
string5
string6
string8
````

Our mission is to group records in **blocks of three columns** like this:

```` shell
string1 string2 string3
string4 string5 string6
string8
````

It may seem complex, but *becomes much simpler* If we understand how to use the *Output Field Separator* `OFS`:

```` shell
$ awk 'ORS = NR%3 ? FS : RS; END{print "\n"}' group.dat
string1 string2 string3
string4 string5 string6
string8
````

If we set the `ORS` to a *blank* character, the `FS` default value, all the output will become a single line:

```` shell
$ awk 'ORS=FS; END{print "\n"}' group.dat
string1 string2 string3 string4 string5 string6 string7
````

`ORS = NR%3 ? FS : RS`: Finally we use the *ternary operator* (explained just before) to evaluate the *[modulo]* `NR%3` result of the division of the current field number `NR` by three. 

If the *remainder* is *True* the `ORS` becomes `FS`, a *blank* space, otherwise the `RS` *default* value will be assigned, the *Unix* line break `\n`.

<hr>

### 15. FASTA File processing

In *bioinformatics*, [FASTA] is a text-based file format.

Having the following example:

```` shell
$ cat fasta.dat
>header1
CGCTCTCTCCATCTCTCTACCCTCTCCCTCTCTCTCGGATAGCTAGCTCTTCTTCCTCCT
TCCTCCGTTTGGATCAGACGAGAGGGTATGTAGTGGTGCACCACGAGTTGGTGAAGC
>header2
GGT
>header3
TTATGAT
````

We need the **total length of each sequence**, and a *final resume*.

Should look like this:

```` shell
>header1
117
>header2
3
>header3
7
3 sequences, total length 127
````

`awk` is the perfect tool for this *reporting effort*, for this example we will use:


```` shell
awk '/^>/ { if (seqlen) {
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
    END{print seqlen
        print seq" sequences, total length " seqtotal+seqlen
    }' fasta.dat

````

The **first action** is *tied* to the header detection `/^>/`, that\'s because *all headers* stars with `>` character.

When `seqlen` is *not null* its value, that holds the previous sequence length, is printed to the *stdout* attached to the new header. `seqtotal` is updated and `seqlen` initialized to serve the next sequence. Finally, we break further record processing with `next`.

The **second action**  `{seqlen += length($0)}` is used to update `seqlen` summing the total record length.

The `END` *rule* purpose is to show the *unprinted* sequence and the totals.

**Trick** here is to print the *previous sequence* length when we found a *new header*.

When we process the first record `seqlen` has no value so we skip the visualization.

<hr>

### 16. Complex reporting

Source:

```` shell
$ cat report.dat
       snaps1:          Counter:             4966
        Opens:          Counter:           357283

     Instance:     s.1.aps.userDatabase.mount275668.attributes

       snaps1:          Counter:                0
        Opens:          Counter:           357283

     Instance:     s.1.aps.userDatabase.test.attributes

       snaps1:          Counter:             5660
        Opens:          Counter:            37283

     Instance:     s.1.aps.userDatabase.mount275000.attributes
````

Our *duty*: create a *report* to visualize `snaps` and `instance` but *only when snap first counter tag is greater than zero*.

Expected output:

```` shell
snaps1: Counter: 4966
Instance: s.1.aps.userDatabase.mount275668.attributes
snaps1: Counter: 5660
Instance: s.1.aps.userDatabase.mount275000.attributes
````

We are playing again around *patterns* and *flags*:

```` shell
awk '{$1=$1}
     /snaps1/ && $NF>0{print;f=1}
     f &&  /Instance/ {print;f=0}'  report.dat
````

For **every record** the **first action is executed**, it forces `awk` to **rebuild the entire record**, using the current values for `OFS` [^3].

This trick allows us to convert a *multiple space separator* to  a *single char*, the **default** value for the Output Field Separator.

Let\'s see this:

```` shell
$ awk '1' text.dat
one      two
three              four
````

```` shell
$ awk '$1=$1' text.dat
one two
three four
````

**Second action** is *triggered* when the pattern is found and the last field greater than zero `/snaps1/ && $NF>0`.

`awk` prints the record and assign a *True* value to the flag `print;f=1`.

Last step: when flag is *True* and *instance* pattern in the line `f &&  /Instance/`, show the line and deactivate flag: `print;f=0`.

<hr>

### 17. Files joiner

Let\'s suppose two archives:

```` shell
$ cat join1.dat
3.5 22
5. 23
4.2 42
4.5 44
````

```` shell
$ cat join2.dat
3.5
3.7
5.
6.5
````

We need the records from the first one `join1.dat`  when the first fields are in the second one `join2.dat`. 

Output should be:

```` shell
3.5 22
5. 23
````

We can use *unix join utility*, of course, but we need to sort the first file:

```` shell
$ join <(sort join1.dat) join2.dat
3.5 22
5. 23
````

Not needed in `awk`:

```` shell
$ awk 'NR == FNR{a[$1];next}
       $1 in a'  join2.dat join1.dat
````

Let\'s study the filters and the actions:

`NR == FNR`: *Record Number* equal to *Record File Number* means that we\'re processing the first file parsed to `awk`: `join2.dat`. 

The pair action `a[$1];next` will be to add a new void value to the array indexed by the first field. `next` statement will **break** the record processing and pass the flow to the *next* one.

For the **second action** `NR != FNR` is applied implicitly and affects only to `join1.dat`, the second condition is `$1 in a` that will be *True* when the first field of `join1.dat` is an array key.

<hr>

### 18. Passwd and Group

These are to *unix classics*:

```` shell
$ cat /etc/group
dba:x:001:
netadmin:x:002:
````

```` shell
$ cat /etc/passwd
jd001:x:1032:001:Javier Diaz:/home/jd001:/bin/rbash
ag002:x:8050:002:Alejandro Gonzalez:/home/ag002:/bin/rbash
jp003:x:1000:001:Jose Perez:/home/jp003:/bin/bash
ms004:x:8051:002:Maria Saenz:/home/ms004:/bin/rbash
rc005:x:6550:002:Rosa Camacho:/home/rc005:/bin/rbash
````

Our goal, a report like this: 

```` shell
d001:dba
ag002:netadmin
jp003:dba
ms004:netadmin
rc005:netadmin
````

We need a **multiple file flow** as we studied in our last example:

```` shell
$ awk -F\: 'NR == FNR{g[$3]=$1;next}
            $4 in g{print $1""FS""g[$4]}' /etc/group /etc/passwd
````

To process  `/etc/group` we repeat the `NR == FNR` comparison then store the *name of the group* `$1` indexed by its *ID* `$3`: `g[$3]=$1`. Finally, we *break* further record processing with `next`.

The **second condition** will target only `/etc/passwd` records, when the fourth field `$4` (*group ID*) is present in the array  `$4 in g`, we will print the *login* and the value pointed by the array *indexed by the group id* `g[$4]`, so: `print $1""FS""g[$4]`.

<hr>

### 19. User connections

Users utility output example:

```` shell
$ users
negan rick bart klashxx klashxx ironman ironman ironman
````

We\'re going to **count** logons per user.

```` shell
$ users|awk '{a[$1]++}
             END{for (i in a){print i,a[i]}}' RS=' +'
rick 1
bart 1
ironman 3
negan 1
klashxx 2
````

The action is performed for all the records.
  
`a[$1]++`: This is the *counter*, for each *user* `$1` it increments the pointed value (uninitialized vars have the numeric value zero).

In the `END` *block* iterate the array *by key* and the stored value to present the results.

<hr>

### 20. Uptime total load average

A *typical* output:

```` shell
$ uptime
 11:08:51 up 121 days, 13:09, 10 users,  load average: 9.12, 14.85, 20.84
````

How can we get the total *load average mean*?

```` shell
$ uptime |awk '{printf "Load average mean: %0.2f\n", 
                ($(NF-2)+$(NF-1)+$(NF))/3 }' FS='(:|,) +'
Load average mean: 14.94
````

Here\'s a new technique.

We’re using a [regex] as the field separator `(:|,) +`, so the `FS` can be a *colon* and a *comma* followed by *zero or more* blank spaces.

We just need the *last three fields* to perform the arithmetic required, then we use `printf` attached to a *proper mask*.

<hr>

## :warning: Disclaimer 2 :warning:

If you are still here, **THANKS**!!

From my point of view, `awk` is an *underrated* language and needs much love :heart:.

If you’re hungry for more let me know it in the comment section bellow and I will consider a second part to finish my mission ... bore you to death :neckbeard:.

Happy coding!

[^1]: [A Guide to Unix Shell Quoting][quoting-guide].

[^2]: [Wikipedia on pipelines][pipes].

[^3]: There are times when it is convenient to force `awk` to rebuild the entire record, using the current values of the `FS` and `OFS`. 
      
      To do this, we use the seemingly innocuous assignment: `$1 = $1`

[^4]: Quick answer, It\'s just a *shortcut* to avoid using the print statement.
      
      In `awk` when a condition gets matched the *default action* is to print the input line.

      `$ echo "test" |awk '1'`

      Is equivalent to:

      `echo "test"|awk '1==1'`
      
      `echo "test"|awk '{if (1==1){print}}'`

      That\'s because `1` will be always [true].

