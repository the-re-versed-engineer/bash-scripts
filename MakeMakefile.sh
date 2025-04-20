#!/bin/bash

#check if Makefile exists in PWD
if [ -e "$PWD/Makefile" ]; then
	echo "$PWD/Makefile already exists. Exiting..."
	exit 1
else
	touch "$PWD/Makefile"
fi


#ParseArgs
argsList=( "$@" )
for (( a=0 ; a<="$#" ; a++ )); do
	case "${argsList[a]}" in
		'-L')	linkedLib="${argsList[ ((a+1)) ]}"
			;;
		'-A')	compilerARGS="${argsList[ ((a+1)) ]}"
			;;
		'-F')	sourceFiles="${argsList[ ((a+1)) ]}"
			;;
		'-C')	compilerCommand="${argsList[ ((a+1)) ]}"
			;;
		'-O')	outputFile="${argsList[ ((a+1)) ]}"
			;;
		'-B')	buildDirectory="${argsList[ ((a+1)) ]}"
			;;
		'-S')	srcDirectory="${argsList[ ((a+1)) ]}"
			;;
	esac
done

printf "#Makefile for a Simple C/C++ program\n" >> "$PWD/Makefile"
printf "outputFile := ${outputFile:-main.out}\n" >> "$PWD/Makefile"
printf "srcFiles := ${sourceFiles:-main.cpp}\n" >> "$PWD/Makefile"
printf "compilerCMD := ${compilerCommand:-g++}\n" >> "$PWD/Makefile"
printf "compilerArgs := $compilerARGS\n" >> "$PWD/Makefile"
printf "linkedLibraries := $linkedLib\n" >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"
printf ".DELETE_ON_ERROR:\n" >> "$PWD/Makefile"
printf "all: clean build\n" >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"
printf "build: " >> "$PWD/Makefile"
printf "\n\t" >> "$PWD/Makefile"
printf '$(compilerCMD) $(srcFiles) $(addprefix -L,$(linkedLibraries)) $(compilerArgs) -o $(outputFile)' >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"
printf ".PHONY: clean\n" >> "$PWD/Makefile"
printf "clean:\n" >> "$PWD/Makefile"
printf "\t" >> "$PWD/Makefile"
printf 'rm $(outputFile)' >> "$PWD/Makefile"
printf "\n" >> "$PWD/Makefile"








