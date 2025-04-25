#!/bin/bash

# Ensure ZAP API is ready
echo "ZAP API is starting up..."
while ! curl -s $ZAP_IP >/dev/null; do
  echo "Waiting for ZAP API to be ready..."
  sleep 2
done

echo "ZAP API is ready!"

curl -s localhost:8080

echo "Web App is starting up..."

while ! curl -s localhost:8080 >/dev/null; do
  echo "Waiting for Web App to be ready..."
  sleep 2
done

echo "Web App is ready!"

# Spider the target
curl "$ZAP_IP/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL"

echo "Spidering the target: $TARGET_URL"

# Wait for spider to complete
while [[ "$(curl -s $ZAP_IP/JSON/spider/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')" != "100" ]]; do
  echo "Spidering progress: $(curl -s $ZAP_IP/JSON/spider/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')%"
  sleep 5
done

echo "Spidering complete!"

# Active scan
curl "$ZAP_IP/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL&recurse=true"

echo "Active scanning the target: $TARGET_URL"

# Wait for active scan to complete
while [[ "$(curl -s $ZAP_IP/JSON/ascan/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')" != "100" ]]; do
  echo "Active scanning progress: $(curl -s $ZAP_IP/JSON/ascan/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')%"
  sleep 10
done

echo "Active scanning complete!"

# Generate HTML report
mkdir -p owasp-zap/reports
curl "$ZAP_IP/OTHER/core/other/htmlreport/?apikey=$ZAP_API_KEY" -o owasp-zap/reports/zap_report.html

echo "Scan complete! Report saved to owasp-zap/reports/zap_report.html"
