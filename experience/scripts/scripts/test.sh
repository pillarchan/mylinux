#!/bin/bash
declare -A domains=(
    [dm]="https://d1pudw69gjw8t1.cloudfront.net"
    [btu]="https://dbwhi1xb189lj.cloudfront.net"
    [kb]="https://d1iwhq6gxwlv3j.cloudfront.net"
	[cw]="https://d1f8cq50uxnhqi.cloudfront.net"
)

cond="bbb"
domain=""
case $cond in
	"aaa")
	domain=${domains[dm]}
	echo $domain
	;;
	"bbb")
    domain=${domains[btu]}
	echo $domain
	;;
	"ccc")
    domain=${domains[kb]}
	echo $domain
	;;
	"ddd")
	domain=${domains[cw]}
	echo $domain
	;;
	*)
	echo "不能为空"
	exit
esac
