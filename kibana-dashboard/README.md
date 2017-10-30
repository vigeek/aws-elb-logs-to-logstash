# Setup Information
In Kibana, go to settings, objects and then select import.

# Assumptions
This dashboard and visualizations assume your index name is: aws-logs-*

To switch the index naming to logstash-* run the following against the dashboard json files:
`sed -i 's/aws-logs-*/logstash-*/g' *.json`

# Partial screen shot
![alt tag](https://github.com/vigeek/aws-elb-logs-to-logstash/blob/master/kibana-dashboard/elb-kibana-dashboard.png)

*Some minor details from the dashboard image are obfuscated.*
