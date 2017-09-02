#! /bin/bash 
reads=$(wc -l < $1)
reads=$(($reads/4))



echo $reads > $1.reads

if (( $reads > 15000000 ))
then
	seqtk sample -s100 $1 15000000 > $1.sub
	seqtk sample -s100 $2 15000000 > $2.sub
	mv $1.sub $1
	mv $2.sub $2
fi
