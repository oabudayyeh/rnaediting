#! /bin/bash 
reads=$(wc -l < $1)
reads=$(($reads/4))



echo $reads > $1.reads

if (( $reads > $3 ))
then
	seqtk sample -s100 $1 $3 > $1.sub
	seqtk sample -s100 $2 $3 > $2.sub
	mv $1.sub $1
	mv $2.sub $2
	echo "subsample complete"
fi
