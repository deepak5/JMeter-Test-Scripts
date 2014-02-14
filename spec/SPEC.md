# Hardware


## Hardware components

Arqiva WiFi's physical assets can be understood in terms of a small number of
primitive kinds of hardware, connected by wireless, wires and the internet:

* "WiFi devices", like laptops and phones, owned by customers
* "Access points", which provide a WiFi signal to WiFi-enabled devices
* "Switches", which connect access points together and perform multiplexing
* "Gateways", which provide selective network access
* "Routers", which connect networks to the internet via ADSL or fiber

Every device is globally, uniquely identified by an unforgeable "MAC address".
(This is not strictly true, but the architecture described in this document
relies on this assumption, so you should accept it as true for now.)


## Physical topology


### Physical locations

We can understand the network topology by breaking it down into separate
physical locations, where every location is connected to, and communicates
via, the internet.

There are a few basic kinds of location:

* sites, which are locations offering WiFi, such as hotels, airports, etc.
* server locations, which house one or more back-end servers owned or leased
  by Arqiva WiFi.
* {street WiFi -- TODO}
* external services provided by other organizations, such as PayPal

Sites are usually connected to the internet via one or more ADSL or fiber
lines.


### Sites

Each site has:

* many *devices*, such as phones and laptops, which are owned by customers at
  the site
* one or more access points, to which the devices are connected via WiFi.
  Access points are distributed over the site to provide signal. Access points
  which overlap in their range are set to different channels to avoid
  interference.
* one or more switches, to which the access points are connected via ethernet.
  The switches provide the access points with both data and power.
* a single gateway, to which the switches are connected via ethernet. The
  gateway is usually in a dedicated "comms room" at the site.
* one or more routers, to which the gateway is connected via ethernet, and
  which are connected to the Internet, usually via ADSL or fiber. The routers
  are also usually in the comms room.

Therefore, every request from a device that is routed via the internet goes
through:

* an access point, then
* a switch, then
* the gateway, then
* a router.


### Server locations


There are several server locations. Each server location potentially has a
different network topology, with multiple servers, databases, load balancers,
etc. Each location is self-contained and does not depend on other locations'
services.


#### WiFi Zone

This is a service that is physically located at Star, an ISP, and consists of
four servers:

* three application servers, known as "webboxes", and labelled "WEBBOX01"
  through "WEBBOX03"
* a database server, known as "DB01"

There is no load balancer, and each application server is directly accessible
via the internet. Each application server is directly connected to DB01.


#### Aptilo

There are five instances of this service. Each is self-contained and shares
nothing with any of the other instances.

Each Aptilo instance runs on Arqiva-owned hardware, somewhere at Arqiva (???).

Each instance runs on a single physical server with direct access to the
internet.


#### MAMA

TODO???


# Software

We can abstract over the physical details of the network and instead describe
it in terms of:

* software components, which do not necessarily have a one-to-one
  correspondence with physical components
* the interfaces that are implemented by each software component
* how the components are logically connected, at which "network layer"


## Software components

The "primitives" in this logical network are:

* customers' network interfaces
* sites' RADIUS clients (is this the proper name? Controllers? Captive
  portals? Logical gateways? "RADIUS server" I don't think captures the
  "captive" element of the process)
* Arqiva's RADIUS servers
* Arqiva's HTTP servers (better name? "Captive portal" servers?)
* external services on the internet

Each software component is hosted on, or implemented by, physical components:

* network interfaces are realized by *network interface cards* on customers'
  devices
* RADIUS clients are hosted on gateways
* Arqiva's RADIUS servers, HTTP servers, and relational databases are hosted
  on the physical servers at various server locations.

  Some physical servers host multiple software components (e.g. both a RADIUS
  server and an HTTP server), and some software components are hosted on
  multiple physical servers (e.g. some HTTP servers are stateless and so can
  have multiple instances, such as WEBBOX 01 to 03). The "software component"
  view ignores both of these details.


## Software topology

These software components are connected:

* each customers' network interface is connected to the sites' RADIUS client
  via IP
* Each sites' RADIUS client is connected to the internet, via IP
* Each sites' RADIUS client is connected to one Arqiva RADIUS server via the
  RADIUS protocol
* Each customer's device is connected to an Arqiva RADIUS server via HTTP
* Each Arqiva HTTP server is connected to an Arqiva RADIUS server via RADIUS
  (???)

This can be visualized as:


      Network    ∞          1  RADIUS  ∞          ∞  Internet
      Interface -------------- client -------------- servers
                     IP                     IP
      ∞ |                      ∞ |
        |                        |
        | HTTP                   | RADIUS
        |                        |
      1 |                      1 |

      HTTP    1             1  RADIUS
      server ----------------- server
                  RADIUS


                           DIAGRAM 1


There is one "commutative" constraint not captured here: for each customer,
they are indirectly connected to a *single* RADIUS server. That is, the RADIUS
client and the HTTP server that they are connected connected to are both
connected to the *same* RADIUS server.


# Payment process: the captive portal

