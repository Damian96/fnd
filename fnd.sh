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

fndUnset() {
	unset fndHelp
	unset SEARCH
	unset RECURSIVE
	unset CONTENT
	unset NAME
	unset SCMD
	unset PATT
}

_trapCmd() {
	trap 'kill -TERM $PID; exit 130;' TERM
	eval "$1" &
	PID=$!
	wait $PID
}

fndHelp() {
	printf "\n%s\n" "fnd Shell Script

USAGE
	fnd [ [-p|--path]=PATH] [ [-d|--depth]=INT] [-c|--content]=PATTERN] [-n|--name]=PATTERN] ] ]

OPTIONS
	-p	--path			The specified directory to set as search space (default: ./)
	-d	--depth			The maximum depth of subdirectories to search. 2 is the first level (default: 2)
	-c	--content	*	The REGEX pattern to match against each line of each search file (default: .*)
	-n	--name		*	The REGEX pattern to match against the name of each search file (default: .*)
	-h	--help			Prints this page

	(*) Required

	For the script to execute, one of the --name or --content parameters need to be passed.

EXIT CODES
	201	Invalid / not sufficient arguments
	202	Both --name and --content parameters were empty or invalid
	0  	Success

Copyright 2019 Damianos Giankakis
LICENSE MIT
Repository https://github.com/Damian96/fnd
A shell script to search files in a specific directory
and its subdirectories, by their contents and / or by their names"
}


if [[ $# -le 1 ]]; then
  fndHelp
  fndUnset
  exit 201
fi

for i in "$@"
do
case $i in
	-p=*|--path=*)
		SEARCH="${i#*=}"
	;;
	-d=*|--depth=*)
		DEPTH="${i#*=}"
	;;
	-c=*|--content=*)
		CONTENT="${i#*=}"
	;;
	-n=*|--name=*)
		NAME="${i#*=}"
	;;
	-h=*|--help)
		fndHelp
		fndUnset
		exit 0
	;;
	*)
		printf "%s\n" "Invalid argument"
		fndUnset
  	exit 201
	;;
esac
done

if [[ -z "${NAME// }" ]]; then
	SCMD="find ./"
elif [[ ! -d "$SEARCH" ]]; then
	printf "%s\n" "Invalid parameter: --path"
	fndUnset
	exit 201
else
	SCMD="find \"$SEARCH\""
fi

if [[ -z "${DEPTH// }" ]]; then
	SCMD="$SCMD"
elif [[ $DEPTH -gt 2 ]]; then
	SCMD="$SCMD -maxdepth $DEPTH"
else
	SCMD="$SCMD"
fi

if [[ ! -z "${NAME// }" ]]; then
	SCMD="$SCMD -type f -name \"$NAME\""
fi

if [[ -z "${CONTENT// }" && -z "${NAME// }" ]]; then
	printf "%s\n" "Invalid parameter: --content"
	printf "%s\n" "Invalid parameter: --name"
	printf "%s\n" "Error: fnd requires one of the two above parameters to work"
	fndUnset
	exit 202
fi

if [[ ! -z "${CONTENT// }" ]]; then
	IFS='
	'
	for f in $( eval "$SCMD" ); do
		_trapCmd "awk -v PATT=$CONTENT 'BEGIN{ TM = 0 } { if (match(\$0, PATT)) { TM += 1; printf(\"\n%s[line %d]: %s\", FILENAME, NR, \$0) } } END{ if (TM > 0) { printf(\"\n\tFound %d, matches in %s\n\", TM, FILENAME) } }' \"$f\""
	done
else
	for f in $( eval "$SCMD" ); do
		printf "\n%s\n" "$f"
	done
fi

fndUnset
exit 0