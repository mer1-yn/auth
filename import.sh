#!/bin/bash

f_flag=''
g_flag=''
a_flag=''

print_usage() {
  printf "Usage: "
}

while getopts 'afg' flag; do
  case "${flag}" in
    a) a_flag='true' ;;
    f) f_flag='true' ;;
    g) g_flag='true' ;;
    ?) printf '\nUsage: %s: [-a] aflag [-b] bflag\n' $0; exit 2 ;;
  esac
done

moi="$(git config user.name)"
test -f generated && rm generated

if getopts "a" arg; then
	test -f $moi ||  echo "# $moi" >> $moi
	for file in $(ls ~/.ssh/*.pub)
	do
		echo $file
		grep -qxF "$(cat $file)" $moi || echo $(cat $file) >> $moi
	done
fi

for file in $(ls . | grep -vE "(import.sh|$moi|generated)" )
do 
	cat $file >> generated
	echo >> generated
done

if getopts "f" arg; then
	if grep -E "AuthorizedKey.*generated" /etc/ssh/sshd_config ; then
		echo "Your sshd_config file is not configured to look at the $(dirname $0)/generated file. Please modify this in /etc/ssh/sshd_config"
		exit 1
	fi 
	cp generated ~/.ssh/
fi
