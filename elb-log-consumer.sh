# ELB Logs Consumer
# Russ Thompson 2016
# Updated:  June 2018.
# Requires: s3cmd

# Check interval, how often to pause in between checks
CHECK_INTERVAL="30"

# Define temporary file, temporary results are stored here to avoid duplicates.
TEMP_FILE="/tmp/elb-tmp"

# Define output file where the ingestible json is sent to.
OUT_FILE="/var/log/ingested-elb-logs.log"

# Define the bucket where cloudtrail logs are beint sent to.
S3_BUCKET_NAME="my-loadbalancer-logs"

# Define the numerical number that resepresents your AWS account.
AWS_ACCOUNT_NUMBER="44444444444444"

# Maximum number of bytes before removing the top half of lines. (default:  200Mb).
FILE_MAX_BS="200000000"

# Check growth of file. When it exceeds the "FILE_MAX_BS", trim it in half by removing the oldest entries.
# Older entries should have already been ingested by logstash.
function check_file_growth {
  # Cut the file in half if large
  if [ "$(du -b $OUT_FILE | awk '{print $1}')" -gt "$FILE_MAX_BS" ] ; then
    CURRENT_LENGTH="$(wc -l $OUT_FILE | awk '{print $1}')"
    DESIRED_LENGTH="$(($CURRENT_LENGTH / 2))"
    nice -n 0 sed -i '1,'$DESIRED_LENGTH'd' $OUT_FILE
    sleep 1
  fi
  # The remporary file should remain small as proccessed entries to get placed in the "OUT_FILE"
  if [ "$(wc -l $TEMP_FILE | awk '{print $1}')" -gt "1000" ] ; then
    nice -n 0 sed -i '1,200d' $TEMP_FILE
    sleep 1
  fi
}

# Log Function
function log_it {
  echo " $(date): $1" >> $LOG_FILE
}

# Change the date on occasion
function reset_date {
  CURRENT_DATE="$(date +%Y/%m/%d/)"
}

# Set the current date
reset_date

# Loop through all the regions.
while true ; do
  for THE_PATH in `s3cmd ls s3://$S3_BUCKET_NAME/ | awk '{print $2}'` ; do
    for THE_REGION in `s3cmd ls "$THE_PATH"AWSLogs/$AWS_ACCOUNT_NUMBER/elasticloadbalancing/ | awk '{print $2}' | xargs -I{} basename {}` ; do
    THE_FILE_LIST=`s3cmd ls "$THE_PATH"AWSLogs/$AWS_ACCOUNT_NUMBER/elasticloadbalancing/$THE_REGION/$CURRENT_DATE | tail -1 | awk '{print $4}'`
    if [ -n "$THE_FILE_LIST" ] ; then
      # If the file exists in our temp file, we already downloaded it.
      if ! grep $THE_FILE_LIST $TEMP_FILE ; then
        echo $THE_FILE_LIST >> $TEMP_FILE
        s3cmd get $THE_FILE_LIST
        FILE_NAME="${THE_FILE_LIST##*/}"
        # Should the extension end in ".gz" it's an ALB style log.
        if [[ $FILE_NAME == *.gz ]] ; then
          nice -n 19 zcat $FILE_NAME >> $OUT_FILE
          rm -f $FILE_NAME
        else
          nice -n 19 cat $FILE_NAME >> $OUT_FILE
          rm -f $FILE_NAME
        fi
      fi
    fi
    sleep 2
    done
  done
  check_file_growth
  reset_date
  sleep $CHECK_INTERVAL
done