Arqiva WiFi's business model is to charge customers for access to the
internet. There are many different payment plans and payment methods, such as
"free access for 30 minutes", "£4 for one hour", "pay via roaming partner",
and so on. From an engineering viewpoint, these differences are superficial,
so we ignore these details here, and describe the process for a generic
payment.

The payment process used by Arqiva WiFi, and many competitors, is called a
*captive portal*.


## Captive portal interface

For the customer, the "captive portal" process works like this:

1. Turn on device.
2. Connect to the WiFi network at the site you are visiting.
3. Open a web browser.
4. Visit any arbitrary URL, e.g. your home page.
5. Get forcibly redirected to another URL, at which is another page with a
   payment form.
6. Complete and submit the form. (Money is taken from your bank.)
7. Use the internet.


## Captive portal implementation

We describe the implementation by describing each edge in Diagram 1. The
correctness of the whole system follows immediately from the correctness of
each of these parts.

TODO: This description is specific to the WiFi Zone implementation, but both
the Aptilo and MAMA/CAR implementations should be similar.


### Network Interface ↔ RADIUS client

The key component at each site is the *RADIUS client*. Without the RADIUS
client, the network architecture at each site is basically the same as a home
network: devices connect to an access point and are given immediate unfettered
access to the internet. The role of the RADIUS client is to restrict this
access. Consult Diagram 1: the RADIUS client sits between the customer and the
internet, at the IP layer.

The customer's network interface sends IP packets to the RADIUS client. Every
packet identifies the sender by its MAC address. The RADIUS client's state
consists of a set of MAC addresses. When the RADIUS client receives a packet,
it tests the packet's sender's MAC address for membership in this set. Based
on this, it does one of two things:

* if the sender is in the set, then the packet is forwarded to its destination
  (probably on the internet).
* otherwise, the RADIUS client drops the packet, and replies with an HTTP
  redirect response, redirecting the sender to the HTTP server's payment form.

TODO: This section is speculative!!! How does this REALLY work? How does the
gateway detect HTTP traffic if it is connected at the IP layer? There's some
weird level-shifting going on here.


### Network interface ↔ HTTP server

The HTTP server exposes two HTTP resources:

* A resource accepting POST requests containing payment details
* A resource accepting GET requests which serves an HTML form for constructing
  payment POST requests

Only the first resource is interesting. When receiving payment details, the
HTTP server:

1. Verifies payment details with any external sources (e.g. credit card
   handler)
2. Assuming this is successful, posts a RADIUS packet to the RADIUS server,
   notifying it of

   * the sender's MAC address
   * how long this address should have access to the internet for
   * the site ID

3. Responds with an HTTP 200 OK


### HTTP server → RADIUS server

The RADIUS server accepts RADIUS packets from the HTTP server. Each packet
contains a MAC address, a length of time, and a site ID. When receiving such a
packet, the RADIUS server:

1. Stores the MAC address, length of time, and site ID
2. Sends a RADIUS packet to the RADIUS client identified by the site ID (TODO:
   how does this work), containing the MAC address in the packet


### RADIUS server → RADIUS client

The RADIUS client accepts RADIUS packets from the RADIUS server. Each packet
contains a MAC address. When receiving such a packet, the RADIUS client
inserts the MAC address into its set of MAC addresses.


### RADIUS client ↔ internet

TODO


# Worked example

We take the staging instance of the Glasgow Airport site as an example. This
is available from the office at One Park Lane as SSID `!Staging_GLA`. The
Glasgow Airport site is identified internally at Arqiva WiFi with the NASID
"GLAAIR01".


## DNS

When connecting to a network, some IP addresses are given to you, telling you
about local resources. In particular, in your connection details you will see

* The IP address of a gateway. This is the same gateway shown in the above
  diagram.
* IP addresses of one or two DNS servers.

The DNS server IP addresses will be the same as the gateway -- that is, the
client is recommended to use the gateway as its DNS server. (It doesn't have
to, though: you can manually change your DNS settings.)

The provided DNS server provides DNS for:

* the domain `glair01.wifiservice.net`. This resolves to the IP of the gateway
  itself. (Presumably, the subdomain name is supposed to be the NASID, but has
  a typo.)
* the domain `staging.wifiservice.net`. This resolves to the captive portal
  server. (Notice that the servers on subdomains of `wifiservice.net` are not
  on the same physical machine.)
* "external" domains on the internet. These resolve correctly for all domains:
  not only "whitelisted" domains like `www.paypal.com` and `arqivawifi.com`,
  but also non-whitelisted domains like `bbc.co.uk` and `google.com`.


## HTTP

The "captive portal" concept uses HTTP for its authentication and payment
processes. As an end-user, there are two key HTTP services you interact with.

One HTTP service runs on the gateway. We will call this the *gateway HTTP
service*. The gateway has state which records, per user, the:

* user name, e.g. `qeAgnWY0L4`
* IP address, e.g. `192.168.103.148`
* MAC address, e.g. `0A:1B:2C:3D:4E:0F`
* Information about the user's session. If the user has a session in progress,
  then it has a record of:

  * Time the user's session started;
  * Time the user's session is due to finish.

  Otherwise, it has a record of how much time the user has remaining on the
  session.

