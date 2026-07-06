#!/bin/bash

BUCKET_NAME="cafe-web-access-logs"

HOSTNAME=$(hostname)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Upload logs to S3
aws s3 cp /var/log/httpd/access_log \
s3://$BUCKET_NAME/$HOSTNAME/access_log-$TIMESTAMP.log

aws s3 cp /var/log/httpd/error_log \
s3://$BUCKET_NAME/$HOSTNAME/error_log-$TIMESTAMP.log

# Clear log files
cat /dev/null > /var/log/httpd/access_log
cat /dev/null > /var/log/httpd/error_log

echo "Logs uploaded successfully for $HOSTNAME."
