#!/bin/bash
function table99(){
str=''
    for i in {1..9};do
        for k in $(seq $i);do
            str=${str}$(echo -en "${i}x${k}=$[$i*$k]\t")
       done
       str=${str}"n" 
    done
    str=$(echo $str | tr "n" "\n")
    #return $str
}
#result=$table99
table99

echo "$str" | while read line;do mysql -e "INSERT INTO myworld.table_99 (times_value) VALUE ($line)";done
#mysql -e "INSERT INTO myworld.table_99 (times_value) VALUE ($str)"
