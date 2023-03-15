#!/bin/bash
# xdanyl00 Danyleyko Kirill
# 08.03.2023


# Enable POSIX-compatible mode and set LC_ALL to C
export POSIXLY_CORRCT=yes
export LC_ALL=C

# Define default values for optional parameters
MOLE_RC=""
FILE=""
FILE_EXIST=false
DIR=""
DIR_EXIST=false

# Define TIME variable
DATETIME=$(date +"%Y-%m-%d_%H-%M-%S")

# Check if FILE or DIRECTORY exist
for arg in "$@"; do
  if [ -f "$arg" ]; then
    FILE="$arg"
    FILE_EXIST=true
    break
  fi

  if [ -d "$arg" ]; then
    DIR="$arg"
    DIR_EXIST=true
    break
  fi
done






#_________________________________
if [ "$FILE_EXIST" = true ]; then
  	echo "FILE EXIST"
else
  	echo "FILE NOT EXIST"
fi
	
#_________________________________	
if [ "$DIR_EXIST" = true ]; then
  	echo "DIR EXIST"
else
  	echo "DIR NOT EXIST"
fi
#_________________________________







	
# Define FILEPATH variable
if [ -n "$FILE" ]; then
	FILEPATH=$(realpath -e "$FILE")
else
	FILE_EXIST=false
	exit
fi

# Define helper functions
print_help() {
	echo "Help:"
	echo "mole -h"
	echo "mole [-g GROUP] FILE"
	echo "mole [-m] [FILTERS] [DIRECTORY]"
	echo "mole list [FILTERS] [DIRECTORY]"

	echo ""
	echo "-h Prints help on how to use the script."
	echo "-g Assigns the file to the GROUP group."
	echo "-m Selects the most frequently opened file or the most recently opened file."
	echo "[FILTERS] Filters files according to the specified criteria."
	echo "[DIRECTORY] The directory in which the operation is to be performed."
	echo "-list Displays a list of open files."
}

list_files() {
	echo "List File function"
}

open_file(){
	case $# in
	2)
		gedit $FILE
		;;
	3)
		
		gedit $FILE
		;;
	esac
}



# Parse command-line arguments
while getopts ":hg:m:b:a:" opt; do
    case $opt in
        h)
		print_help
		exit
		;;
        g)
        	if [ "$DIR_EXIST" = true ]; then
  			echo "Error: File not exist" >&2
  			exit
		fi 
		open_file $1 $2 $3
		;;
	m)
		echo "arg -m"
		;;
        list)
		echo "arg -list"
        	;;
        secret-log)
        	echo "arg -secret-log"
        	;;
        b)
        	echo "_____________"
		echo "> OPTARG - "
		echo $OPTARG
		echo "_____________"
        	;;     
        \?)
		echo "Error: Invalid switch: -$OPTARG" >&2
		exit
		;;
        *)
		echo "Error: Switch -$OPTARG requires an argument." >&2
		exit
		;;
    esac
done
