#!/bin/bash

jmeter="java -jar ./bin/apache-jmeter-2.11/bin/ApacheJMeter.jar --nongui --propfile ./jmeter.properties"

${jmeter} --testfile ./JMX/gla_free.jmx --logfile ./log.txt
