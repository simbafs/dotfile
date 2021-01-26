#!/bin/bash
######################################
##              CAUTION             ## 
## Only run this script on simba-nb ##
######################################

# author: simba-fs
# usage: update.sh [list file:./.list] [from:~/] [to:./]
# 2020/6/30

[[ -z $1 ]] && list=$(pwd)/.list || list=$1;
[[ -z $2 ]] && from=$HOME || from=$(dirname $2);
[[ -z $3 ]] && to="$(pwd)/dot-file" || to=$(dirname $3);

echo list is $list; 
echo from $from; 
echo to $to;
echo;

echo -n '[n/Y] '; 
read n;
[[ "x$n" == "xn" || "x$n" == "xN" ]] && exit 1;

rm -rf $to
mkdir $to

for i in $(cat $list);do
	echo $i
	echo cp -r $from/$i $to/$i;

	mkdir -p $(dirname $to/$i);
	cp -r $from/$i $to/$i;
done;

echo finish;
