### Tired of manually updating your data ?  Automate the process with this easy-to-follow guide!

**About the Author:**

 Hi! I'm [satish Kumar Rai](https://github.com/kumarsatish23), a passionate Developer. I'm excited to share this automation solution with you.

# Automating Sitemap Generation with Cron Job

This guide outlines the steps to create a cron job in a Linux environment that runs a service to generate a sitemap daily at 12 AM. The process involves creating a timer, service, and a Bash script to fetch and format the sitemap. Logs are generated for tracking the script's execution.

### Prerequisites:

- A Linux server with root access
- A sitemap generation tool (e.g., `wget`, `curl`)
- Basic understanding of systemd and Bash scripting
#
![GNU Bash Badge](https://img.shields.io/badge/GNU%20Bash-4EAA25?logo=gnubash&logoColor=fff&style=for-the-badge)
![Linux Badge](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=000&style=for-the-badge)
![LinuxServer Badge](https://img.shields.io/badge/LinuxServer-DA3B8A?logo=linuxserver&logoColor=fff&style=for-the-badge)
![Amazon EC2 Badge](https://img.shields.io/badge/Amazon%20EC2-F90?logo=amazonec2&logoColor=fff&style=for-the-badge)
![Postman Badge](https://img.shields.io/badge/Postman-FF6C37?logo=postman&logoColor=fff&style=for-the-badge)

## Step 1: Navigate to the systemd system folder
```bash
cd /etc/systemd/system
```

## Step 2: Create a timer file
```bash
nano sitemapsync.timer
```

### Content of `sitemapsync.timer` file:
```ini
[Unit]
Description=Run a service called sitemapsync.service every day at 12AM

[Timer]
Unit=sitemapsync.service
OnCalendar=*-*-* *:00:00

[Install]
WantedBy=timers.target
```
Exit the editor.

## Step 3: Create a service file
```bash
nano sitemapsync.service
```

### Content of `sitemapsync.service` file:
```ini
[Unit]
Description=Run a script called script.sh only once

[Service]
Type=oneshot
ExecStart=/bin/bash /<path>/script.sh
User=ec2-user
Group=ec2-user
WorkingDirectory=/<path>

[Install]
WantedBy=multi-user.target
```
Exit the editor.

## Step 4: Create a Bash file in the specified path
```bash
nano /<path>/script.sh
```

### Content of the Bash file:
```bash
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
```

## Step 5: Start the automated job

### Set execute permission for the script
```bash
sudo chmod +x /<path>/script.sh
```

### Reload systemd daemon
```bash
sudo systemctl daemon-reload
```

### Restart the timer
```bash
sudo systemctl restart sitemapsync.timer
```

### Check the status of the timer
```bash
sudo systemctl status sitemapsync.timer
```

# Viewing Service Logs

## Read the last 20 lines of logs for `sitemapsync.service`
```bash
journalctl -u sitemapsync.service -n 20
```

## View additional details or older logs
```bash
journalctl -xe
```
