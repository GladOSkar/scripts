#!/bin/bash

if [ $# == 0 ]
then
	echo "Usages:"
	echo "roll [<num>] <die>"
	echo "roll <num>d<die>"
	exit 1
elif [ $# == 1 ]
then
	if [[ $1 == *"d"* ]]
	then
		DIES=`cut -d'd' -f1 <<< $1`
		[ -z $DIES ] && DIES=1
		DIE=`cut -d'd' -f2 <<< $1`
	else
		DIES=1
		DIE=$1
	fi
else
	DIES=$1
	DIE=$2
fi

echo " 🎲 Rolling ${DIES}d${DIE} 🎲 "

SUM=0
for _ in `seq 1 $DIES`
do
	DIERESULT=$(( ($RANDOM % $DIE) + 1 ))
	echo -n "$DIERESULT + "
	SUM=$(( $SUM + $DIERESULT ))
done

echo -ne "\b\b"

if [ $DIES -gt 1 ]
then
	echo "= $SUM"
else
	echo "  "
fi
