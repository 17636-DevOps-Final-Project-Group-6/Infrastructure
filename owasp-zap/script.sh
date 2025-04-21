#!/bin/bash

# Ensure ZAP API is ready
echo "ZAP API is starting up..."
while ! curl -s http://localhost:8090 >/dev/null; do
  echo "Waiting for ZAP API to be ready..."
  sleep 2
done

# Spider the target
curl "http://localhost:8090/JSON/spider/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL"

# Wait for spider to complete
while [[ "$(curl -s http://localhost:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')" != "100" ]]; do
  echo "Spidering progress: $(curl -s http://localhost:8090/JSON/spider/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')%"
  sleep 5
done

# Active scan
curl "http://localhost:8090/JSON/ascan/action/scan/?apikey=$ZAP_API_KEY&url=$TARGET_URL&recurse=true"

# Wait for active scan to complete
while [[ "$(curl -s http://localhost:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')" != "100" ]]; do
  echo "Active scanning progress: $(curl -s http://localhost:8090/JSON/ascan/view/status/?apikey=$ZAP_API_KEY | jq -r '.status')%"
  sleep 10
done

# Generate HTML report
curl "http://localhost:8090/OTHER/core/other/htmlreport/?apikey=$ZAP_API_KEY" -o /zap/reports/zap_report.html

echo "Scan complete! Report saved to zap-reports/zap_report.html"
