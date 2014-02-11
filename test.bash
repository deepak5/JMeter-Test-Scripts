#!/bin/bash

jmeter="java -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar --nongui --propfile ./jmeter.properties"
logfile=./log/results.xml

# Clear the log file
echo '' > ${logfile}

${jmeter} --addprop ./sites/GLAAIR01.properties --jmeterproperty mac_address=0A:1B:2C:3D:4E:4F --testfile ./JMX/gla_free.jmx --logfile ${logfile}

# Old MAC address: a4:4e:31:91:2b:e8
# ifconfig wlan0 hw ether de:ad:de:ad:be:ef
