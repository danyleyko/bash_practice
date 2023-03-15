#!/bin/sh
# xdanyl00 Danyleyko Kirill
# 08.03.2023

# Define default values for optional parameters
GROUP=""
FILTERS=""
DIRECTORY=""

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
	echo "Open File function"
}

# Parse command-line arguments
while getopts ":hg:m:ls" opt; do
    case $opt in
        h)
            print_help
            exit 0
            ;;
        g)
            echo "arg -g"
            group="$OPTARG"
            open_file
            ;;
        m)
            echo "arg -m"
            FILTERS="-type f"
            ;;
        l)
             list_files
             echo "arg -list"
             ;;
        s)  
             open_file
             echo "arg -secret-log"
             ;;     
        \?)
            echo "Invalid switch: -$OPTARG" >&2
            exit 1
            ;;
        *)
            echo "Switch -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))


