#!/bin/bash

jmeter="java -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar --nongui --propfile ./jmeter.properties"
logfile=./log/results.xml

function run_test {
  # Clear the log file
  echo '' > ${logfile}

  ${jmeter} \
    --addprop ./sites/${1}.properties \
    --jmeterproperty captive_portal.domain=${2} \
    --jmeterproperty mac_address=${3} \
    --testfile ./JMX/${4}.jmx \
    --logfile ${logfile}
}

run_test "GLAAIR01" "staging.wifiservice.net" "0A:1B:2C:3D:4E:4D" "free"
