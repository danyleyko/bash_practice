#!/bin/bash
# xdanyl00 Danyleyko Kirill
# 08.03.2023

# export MOLE_RC=$HOME/.config/molerc

# Enable POSIX-compatible mode and set LC_ALL to C
export POSIXLY_CORRCT=yes
export LC_ALL=C

# Define values
FILE_EXIST=false
DIR_EXIST=false
GROUP_EXIST=false
LOG="$MOLE_RC"


# Error 
if [ -z "$MOLE_RC" ]; then
	echo "Error: MOLE_RC is not set."
	exit 25
fi

# Define DATE variable
DATETIME_N=$(date +"%Y-%m-%d_%H-%M-%S")

# Check if FILE or DIRECTORY exist
for arg in "$@"; do
  if [ -f "$arg" ]; then
    FILE="$arg"
    FILE_EXIST=true
    break
  elif [ -d "$arg" ]; then
    DIR="$arg"
    DIR_EXIST=true
    break
  fi
done
	
# Define FILEPATH variable
if [ -n "$FILE" ]; then
	FILEPATH=$(realpath -e "$FILE")
else
	FILE_EXIST=false
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

# Define open file functions
open_file(){
	
	case $# in
	2)
		#vi $FILE
		if [[ $FILE_EXIST == true &&  $list_arg == false ]]; then
  			printf "%s: %s : %s : %s\n" "$(basename "$FILE")" "-" "$DATETIME_N" "$(pwd)"  >> "$LOG"
  		else
  			filters $2
		fi
		
		
		;;
	3)
		GROUP=$OPTARG
		GROUP_EXIST=true
		#vi $FILE
		printf "%s: %s : %s : %s\n" "$(basename "$FILE")" "$GROUP" "$DATETIME_N" "$(pwd)">> "$LOG"	
			
		
		;;
	esac
}

# Define filters functions
filters(){
	# separating string by char=','
	IFS=',' read -ra g_filter <<< "$1"
	arr_count=${#g_filter[@]}
	
	
	if [ "$DIR_EXIST" == false ]; then
		DIR_1=$(pwd)
	else 
		DIR_1=$DIR
	fi
	
	
	FILTER=$(awk -v a_date="$a_date" -v b_date="$b_date" -v dir="$DIR_1" -v g_filter="${g_filter[*]}" -v arr_count="$arr_count" '
	BEGIN {
		split(g_filter, array_filters, " ")
	}
	{
		if (b_date != "" && a_date != "") {
			if ((substr($4, 1, 10) >= a_date && substr($4, 1, 10) <= b_date) && dir == $6) {
				if( length(array_filters) > 0 )
				{
					for (i=1; i <= arr_count; i++) {
						if (array_filters[i] == $2) {
							printf "%-20s %-10s %s\n", $1, $2, $6
						
						}
					}
				}
				else if(a_date == null && dir == $6)
				{
					printf "%-20s %-10s %s\n", $1, $2, $6
				}
			}
		}
		else if (b_date == "") 
		{
			if (a_date <= substr($4, 1, 10) && dir == $6) 
			{
				if( length(array_filters) > 0 )
				{
					for (i=1; i <= arr_count; i++) {
						if (array_filters[i] == $2) {
							printf "%-20s %-10s %s\n", $1, $2, $6
						
						}
					}
				}
				else
				{
					printf "%-20s %-10s %s\n", $1, $2, $6
				}
				
			}
			else if(a_date == null && dir == $6)
			{
				printf "%-20s %-10s %s\n", $1, $2, $6
			}
		}	
		else if (a_date == "") 
		{
			if (substr($4, 1, 10) <= b_date && dir == $6) 
			{ 
				if( length(array_filters) > 0 )
				{
					for (i=1; i <= arr_count; i++) {
						if (array_filters[i] == $2) {
							printf "%-20s %-10s %s\n", $1, $2, $6
						
						}
					}
				}
				else
				{
					printf "%-20s %-10s %s\n", $1, $2, $6
				}
			} 
			else if(b_date == null && dir == $6)
			{
				printf "%-20s %-10s %s\n", $1, $2, $6
			}
		}
		else
		{
			printf "Empty list"
		}
	}' "$LOG")
	
}



# Parse command-line arguments - list and secret-log
case $1 in
	list)	
	
		# list
		list_arg=true
		shift
		;;
		
	secret-log) 
	
		# secret-log
		secret_log_arg=true
		exit
		;;
	-m)	
		m_arg=true
		shift
		;;
	*)	
	
		# No command specified, default to opening a file
		for i in 1
		do
			# For Parsing other arguments
			if [[ "$1" != "list" && "$1" != "secret-log" && "$1" != "m_arg" && "$1" != "$FILE" ]]; then
				break 
			fi
			
			# Check if have >= 1 arg
			if [ $# -gt 1 ]; then
				echo "Error: You must write only 1 argument" >&2
				exit 3
			fi
				
			# Open File
			if [[ -n "$2" && "$FILE" != "" ]] || [ "$FILE_EXIST" == "false" ]; then
				echo "Error: File not exist" >&2
				exit 3
			elif [ "$FILTER" != "" ]; then
				echo $FILTER
			    	#vi $FILE
			else
			    	printf "%s: %s : %s : %s\n" "$(basename "$FILE")" "-" "$DATETIME_N" "$(pwd)"  >> "$LOG"
			    	#vi $FILE
			fi
		done
		;;
		
esac

# Parse command-line arguments
while getopts "hg:m:b:a:" opt; do
    case $opt in
    	a)	
    		# Checks if its a date or not
		if [[ "$OPTARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
			a_date=$OPTARG
		else
			echo "Error: '$OPTARG' is not a date" >&2
			exit 27 
		fi
		;;
	
	b)
		# Error Checks if its a date or not
		if [[ "$OPTARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
			b_date=$OPTARG
		else
			echo "Error: '$OPTARG' is not a date" >&2
			exit 27 
		fi
		;;  
	
	h)
		print_help
		exit
		;;
	g)
		open_file $1 $2 $3 
		;;
	
	\?)
		# Error
		echo "Error: Invalid switch: -$OPTARG" >&2
		exit 1 
		
		;;
	*)
		# Error
		echo "Error: Switch -$OPTARG requires an argument." >&2
		exit 2 
		;;
		
    esac
    
done

if [[ $list_arg == true ]]; then
	filters
	echo "$FILTER" | awk '{ printf "%-20s %-10s\n", $1, $2 }'
elif [[ $secret_log_arg == true ]]; then
	if [ ! -d "$HOME/.mole" ]; then
		mkdir "$HOME/.mole"
	fi
elif [[ $m_arg == true ]]; then
	
	filters
	sort_filter=$(printf "%s\n" "$FILTER" | uniq -c | sort -nr | awk '{
		printf "%s\n", $2
	}' |
	head -n 1 |
	sed 's/:$//' |
	xargs echo)
	
	
	if [ -f "$sort_filter" ];then
		vi $sort_filter
	else
		echo "Error: File not exist" >&2
		exit 3
	fi
	
fi

