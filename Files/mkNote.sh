#!/bin/bash

idDisplayArray=()
idFolderArray=()
CUSFOLDER=
PCFOLDER=
IDNUMBER=
nameArray=()
folderArray=()

#source "./Files/commonFunctions.source"

c_timestamp() {
        date | awk '{print $2,$3,$4}'
}

find_PC() {
	echo
	old_IFS=$IFS
	for i in $(find "$CUSFOLDER" -maxdepth 6 -type f -name "log")
	        do
	                IFS=
	                idDisplayArray+=($(echo $i | grep -o 'ID[0-9]'))
	                idFolderArray+=($(echo ${i%/*}))
	        done
	IFS=${old_IFS}

	if [ "${idDisplayArray[1]}" ]; then

		PS3="Please choose a PCID from the matched customer search: "

		select pcOpt in "${idDisplayArray[@]}"; do
			case $pcOpt in
				"${idDisplayArray[0]}")
					PCFOLDER="${idFolderArray[0]}";
					make_note
					break;
					;;
				"${idDisplayArray[1]}")
					PCFOLDER="${idFolderArray[1]}";
					make_note
					break;
					;;
				"${idDisplayArray[2]}")
					PCFOLDER="${idFolderArray[2]}";
					make_note
					break;
					;;
				"${idDisplayArray[3]}")
					PCFOLDER="${idFolderArray[3]}";
					make_note
					break;
					;;
				"${idDisplayArray[4]}")
					PCFOLDER="${idFolderArray[4]}";
					make_note
					break;
					;;
				*)
					echo "ERROR: YOU HAVE MADE AN INCORRECT CHOICE.";
					echo "PLEASE CHOOSE ONE OF THE OPTIONS LISTED.";
					sleep 1;
					;;
			esac
		done
	else
		PCFOLDER="${idFolderArray[0]}"
		IDNUMBER="${idDisplayArray[0]}"
		make_note
	fi
}

make_note() {
        if [ "${editNoteOnly}" == 'y' ]; then
          nano "${PCFOLDER}/notes"
          exit 0
        fi

	if [ "$1" ]; then
		notesList="$1"
		PCFOLDER="$2"
	fi

	echo
	echo "Below are the notes for the chosen PCID so far."
	echo
        echo '****************************************************************************'
        cat "${PCFOLDER}/notes"
        echo '****************************************************************************'
        echo 'Please enter your note. It will be formatted automatically in the file.'
	echo
        read -ep '>' note
	echo -e "@@@@@ $(c_timestamp) @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> "$PCFOLDER/notes"

	if [ "$notesList" ]; then
		echo -n "$notesList" >> "$PCFOLDER/notes"
	fi
#	nano +999,999 -L "$PCFOLDER/notes"
        echo "${note}" | fold -sw 68 >> "$PCFOLDER/notes"
	echo  >> "$PCFOLDER/notes"
}

main() {
clear

echo '***********************************************************************************************'
printf "Enter or scan in PCID or type (c) to search for computer by customer name: "
read choice1
echo

if [ "$choice1" != "c" ] && [ "${choice1:0:2}" != "ID" ]; then
	choice1="ID${choice1}"
fi

isID=$(echo $choice1 | grep 'ID')

if [ "$isID" ]; then
	eval PCID="$choice1"

	if [ "${PCID:0:2}" != "ID" ]; then
		PCIDLoc=$(mktemp)
		echo $PCID > $PCIDLoc
		PCID=$(sed -e 's/^/ID/' $PCIDLoc)
		rm $PCIDLoc
	fi

	echo

	PCFOLDER=$(find ./* -maxdepth 6 -name "$PCID")
	CUSFOLDER=$(echo "${PCFOLDER%/*}")

	if [ ! "$PCFOLDER" ]; then
	        echo "ERROR: PC ID COULD NOT BE FOUND. PLEASE CHECK FOLDER AND TRY AGAIN."
	        sleep 1
	        exit
	fi

	if [ ! -f "$PCFOLDER/log" ]; then
	        echo "ERROR: PC HAS NOT BEEN CHECKED IN YET."
	        sleep 1
	        exit
	fi

	make_note

elif [ "$choice1" == "c" ]; then
	echo '***************************************************************'
	printf "Please enter the customer name or phone # to look for: "
	read searchName
	echo

	old_IFS=$IFS
	for i in $(find . -maxdepth 6 -type f -name "info.cus"); do
	        IFS=
	        nameArray+=($(egrep -C 99 -i "$searchName" "$i"| head -n 1))
		tempVar=$(egrep -il "$searchName" "$i")
	        folderArray+=($(echo ${tempVar%/*}))
	done
	IFS=${old_IFS}

	if [ "${nameArray[1]}" ]; then

		PS3="Please choose a customer from the match search: "

		select cusOpt in "${nameArray[@]}"; do
	        	case $cusOpt in
	                	"${nameArray[0]}")
	                        	CUSFOLDER="${folderArray[0]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[1]}")
	                        	CUSFOLDER="${folderArray[1]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[2]}")
	                        	CUSFOLDER="${folderArray[2]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[3]}")
	                        	CUSFOLDER="${folderArray[3]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[4]}")
	                        	CUSFOLDER="${folderArray[4]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[5]}")
	                        	CUSFOLDER="${folderArray[5]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[6]}")
	                        	CUSFOLDER="${folderArray[6]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[7]}")
	                        	CUSFOLDER="${folderArray[7]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[8]}")
	                        	CUSFOLDER="${folderArray[8]}"
					find_PC
					break;
	                        	;;
	                	"${nameArray[9]}")
	                        	CUSFOLDER="${folderArray[9]}"
					find_PC
					break;
	                        	;;
				*)
					echo "ERROR: YOU HAVE MADE AN INCORRECT CHOICE.";
					echo "PLEASE CHOOSE ONE OF THE OPTIONS LISTED.";
					sleep 1;
					;;
		        esac
		done
	else
		CUSFOLDER="${folderArray[0]}"
		find_PC
	fi

else
	echo "ERROR: AN INCORRECT OPTION HAS BEEN CHOSEN. PLEASE TRY AGAIN."
	sleep 1
	main
fi
}

if [ "${1}" == 'm' ]; then
  editNoteOnly='y'
fi

if [ -n "$1" -a "${1}" != 'm' ]; then
	make_note "$1" "$2"
	exit 0
fi
main
exit 0
