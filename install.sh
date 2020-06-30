for i in $(ls dot-file);
do
	echo install $i ...
	mv dot-file/$i ~/.
done

echo finish
