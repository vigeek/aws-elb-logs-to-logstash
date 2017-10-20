# aws-elb-logs-to-logstash
Consumes AWS ELB (Elastic Load Balancer), NLB (Network Load Balancer), ALB (Application Load Balancer) logs from S3 and sends them to logstash for ingestion.  The logs are formatted through a LogStash filter. 

# Requires
s3cmd -and- jq

# Configuration

1. Edit the script and update variable 'AWS_ACCOUNT_NUMBER' with your account number.
2. Edit the script and update variable 'S3_BUCKET_NAME' with your buckets name.
3. Ensure your AWS credentials are configured (e.g:  ~/.aws/credentials)
4. Execute the script (it will run in a constant loop)

# Ingesting CloudTrail logs
See here:  https://github.com/vigeek/aws-cloudtrail-to-logstash

# Example Dashboard (included)
![alt tag](https://github.com/vigeek/aws-elb-logs-to-logstash/blob/master/kibana-dashboard/elb-kibana-dashboard.png)

*Some minor details from the dashboard image are obfuscated.*
