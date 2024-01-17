#!/bin/bash

# Function to handle errors
handle_error() {
    local error_message=$1
    echo "Error: $error_message"
    exit 1
}

############## Main script ##############

#Constant of the scripts path 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Check if the number of arguments is not equal to 1
if [ "$#" -ne 1 ]; then
    handle_error "Please provide exactly one argument (-backup or -health)"
fi

# Check the provided argument and display the corresponding file content
case "$1" in
    "-backup")
        cat "$SCRIPT_DIR/backup_log.txt"
        ;;
    "-health")
        cat "$SCRIPT_DIR/health_check_log.txt"
        ;;
    *)
        handle_error "Invalid argument. Please use -backup or -health."
        ;;
esac
