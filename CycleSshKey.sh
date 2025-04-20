#!/usr/bin/env bash
set -e #exit if ANY errors occur
#####WORKING####



#set variables from args
argsList=( "$@" )
for (( a=0 ; a<="$#" ; a++ )); do #idk why the *2 is needed
	case "${argsList[a]}" in
		'-h')	givenHostIP="${argsList[ ((a+1)) ]}"
			;;
		'-u')	givenHostUser="${argsList[ ((a+1)) ]}"
			;;
		'-p')	givenPortNum="${argsList[ ((a+1)) ]}"
			;;
		'-i')	identityFileName="${argsList[ ((a+1)) ]}"
			;;
		'-a')	givenAuthKeysPath="${argsList[ ((a+1)) ]}"
			;;
		'-c')	givenComment=" --${argsList[ ((a+1)) ]}--"
			;;
		-* )	echo "Argument '${argsList[a]}' not recognized. Exiting."
				exit 1
			;; #untested
	esac
done
hostIP="$givenHostIP"
hostUser="$givenHostUser"
portNum="${givenPortNum:-22}"
#xit if any of these vars are null
if [ ! "$hostIP" ] | [ ! "$hostUser" ] | [ ! "$portNum" ] | [ ! "$identityFileName" ] | [ ! -e "$identityFileName" ]; then
	exit 1
fi 



#strip the path and suffix (if either provided) from filename
fileName="$(basename --suffix=.pub $identityFileName)" #remove .pub suffix if given
#local path to dir containing old keyfile
dirPath="$(dirname $(realpath $identityFileName))"
#remote path to authorized_keys file
authKeysPath="${givenAuthKeysPath:-/home/$hostUser/.ssh/authorized_keys}"

#prompt user for confirmation of input info
#loop to re-promt user when confirmation input is not recognized
while true
do
	echo
	echo "User: $hostUser"
	echo "Host: $hostIP"
	echo "Port: $portNum"
	echo "Public Keyfile name: $fileName.pub"
	echo "Private Keyfile name: $fileName"
	echo "LOCAL Keys contained in: $dirPath"
	echo "REMOTE keys going to: $authKeysPath"
	echo "Comment: $givenComment"
	echo
	read -p "Is this all Correct? [Y/n]"
	case "$REPLY" in
		'Y' | 'y' | '' | ' ' ) echo "Starting Script." ; break ;;
		'N' | 'n' ) echo "Exiting."; exit -1 ;;
		* ) echo "Input not recognized."
	esac
done

#Confirm connection with old key
echo "Checking connection to host with old key pair."
ssh -i "$dirPath/$fileName" -p "$portNum" "$hostUser"@"$hostIP" "exit"
initialConnectionCheck=$?
if [ "$initialConnectionCheck" -ne 0 ]; then 
	echo "Error connecting with the old key"
	exit
fi



#save old key contents to var
oldKeyFIleData="$(cat $dirPath/$fileName.pub)"
#change old keyfile name
mv "$dirPath/$fileName" "$dirPath/OLD_$fileName"
mv "$dirPath/$fileName.pub" "$dirPath/OLD_$fileName.pub"
oldPubKey="$dirPath/OLD_$fileName.pub"
oldIdentityFile="$dirPath/OLD_$fileName"
newIdentityFile="$dirPath/$fileName"
#create ney keyfile pair with same name as orig
#the user will be prompted for a password to the key
#only makes the default key type at the moment
#in the comment of the public keyfile it will contain:
#-"date-created: YYYY-MM-DD --$givenComment--"
ssh-keygen -C "--date-created: $(date +%Y-%m-%d)$givenComment" -f "$newIdentityFile" || exit 1
#copy new key data over to hosts auth_keys file
echo "Updating public key on host"
ssh -i "$oldIdentityFile" -p "$portNum" "$hostUser"@"$hostIP" "echo '$(cat $newIdentityFile.pub)' >> $authKeysPath"
#Confirm connection with new key
echo "Checking connection to host with new key pair."
ssh -i "$newIdentityFile" -p "$portNum" "$hostUser"@"$hostIP" "exit"
connectionCheck=$?
if [ "$connectionCheck" -ne 0 ]; then #Unsuccessfull connection with new key
	echo "Error connecting to host with new key pair."
	echo "Exiting"
	exit 1
else #connection was successful
	echo "Connection with new key par successful."
	#remove old key data from hosts authorized_keys file (and left behind blank line)
	ssh -i "$newIdentityFile" -p "$portNum" "$hostUser"@"$hostIP" "sed -i 's?$oldKeyFIleData??g' $authKeysPath ; sed -i '/^$/d' $authKeysPath" || exit 1 #exit if error
	#delete the old key files last in case there was an error
	rm "$oldPubKey"
	rm "$oldIdentityFile"
fi
exit
