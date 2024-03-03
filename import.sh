#!/bin/bash

f_flag=false
g_flag=false
a_flag=false
e_flag=true
fval="~/.ssh/generated"

while getopts 'af::eg' flag; do
  case "${flag}" in
    a) a_flag='true' ;;
    f) f_flag='true' 
	    fval=$OPTARG;;
    e) e_flag='false' 
    	f_flag='true';;
    g) g_flag='true' ;;
    *) printf '\nUsage: %s: \n\t [-a] Add local keys \n\t [-f FILENAME] Write to file \n\t [-g] Generate new keylist\n' $0; exit 2 ;;
  esac
done

if [ $a_flag == false ] && [ $g_flag == false ] && [ $f_flag == false ]; then 
	printf '%s: no arguments: \n\nUsage: %s: \n\t [-a] Add local keys \n\t [-f FILENAME] Write to file \n\t [-g] Generate new keylist\n' $0; 
	exit 2
fi
moi="$(git config user.name)"

if $a_flag; then
	test -f $moi ||  echo "# $moi" >> $moi
	for file in $(ls ~/.ssh/*.pub)
	do
		echo $file
		grep -qxF "$(cat $file)" $moi || echo $(cat $file) >> $moi
	done
	grep -qxF $moi keyfiles && echo $moi >> keyfiles
fi

if $g_flag; then
	test -f generated && rm generated
	echo ---SSH Keyfile generated $(date)--- >> generated
	for file in $(cat keyfiles)
	do 
		cat $file >> generated
		echo >> generated
	done
fi

if $f_flag; then
	if $e_flag; then
		if [ !$(grep "AuthorizedKey.*generated" /etc/ssh/sshd_config) ] ; then
			echo "Your sshd_config file is not configured to look at the $(dirname $0)/generated file. Please modify this in /etc/ssh/sshd_config"
			exit 1
		fi
	fi 
	[ -f generated ] || exec $0 -g  && cp generated $fval
	[ -f generated ] && rm generated
fi
