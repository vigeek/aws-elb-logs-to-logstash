# aws-elb-logs-to-logstash
Consumes AWS ELB (Elastic Load Balancer), NLB (Network Load Balancer), ALB (Application Load Balancer) logs from S3 and sends them to logstash for ingestion.  The logs are formatted through a LogStash filter. 

# Requires
s3cmd -and- jq

# Configuration

1. Edit the script and update variable 'AWS_ACCOUNT_NUMBER' with your account number.
2. Edit the script and update variable 'S3_BUCKET_NAME' with your buckets name.
3. If your bucket is nested (e.g: loadbalancer-logs/AWSLogs/service/AWSLogs) set S3_BUCKET_NAME to "loadbalancer-logs/AWSLogs"
4. Ensure your AWS credentials are configured (e.g:  ~/.aws/credentials)
5. Execute the script (it will run in a constant loop)

# Configuration extended.
Included is a traditional init script and monit config (optional), to use the init script...

1. Ensure 'elb-log-consumer.sh' is located here:  /opt/elb-consumer
2. Alternatively, edit 'elb-consumer-init.sh' and change variable 'THE_PATH'
3. Place the init script[elb-consumer-init.sh] in /etc/init.d
4. Make init script executable:  chmod ug+x elb-consumer-init.sh
5. It can then be started as such:  /etc/init.d/elb-consumer-init.sh start (or stop)
6. The included monit script can be placed in your monits configuration directory and used to control the ELB consumer.

# Ingesting CloudTrail logs
See here:  https://github.com/vigeek/aws-cloudtrail-to-logstash

# Example Dashboard (included)
![alt tag](https://github.com/vigeek/aws-elb-logs-to-logstash/blob/master/kibana-dashboard/elb-kibana-dashboard.png)

*Some minor details from the dashboard image are obfuscated.*
