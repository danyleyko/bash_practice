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
LOG="$MOLE_RC"
a_date=""
b_date=""
list_arg=false
secret_log_arg=false
m_arg=false
g_arg=false


# Error $MOLE_RC not set
if [ -z "$MOLE_RC" ]; then
	echo "Error: MOLE_RC is not set."
	exit 25
fi

# Define DATE variable
DATETIME_N=$(date +"%Y-%m-%d_%H-%M-%S")

# Check if FILE exist
for arg in "$@"; do
	if [ -f "$arg" ]; then
		FILE="$arg"
		FILE_EXIST=true
		break
	fi
done

# Check if DIRECTORY exist
for arg in "$@"; do
	if [ -d "$arg" ]; then
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
		
		if [[ $FILE_EXIST == true &&  $list_arg == false &&  $m_arg == false ]]; then
  			printf "%s: %s : %s : %s : %s\n" "$(basename "$FILE")" "-" "$DATETIME_N" "$(pwd)" "$FILEPATH" >> "$LOG"
  		else
  			filters $2
		fi
			;;
	3)
		GROUP=$OPTARG
		#vi $FILE
		if [[ $list_arg == false &&  $m_arg == false ]]; then 
			printf "%s: %s : %s : %s : %s\n" "$(basename "$FILE")" "$GROUP" "$DATETIME_N" "$(pwd)" "$FILEPATH">> "$LOG"
		fi
		
		;;
	esac
}

# Define filters functions
filters(){
	# separating string by char=','
	if [[ $g_arg == true ]]; then
		IFS=',' read -ra array <<< "$1"
	fi
	
	if [[ "$DIR_EXIST" == false ]]; then
		DIR_1=$(pwd)
		
	elif [[ $secret_log_arg == true ]]; then
		DIR_1="$1"
		
	elif [[ $DIR_EXIST == true && $g_arg == true ]]; then
		DIR_1="$2"	
		
	elif [[ $DIR_EXIST == true && $g_arg == false ]]; then
		DIR_1="$1"
		
	else 
		DIR_1=$DIR
		
	fi
	
	FILTER=$(awk -v a_date="$a_date" -v b_date="$b_date" -v dir="$DIR_1" -v arr="$(echo "${array[@]}")" '
	    BEGIN {
	    	n = split(arr, filters, " ");
	    }
	    {
	    	
	    	if (b_date != null && a_date != null) {

			if ((substr($4, 1, 10) >= a_date && substr($4, 1, 10) <= b_date) && dir == $6) {
				if( n > 0 )
				{
					for (i=1; i <= n; i++) {
						if (filters[i] == $2) {
							printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
						
						}
					}
				}
				else if(dir == $6)
				{
					printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
				}
			}
		}
		else if (b_date == null) 
		{
	
			if (a_date <= substr($4, 1, 10) && dir == $6) 
			{
				if( n > 0 )
				{
					for (i=1; i <= n; i++) {
						if (filters[i] == $2) {
							printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
						
						}
						
					}
				}
				else
				{	
					printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
				}
				
			}
			else if(a_date == null && dir == $6)
			{
				printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
			}
		}	
		else if (a_date == null) 
		{

			if (substr($4, 1, 10) <= b_date && dir == $6) 
			{ 
				if( n > 0 )
				{
					for (i=1; i <= n; i++) {
						if (filters[i] == $2) {
							printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
						
						}
					}
				}
				else
				{
					printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
				}
			} 
			else if(b_date == null && dir == $6)
			{
				printf "%s %s %s %s %s\n", $1, $2, $4, $6, $8
			}
		}
		
	}' "$LOG")
	
	if [[ $FILTER == "" ]]; then
		#FILTER="Empty_list"
		FILTER="List is empty"
	fi
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
		shift
		;;
	-m)	
		# m
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
			    	printf "%s: %s : %s : %s : %s\n" "$(basename "$FILE")" "-" "$DATETIME_N" "$(pwd)" "$FILEPATH" >> "$LOG"
			    	#vi $FILE
			fi
		done
		;;
		
esac

# Parse command-line arguments
while getopts ":g:m:b:a:h" opt; do
    case $opt in
    	a)	
		if [[ "$OPTARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
			a_date=$OPTARG
		else
			echo "Error: '$OPTARG' is not a date" >&2
			exit 27 
		fi
		;;
	 b)
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
		g_arg=true
		for i in $(seq 1 $#); do
  			if [ "${!i}" = "-g" ];then
  				arg_g_count=$i
  			fi
		done
		shift $(($arg_g_count - 1))
		
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

#
if [[ $list_arg == true ]]; then
	
	if [[ $g_arg == true && $DIR_EXIST == true ]]; then
		filters $2 $DIR
		
	elif [[ $g_arg == false && $DIR_EXIST == true ]]; then 
		filters $DIR
		
	elif [[ $g_arg == true && $DIR_EXIST == false ]]; then 
		filters $2
		
	else	
		filters
		
	fi
	
	shift $((OPTIND - 1 )) 
	# Error
	if [[ ! -d $1  && $DIR_EXIST == true ]]; then
		echo "Error: You write '$1' which not exist" >&2
		exit
	fi
		
	if [[ $FILTER == "List is empty" ]]; then
		echo "$FILTER"
	else
		echo "$FILTER" | awk '{ printf "%s %s\n", $1, $2 }'| column -t 
	fi
	
	
elif [[ $secret_log_arg == true ]]; then
	# Create folder for secret-log
	if [ ! -d "$HOME/.mole" ]; then
		mkdir "$HOME/.mole"
	fi
	
	# Parsing DIR
	if [ $DIR_EXIST == true ] ;then 
		filters $DIR
	else
		filters
	fi
	
	
	
	shift $((OPTIND - 1 )) 
	# Error
	if [[ ! -d $1 && $DIR_EXIST == true ]]; then
		echo "Error: You write '$1' which not exist" >&2
		exit
	fi
	
	
	if [[ $FILTER == "List is empty" ]]; then
		echo "$FILTER" 
	else
		echo "$FILTER" | awk '{ printf "%s %s %s\n", $1, $5, $3}' | sort | uniq -c | awk '{ 
		printf "%s;%s\n", $3 ,$4 
		}'| bzip2 > ~/.mole/log_"$USER"_"$(date +"%Y-%m-%d_%H-%M-%S")".bz2
		
		
	fi
	
	
	
	
elif [[ $m_arg == true ]]; then
	
	if [[ $g_arg == true && $DIR_EXIST == true ]]; then
		filters $2 $DIR
		
	elif [[ $g_arg == false && $DIR_EXIST == true ]]; then 
		filters $DIR
		
	elif [[ $g_arg == true && $DIR_EXIST == false ]]; then 
		filters $2
		
	else	
		filters
		
	fi
	
	sort_filter=$(printf "%s\n" "$FILTER" | uniq -c | sort -nr | awk '{
		printf "%s\n", $2
	}' |
	head -n 1 |
	sed 's/:$//' |
	xargs echo)
	
	if [ -f "$sort_filter" ];then
		vi $sort_filter
	else
		echo "Error: File - '$sort_filter' not exist" >&2
		exit 3
	fi
	
fi

