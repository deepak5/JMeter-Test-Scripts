#!/bin/bash

# Usage:
# ./run_tests.bash <NASID> <captive_portal_domain>

# Will run through all forms of payment
# and print results to stdout.

# FIXME:
# generate MAC addresses
# switch networks

# Networks:
#
# NASID          Staging SSID
# "GLAAIR01"     "!Staging_GLA"
# "AIRLHRPUBT2"  "!Staging_LHR"

./run_test.bash $1 $2 0A:1B:2C:3D:4E:4D free
./run_test.bash $1 $2 0A:1B:2C:3D:4E:4D card
./run_test.bash $1 $2 0A:1B:2C:3D:4E:4D paypal
./run_test.bash $1 $2 0A:1B:2C:3D:4E:4D roaming
