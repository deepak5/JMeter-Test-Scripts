#!/bin/bash

# Usage:
# ./run_test.bash <NASID> <captive_portal_domain> <mac_address> <payment_method>

# Will print results to stdout.

java \
  -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar \
  --nongui \
  --propfile ./jmeter.properties \
  --addprop ./sites/${1}.properties \
  --jmeterproperty captive_portal.domain=${2} \
  --jmeterproperty mac_address=${3} \
  --jmeterproperty payment_method=${4} \
  --testfile ./test.jmx \
  --logfile /dev/stdout
