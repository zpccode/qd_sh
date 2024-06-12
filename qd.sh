#!/bin/bash
sleep 1
# Define an associative array containing multiple sets of cookies and URLs
declare -A request_data
request_data=(
    ["cookie1"]="key=value"
    ["url1"]="https://a.com"

    ["cookie2"]="key=value"
    ["url2"]="https://b.com"
     # You can add more cookies and URLs here
)

# Get all keys of the associative array
keys=(${!request_data[@]})

# Loop through the dictionary of cookies and URLs
for ((i=0; i<${#keys[@]}/2; i++))
do
    cookie_key="cookie$((i+1))"
    url_key="url$((i+1))"
    
    cookie=${request_data[$cookie_key]}
    url=${request_data[$url_key]}
    
    # Initialize retry count
    retries=0
    max_retries=5
    success=false
    
    while [ $retries -lt $max_retries ]; do
        # Get the current time
        current_time=$(date "+%Y-%m-%d %H:%M:%S")
        
        # Send a request with the cookie, redirect output to /dev/null, and get the HTTP status code
        status_code=$(curl -s --proxy "http://127.0.0.1:10809" -o /dev/null -w "%{http_code}" --cookie "$cookie" "$url")
        
        # Log the URL and status code
        echo "[$current_time] URL: $url, Status Code: $status_code" >> /root/qd/request.log
        
        # Check the HTTP status code
        if [ $status_code -eq 200 ]; then
            echo "Request successful, URL: $url, Status Code: 200"
            success=true
            break
        elif [[ $status_code -ge 500 && $status_code -lt 600 ]]; then
            echo "Server error, URL: $url, Status Code: $status_code, Retrying $((retries + 1)) time"
            retries=$((retries + 1))
            sleep 3
        else
            echo "Request failed, URL: $url, Status Code: $status_code"
            break
        fi
    done
    
    if [ "$success" = false ]; then
        echo "Request ultimately failed, URL: $url, please check the issue"
    fi
done
