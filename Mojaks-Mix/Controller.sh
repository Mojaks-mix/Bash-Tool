#!/bin/bash
#####################################
# Author: Mohammad Sa'bi
# Version: v1.0.0
# Date: 2023-1-16
# Description: Mojaks-Mix tool!
# Usage:Mojaks-Mix -c -zip <source_path> [backup_destination] 
#	Mojaks-Mix -c <source_path> [backup_destination] 
#	Mojaks-Mix -hc
#	Mojaks-Mix -log
#	Mojaks-Mix -h  # for help
#####################################

#Constant of the scripts path 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to handle errors
handle_error() {
    local error_message=$1
    echo "Error: $error_message"
    exit 1
}

# Function to display help message
function show_help() {
    echo "Usage: Mojaks-Mix [OPTIONS] [ARGUMENTS]"
    echo "Options:"
    echo "	-c	or	copy		*Create a comprised copy of a folder"
    echo "	-hc	or	health-check	*System Health Check"
    echo "	-log	or	log		*Display the content of the log file"
}

# Function to handle backup action
function backup_action() {
    # Calling the action file of the backup 
    source $SCRIPT_DIR/back-up.sh $@
}

# Function to handle health check action
function health_check_action() {
    # Calling the action file of the health check
    source $SCRIPT_DIR/health-check.sh $@
}

# Function to display log content
function display_log() {
    # Calling the action file display logs
    source $SCRIPT_DIR/display-logs.sh $@
}

# Function to check if the input matches the specified values or flags
check_input() {
    local input="$1"
    # Define the allowed values and flags using regular expressions
    allowed_values=("help" "copy" "health-check" "logs")
    allowed_flags=("-c" "-h" "-hc" "-log")
    # Check if the input matches either the values or the flags
    if [[ ${allowed_values[@]} =~ $input || ${allowed_flags[@]} =~ $input ]]; then
        case $input in
        "-c"|"copy")
            backup_action ${@:2}
            exit
            ;;
        "-hc"|"health-check")
            health_check_action $@
            exit
            ;;
        "-log"|"logs")
            display_log ${@:2}
            exit
            ;;
        "-h"|"help")
            show_help
            exit
            ;;
    	esac
    else
       # If no valid command is provided, display help
		handle_error "Invalid command. Use 'help' command for usage."
    fi
}

############## Main script ##############

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    handle_error "No command provided. Use 'help' for usage."
fi

# Parse command line arguments
check_input $@
