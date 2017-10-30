#!/bin/bash
# Wrapper/init script for ELB/ALB consumer
# Russ Thompson 2016

# Standard pid location 
PID_FILE="/var/run/elb-consumer.pid"

# The name of the script
THE_PROG="elb-log-consumer.sh"

# The path where THE_PROG lives *EDIT THIS IF NOT DEFAULT*
THE_PATH="/opt/elb-consumer"

## END CHANGEABLE VARIABLES ##

# Change into the core path rregardless of argument (assume default)
cd $THE_PATH

function get_pid {
  THE_PID="$(ps aux | grep -v "grep" | grep $THE_PROG | awk '{print $2}' | head -n1)"
}

# Try and get the pid before all else
get_pid

# Start function
function start {
  if [ ! -z "$THE_PID" ] ; then
    echo -e "ERROR: $THE_PROG already running with PID:  $(cat $PID_FILE), stop first"
    exit 1
  else 
    screen -A -m -d -S elb-consumer bash $THE_PROG &
    sleep 3 ; get_pid
    if [ ! -z $THE_PID ] ; then
      echo $THE_PID > $PID_FILE
      echo "$THE_PROG is now running with PID:  $(cat $PID_FILE)"
    else
      echo -e "ERROR:  Unable to get running pid of $THE_PROG"
      exit
    fi
  fi
}

# Stop function
function stop {
  # Check that hte pid file exists
  if [ -f "$PID_FILE" ] ; then
    echo -e "Stopping monitor with PID:  $(cat $PID_FILE)"
    kill $(cat $PID_FILE)
    rm -f $PID_FILE
  else
    echo -e "ERROR:  no pid file existed."
    exit 1
  fi
}

if [ "$1" == "start" ] ; then
  start ; exit 0
elif [ "$1" == "stop" ] ; then
  stop ; exit 0
else
  echo -e "ERROR:  no/invalid argument passed, exiting"
  exit 1
fi
