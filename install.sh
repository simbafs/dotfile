#!/bin/bash
for i in $(ls dot-file);
do
	echo install $i ...
	cp -r dot-file/$i ~/
done

echo finish
