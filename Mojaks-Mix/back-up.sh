#!/bin/bash

#Constant of the scripts path 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to handle errors
handle_error() {
    local error_message=$1
    echo "Error: $error_message"
    exit 1
}

# Function to check file or directory size
check_size() {
    local path=$1
    local size=$(du -s "$path" | awk '{print $1}')
    if [ "$size" -gt 1000000000 ]; then
        handle_error "Size of $path is more than 1 GB."
        exit 1
    fi
}

# Check if correct number of arguments provided and handle the errors
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    echo "Usage to backup:"
    echo "    Mojaks-Mix [-c or copy] <source_path> [backup_directory *optional]"
    echo ""
    echo "Usage to copress the backup:"
    echo "    Mojaks-Mix [-c or copy] [-zip] <source_path> [backup_directory *optional]"
    exit 1
fi

# Set default backup directory if not provided
backup_directory=""
zip_flag=false

# Set flags based on user input
if [ "$1" == "-zip" ]; then
    zip_flag=true
    source_path="$2"
    backup_directory="$3"
else
    source_path="$1"
    backup_directory="$2"
fi

# If backup directory is not provided, set it to default
if [ -z "$backup_directory" ]; then
    backup_directory="$SCRIPT_DIR/Mojaks_Back_Up/default_backup_directory"
fi

# Check if backup directory exists, create it if not
if [ ! -d "$backup_directory" ]; then
    mkdir -p "$backup_directory" || handle_error "Unknown backup directory: $backup_directory"
fi

# Get absolute path for the backup directory
backup_directory=$(realpath "$backup_directory")

# Check if the provided source path exists
if [ ! -e "$source_path" ]; then
    handle_error "Source path $source_path not found."
fi

# Check the size of the source path
check_size "$source_path"

# Check if the provided source path is a directory
if [ -d "$source_path" ]; then
    # If it's a directory, create a tar archive
    backup_file="$backup_directory/$(date +"%Y%m%d%H%M%S")_$(basename "$source_path").tar"

    tar_options=""
    if [ "$zip_flag" == true ]; then
        # If -zip flag is provided, compress the tar archive
        backup_file="$backup_file.gz"
        tar_options="-czf"
    else
        tar_options="-cf"
    fi

    tar "$tar_options" "$backup_file" -C "$(dirname "$source_path")" "$(basename "$source_path")"
    echo "Directory $source_path backed up to $backup_file"

else
    # If it's a file, perform the backup
    backup_file="$backup_directory/$(date +"%Y%m%d%H%M%S")_${source_path##*/}"

    if [ "$zip_flag" == true ]; then
        # Compress the file before backup
        gzip -c "$source_path" > "$backup_file.gz"
        echo "File $source_path compressed and backed up to $backup_file.gz"
    else
        cp "$source_path" "$backup_file"
        echo "File $source_path backed up to $backup_file"
    fi
fi

# Log the action
echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup performed: $source_path to $backup_file" >> "$SCRIPT_DIR/backup_log.txt"

