#!/bin/bash

# Copyright Damianos Giankakis
# LICENSE MIT
# Created 2019 / 03
# Repository https://github.com/Damian96/fnd
# A shell script to search files in a specific directory
# recursively or not, by their contents and / or by their names

if ! [ -x "$(command -v find)" ]; then
	printf "%s\n" "Package find is required, but not found"
fi

if ! [ -x "$(command -v awk)" ]; then
	printf "%s\n" "Package awk is required, but not found"
fi

if [[ $# -le 2 ]]; then
  printf "%s\n" "Usage: fnd [ [-p|--path]=PATH] [-r|--recursive] [-c|--content]=PATTERN] [-n|--name]=PATTERN] ]"
  exit 1
fi

for i in "$@"
do
case $i in
	-p=*|--path=*)
		SEARCH="${i#*=}"
	;;
	-r|--recursive)
		RECURSIVE=1
	;;
	-c=*|--content=*)
		CONTENT="${i#*=}"
	;;
	-n=*|--name=*)
		NAME="${i#*=}"
	;;
	*)
  	printf "%s\n" "Usage: fnd [ [-p|--path]=PATH] [-r|--recursive] [-c|--content]=PATTERN] [-n|--name]=PATTERN] ]"
  	exit 1
	;;
esac
done

if [[ ! -d "$SEARCH" ]]; then
	printf "%s\n" "Invalid parameter: --path"
	exit 1
else
	SCMD="find \"$SEARCH\""
fi

if [[ $RECURSIVE -ne 1 ]]; then
	SCMD="$SCMD -maxdepth 1"
fi

if [[ -z "${NAME// }" ]]; then
	printf "%s\n" "Invalid parameter: --name"
	exit 1
else
	SCMD="$SCMD -type f -path \"$NAME\""
fi

if [[ -z "${CONTENT// }" ]]; then
	printf "%s\n" "Invalid parameter: --content"
	exit 1
fi

IFS='
'
for f in $( eval "$SCMD" ); do
	awk -v PATT=$CONTENT 'BEGIN{ TM = 0 } { if (match($0, PATT)) { TM += 1; printf("\n%s[line %d]: %s", FILENAME, NR, $0) } } END{ if (TM > 0) { printf("\n\tFound %d, matches in %s\n", TM, FILENAME) } }' "$f"
done

unset SEARCH
unset RECURSIVE
unset CONTENT
unset NAME
unset SCMD
unset PATT
exit 0