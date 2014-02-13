README
======

This project provides a test suite and and ad hoc specification for the
captive portal login and payment processes. This test suite is implemented
using JMeter as an HTTP client. It only does correctness testing; no
performance testing is involved.

This test suite is intended to run on:

* developers' machines, for developers to test changes in their development
  environment
* a CI server, for testing of committed changes
* Android devices, for continuous on-site testing


## Requirements

* Bash shell
* Java
* JMeter 2.10+ (included in `./bin/`)
* A WiFi-enabled device


## Usage


### Basic usage

Connect to the WiFi network you wish to test.

From this directory, run:

    ./run_test.bash <NASID> <captive_portal_domain> <mac_address> <payment_method>

where

* `NASID` is a filename from the `./sites/` directory, stripped of its file
  extension
* `captive_portal_domain` is probably either `staging.wifiservice.net` or a
  live server
* `mac_address` is your current MAC address. You should be able to spoof this
  address for easier repetitive testing.
* `payment_method` is either `free`, `card`, `paypal`, or `roaming`.

You will receive an XML report on stdout, with a summary at the end of this report.


### Testing all payment methods for a site

FIXME: this is not implemented; it needs to spoof MAC addresses!

Run

    ./run_tests.bash <NASID> <captive_portal_domain>

This will run `./run_test.bash` for each payment method.


### Testing all payment methods for all sites

FIXME: this is not implemented; it needs to switch networks!

Run `./test.bash` in this directory.

This will run through each site, and for each, switch to the appropriate
network and then run `./run_tests.bash` for that site.


## Development notes

Do **NOT** set the HTTP implementation to HttpClient4; it is broken! All
documentation refers to HttpClient3.1, with which it is NOT backwards-
compatible. You'll have to trust me on this; you won't find this written
anywhere.


### Adding a new site

You should just have to create a new file in `./sites/`, following the format
of the files currently present. Name the file with the NASID of the site. You
can then test this site by following the usage notes above.
