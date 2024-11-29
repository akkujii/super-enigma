#!/bin/bash

# Check if WEBAPP_URL is set
if [ -z "$WEBAPP_URL" ]; then
    echo "Error: WEBAPP_URL environment variable is not defined"
    exit 1
fi

# Check if GITHUB_SHA is set
if [ -z "$GITHUB_SHA" ]; then
    echo "Error: GITHUB_SHA environment variable is not defined"
    exit 1
fi

# Send request to the URL specified in WEBAPP_URL
response=$(curl -s "$WEBAPP_URL")

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch content from $WEBAPP_URL"
    exit 1
fi

# Extract the content between <code> tags
extracted_sha=$(echo "$response" | sed -n 's/.*<code>\([^<]*\)<\/code>.*/\1/p')

# Check if extraction was successful
if [ -z "$extracted_sha" ]; then
    echo "Error: Failed to extract SHA from the response"
    exit 1
fi

# Compare extracted SHA with GITHUB_SHA
if [ "$extracted_sha" = "$GITHUB_SHA" ]; then
    echo "Deployed application matches the expected deployment: $extracted_sha"
    exit 0
else
    echo "Deployed application does not match the expected. Expected: $GITHUB_SHA, Found: $extracted_sha"
    exit 1
fi
