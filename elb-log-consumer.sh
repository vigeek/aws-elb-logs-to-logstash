# ELB Logs Consumer
# Russ Thompson 2016.
# Requires: s3cmd

# Check interval, how often to pause in between checks
CHECK_INTERVAL="30"

# Define temporary file, temporary results are stored here to avoid duplicates.
TEMP_FILE="/tmp/elb-tmp"

# Define output file where the ingestible json is sent to.
OUT_FILE="/var/log/ingested-elb-logs.log"

# Define the bucket where cloudtrail logs are beint sent to.
S3_BUCKET_NAME="ck-loadbalancer-logs"

# Define the numerical number that resepresents your AWS account.
AWS_ACCOUNT_NUMBER="44444444444444"


# Check growth of file. 
# Rather than rotate, just keep them relatively small.
function check_file_growth {
  if [ "$(wc -l $TEMP_FILE | awk '{print $1}')" -gt "350" ] ; then
    sed -i '1,100d' $TEMP_FILE
  fi
  if [ "$(wc -l $OUT_FILE | awk '{print $1}')" -gt "5000" ] ; then
    sed -i '1,1000d' $OUT_FILE
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
