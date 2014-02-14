#!/bin/bash

# Usage:
# ./run_test.bash <NASID> <mac_address> <payment_method>

# Will print results to stdout.

java \
  -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar \
  --propfile ./jmeter.properties \
  --addprop ./sites/${1}.properties \
  --jmeterproperty mac_address=${2} \
  --jmeterproperty payment_method=${3} \
  --testfile ./test.jmx \
  --logfile /dev/stdout
