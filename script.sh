#!/bin/bash

# Log file name
LOG_FILE="/opt/sitemap.log"

# Function to log messages to the file
log_message() {
  echo "$1" >> "$LOG_FILE"
}

# Function to fetch and format the sitemap
fetch_and_format_sitemap() {
  # Log API request headers
  log_message "API Request Headers:"
  curl -I "$API_URL" >> "$LOG_FILE"

  # Fetch and format the sitemap.xml in a single pipeline
  curl_result=$(curl --location --write-out "%{http_code}" --output /opt/sitemap.xml "$API_URL")
  CURL_STATUS=${curl_result%% *}  # Extract the status code from the result

  # Log the curl command execution and status
  log_message "Curl command executed. Status code: $CURL_STATUS"

  # Check if the curl command was successful (status code 200)
  if [ "$CURL_STATUS" -eq 200 ]; then
    log_message "Curl command successful. Status code: $CURL_STATUS"
    
    # Format the sitemap.xml (basic formatting)
    # Log the sed command execution
    sed -i 's/></>\n</g' /opt/sitemap.xml  # Add newlines between tags
    log_message "Formatted sitemap.xml with newlines between tags."
    
    # Log the awk command execution
    awk '{printf "%4s%s\n", "", $0}' /opt/sitemap.xml > /opt/sitemap.xml.tmp  # Add indentation
    mv /opt/sitemap.xml.tmp /opt/sitemap.xml
    log_message "Indented sitemap.xml."

  else
    log_message "Curl command failed. Status code: $CURL_STATUS"
  fi
}

# Get current date and time in ISO 8601 format
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log script started details
log_message "Script started at: $START_TIME"

# API endpoint
API_URL='https://localhost:8080/'

# Fetch and format the sitemap
fetch_and_format_sitemap

# Get end time
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log script end details
log_message "Script ended at: $END_TIME"
log_message "___________________________________________________________________________________________________________________________________"