The gateway HTTP service exposes the following resources over non-
secure HTTP:

* `/status`. This accepts `GET` requests and provides information on the above
  client-specific state. Under some conditions, it returns a 302 to the
  captive portal HTTP service. (TODO)

* `/login`. This accepts `GET` requests (!) in two forms:

  * containing the query fields `username` and `password` (both strings), and
    `dst`, a URL. It does some stuff (TODO) and the response contains a cookie
    `loginID` and redirects to the `dst` URL.

  * containing your `loginID` cookie. This logs you back in.

* `/logout`.
* ...

Another HTTP service runs on the captive portal server. We will call this the
*captive portal HTTP service*. It exposes the following resources over secure
HTTP (`https`):

* `/`
* `/product/free`
* `/product/billing`
* `/product/payment`
* `/product/roaming`
* ...


## Payment process

The "free X minutes" process works like this:

* Browser makes request for a non-whitelist site, like `http://www.bbc.co.uk/`.
* The request is intercepted by the gateway, which

  * responds with an HTTP 302 response
  * redirecting the client to the `/` resource on the captive portal HTTP service
  * passing along some details in the `GET` string about the device and the site

* The browser follows the redirect to the captive portal HTTP service, which
  responds with a splash screen presenting payment options.
* The user chooses the "free" option: they direct the browser to
  `/product/free`, which responds with an HTML form to complete, including
  details about the customer.
* The user submits the form to `/product/free`. The response redirects the
  user to `/`.
* The browser requests `/` on the captive portal HTTP service, which

  * redirects to `/login` on the gateway HTTP service
  * passing along some details in the `GET` string:

    * a `username` and `password`, which are are machine-generated (TODO)
    * the `dst` URL set to the `/` resource on the captive portal, so it will
      redirect back again

* The browser requests `/login` on the gateway HTTP service with the
  credentials provided by the captive portal. The gateway marks this user as
  logged in, and redirects the user back to `dst`, which was set to `/` on the
  captive portal.
* The browser requests `/` on the captive portal, which serves an HTML page
  welcoming the user and telling them how much time they have remaining.


# TODO

DNS restrictions on domains

How does the MAC address on the RADIUS client get invalidated after they no
longer have access?

MAC address forgery!

Client details (username/password)


# Glossary

NIC.
  Network Interface Controller.
  A network card in a PC etc.

MAC address.
  Media Access Control address.
  Globally unique identifier for all NICs in the world ever.

RAS
  Remote Access Service.
  Fuck knows; something to do with remote desktop.

NAS.
  Network Access Server.
  A kind of Gateway.
  Controls access by client machines to other services.

  Identified by a NAS ID.

Accounting.
  The tracking of network resource consumption by users for the
  purpose of capacity and trend analysis, cost allocation, billing.

AAA
  Authentication, Authorization, Accounting.

RADIUS
  Remote Access Dial In User Service.
  A protocol providing AAA.
  A client/server protocol.
  An application-layer protocol.
  Runs on UDP as transport layer.
  The RADIUS server is usually a background process running on a UNIX or Microsoft Windows server.
  Clients: RAS, NAS


Network switch.
  A physical device that connects many devices together on a computer network.
  Data link layer.

Gateway.
  Like a switch but bigger???

Walled garden.

Captive portal.
  A technique that forces an HTTP client on a network to see a
  special web page for authentication purposes before using the
  Internet normally. A captive portal turns a Web browser into an
  authentication device.

  This is done by intercepting all packets, regardless of address or port,
  until the user opens a browser and tries to access the web.

Winbox
  Some software to manage MikroTik routers

Hotspot
  ???
  Something to do with HP controllers
  Something I can access using Winbox

NOC
  Network Operations Center.
  Some humans in a room.

NOC authentication.
  Something to do with a NOC. ???


Cisco CAR
  Cisco Unified Communications Manager CDR Analysis and Reporting (CAR)
  An AAA server ???
  A RADIUS server???
  Also does Accounting
  "a tool that is used to create user, system, device, and billing reports."
  Interfaces with:
    ACS
    MAMA

NAC (1)
  "Network Access Control"


NAC (2)
  "Network Admission Control"
  Cisco's version of Network Access Control

AP
  "Access Point"

Service Controller
  The same as a NAS???

Wireless Controller
  A kind of Service Controller???

MSC
  A Service Controller???

Colubris
  Colubris Networks, a company acquired by HP

HP MSM 3x3
  A "Wireless Controller"

ACS
  "Access Control Server"
  "a component of Cisco's Network Admission Control technology"
  A DHCP server?
  An HTTP server
  Interfaces with:
    Client/device
    MAMA
    CAR

VSA
  "Vendor-Specific Attributes"


MAMA
  Data backend to RADIUS server, including:
    user accounts
      username+password
    accounting
  "Hotspot" users?
  Serves captive portal HTTP stuff.

  It appears MAMA is two things:

    The web server that hosts landing pages, using the service controller as
    an authentication backend.

    The RADIUS server's authentication backend. (Insanely, the RADIUS server
    is *itself* the authentication backend of the service controller.)
