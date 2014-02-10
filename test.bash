#!/bin/bash

jmeter="java -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar --nongui --propfile ./jmeter.properties"

${jmeter} --testfile ./JMX/gla_free.jmx --logfile ./log/results.xml

# Old MAC address: a4:4e:31:91:2b:e8
# ifconfig wlan0 hw ether de:ad:de:ad:be:ef
