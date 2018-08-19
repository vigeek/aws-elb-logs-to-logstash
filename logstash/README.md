## Logstash Configuration Files
Included is a simple Logstash configuration file that includes the input, filter and output definitions.

#### Changes required
- Open file `aws-loadbalancer-logs.conf` in an editor.
- Modify the `output` section and set the host address to your ElasticSearch server.

###### Optional changes
If you made no changes to the ingestion script itself, you should be all set.  The following settings are optional and should only be tweaked as needed.

- Modify the `input` section if you changed the `OUT_FILE` variable in the script.
- Modify the `filters` section if you need any custom parsing.
