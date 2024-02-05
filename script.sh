#!/bin/bash

# Log file name
LOG_FILE="/opt/sitemap.log"

# Get current date and time in ISO 8601 format
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log script started details
echo "Script started at: $START_TIME" >> "$LOG_FILE"

# API endpoint
API_URL='https://localhost:8080/'

# Fetch and format the sitemap in a single pipeline
CURL_STATUS=$(curl --location --write-out "%{http_code} %{url_effective}\\n" --output /opt/sitemap.xml "$API_URL" | awk '{print $1}')

# Check if the curl command was successful (status code 200)
if [ "$CURL_STATUS" -eq 200 ]; then
  echo "Curl command successful. Status code: $CURL_STATUS" >> "$LOG_FILE"
  
  # Format the sitemap.xml (basic formatting)
  sed -i 's/></>\n</g' /opt/sitemap.xml  # Add newlines between tags
  awk '{printf "%4s%s\n", "", $0}' /opt/sitemap.xml > /opt/sitemap.xml.tmp  # Add indentation
  mv /opt/sitemap.xml.tmp /opt/sitemap.xml

else
  echo "Curl command failed. Status code: $CURL_STATUS" >> "$LOG_FILE"
fi

# Get end time
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log script ende details
echo "Script ended at: $END_TIME" >> "$LOG_FILE"
