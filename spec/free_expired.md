Everything is HTTP/1.1

External page request:
  Request:
    GET http://www.bbc.co.uk/

  Response:
    HTTP 302
    Status: "Hotspot login required"
    Headers:
      Location: https://staging.wifiservice.net/?<QUERYPARAMS>
        where <QUERYPARAMS> are:
          Key           Value
          "aa[ac_url]"    "https://glair01.wifiservice.net/login"
          "aa[mac]"       Your MAC address, all caps, e.g. "A4:4E:31:91:2B:E8"
          "aa[nasid]"     "GLAAIR01"
          "aa[ssid]"      "Glasgow Airport"
          "aa[orig_url]"  The URL requested, e.g. "http://www.bbc.co.uk/"

