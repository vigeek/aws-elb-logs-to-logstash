# Configuration
The init script assumes you've installed the consumer to:  /opt/elb-consumer

Copy the init script [elb-consumer-init.sh] to:  /etc/init.d

Make init script executable:  chmod ug+x /etc/init.d/elb-consumer-init.sh

It should now be usable e.g:  /etc/init.d/elb-consumer-init.sh start|stop

The monit configuration can be dropped in your monit configuration folder, it simply uses the init script for control


