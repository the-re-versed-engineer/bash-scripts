#!/usr/bin/env bash

#$1=filename
#$2=num of leading spaced make 1 tab

#read file line by line calculating how many tabs it should have based on how many spaces devided by num given in arg
#keep any remainder spaces that dont add to a full tab

#check to make sure the file is not currently open. exit if it is
if [ $(lsof | grep "$(realpath $1)") ]; then exit 1; fi

#save total file line num to var
totalLines="$(wc -l $1)"
#remove the txt portion of string
totalLines="${totalLines/% */''}"
#make tempfile to hold data
tmpFile="$(mktemp --tmpdir=/tmp)"

#create string of spaces to replace with tabs based on input arg num
for (( s = 0 ; s < "$2" ; s++ )); do
	#print each space to a file
	printf ' ' >> "$tmpFile"
done
#read the tmp file to the the space string
spaceString="$(cat $tmpFile)"
#erase contents of tmpfile for reuse
printf '' > "$tmpFile"

#loop thrgh each line of a file replace grouped spaces with a tab
for (( l = 1 ; l <= "$totalLines" ; l++ ));do
	sed -n "$l{: start; s/$spaceString/\t/; t start; p}" "$1" >> "$tmpFile"
done
#delete contents of orig file, exit if unsuccessful
printf '' > "$1" || exit 1
#print new file contents from tmp t orig file
cat "$tmpFile" >> "$1"
#remove tmp file
rm "$tmpFile"



















