for i in $(ls dot-file);
do
	echo install $i ...
	mv dot-file/$i ~/.$i
done

echo finish
