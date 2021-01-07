#!/bin/bash

TOTAL=0
COUNT=0

while read LINE
do
	(( COUNT += 1 ))
	(( TOTAL += LINE ))
done

AVG=`bc <<< "scale=3; $TOTAL/$COUNT"`

echo $AVG
