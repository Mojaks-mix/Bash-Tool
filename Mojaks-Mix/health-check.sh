#!/bin/bash

#line separator 
SEPARATOR="             _________________________________             "

#Constant of the scripts path 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to handle errors
handle_error() {
    local error_message=$1
    echo "Error: $error_message"
    exit 1
}

# Output directory for the health reports
output_file="$SCRIPT_DIR/system_health_report_$(date +'%Y-%m-%d').pdf"

# Function to check disk space
check_disk_space() {
    echo "$SEPARATOR"
    echo "1-Disk Space Check: $(df -h / | awk 'NR==2 {print $5}')"
    echo ""
    df -h | awk '{print $1, $2, $3, $4, $5, $6}' | column -t
}

# Function to check memory usage
check_memory_usage() {
    echo "$SEPARATOR"
    echo "2-Memory Usage Check: $(free -m | awk 'NR==2 {print $3 "MB used out of " $2 "MB"}')"
    echo ""
    echo "      total used  free  available"
    echo "$(free -m | awk '/Mem/{print $1, $2, $3, $4, $7}' | column -t)"
}

# Function to check CPU usage
check_cpu_usage() {
    echo "$SEPARATOR"
    echo "3-CPU Usage Check:$(top -bn1 | awk '/Cpu\(s\):/ {print $2}')% used"
}

# Function to check running services
check_running_services() {
    echo "$SEPARATOR"
    echo "4-Running Services Check: $(systemctl list-units --type=service --state=running | grep -c 'running') running services."
    echo ""
    echo "$(systemctl list-units --type=service --state=running | awk '{print $1, $2, $3, $4}' | column -t)"
}

# Function to check recent system updates
check_system_updates() {
    #formatting the report so this part will be in a new page
    for ((i=1; i<=10; i++)); do
    	echo ""
    done
	
    #last update that was loged
    echo "$SEPARATOR"
    
    # Get the path to the package manager log file
    log_file="/var/log/apt/history.log"

    # Check if the log file exists
    if [ ! -e "$log_file" ]; then
    handle_error "Package manager log file not found. Update information unavailable"
    fi
      
    last_update=$(stat -c %Y "$log_file")

    # Convert timestamp to a readable date
    last_update_date=$(date -d "@$last_update" "+%Y-%m-%d %H:%M:%S")
    
    echo "5-Last System Update Date: $last_update_date"
    
    #recent Updates
    echo "$SEPARATOR"
    echo "6-Recent System Updates Check:"
    echo ""
    if [ -x "$(command -v apt)" ]; then
        apt list --upgradable | column -t
    elif [ -x "$(command -v yum)" ]; then
        yum check-update | column -t
    else
        echo "Unsupported package manager. Update check not performed."
    fi
}

# Function to generate the PDF report
generate_pdf_report() {
    echo "Generating PDF Report..."
    {
        echo "System Health Report - $(date +'%Y-%m-%d')"
        echo ""
        check_disk_space
        check_memory_usage
        check_cpu_usage
        check_running_services
        check_system_updates
    } | enscript -B -p - | ps2pdf - "$output_file" || handle_error "You need to install enscript!"
    echo "PDF Report generated: $output_file"

    # Open the generated PDF automatically
    xdg-open "$output_file" &> /dev/null
}

# Function to check for high memory and CPU usage
check_high_usage() {
    local memory_threshold=80
    local cpu_threshold=80

    local memory=$(free | awk '/Mem/{printf("%.2f", $3/$2*100)}')
    local cpu=$(top -bn1 | awk '/Cpu\(s\):/ {print $2}' | cut -d. -f1)
    
    if (( $(echo "$memory > $memory_threshold" | bc -l) )); then
        echo "Warning: High Memory Usage! Current usage: ${memory}%"
    fi

    if (( $cpu > $cpu_threshold )); then
        echo "Warning: High CPU Usage! Current usage: ${cpu}%"
    fi
}

############## Main script ##############

if [ "$#" == 1 ] && [[ "$1" != "-hc"  ||  "$1" != "health-check" ]] ; then
    # Execute the health check functions and generate the PDF report
    generate_pdf_report

    # Check for high memory and CPU usage
    check_high_usage
    
    # Log health check results to the log file
    echo "Log entry: Health check performed at $(date)" >> "$SCRIPT_DIR/health_check_log.txt"
    
    else
    # If no valid command is provided, display help
    handle_error "Invalid command. Use 'Mojaks-Mix help' for usage."
    
    fi

