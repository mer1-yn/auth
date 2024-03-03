#!/bin/bash

moi="$(git config user.name)"
touch $moi
for file in $(ls ~/.ssh/*.pub)
do
	echo $file

	grep -qxF "$(cat $file)" $moi || echo $(cat $file) >> $moi
done

for file in $(ls . | grep -vE "(import.sh|$moi|generated)" )
do 
	cat $file >> generated
done
