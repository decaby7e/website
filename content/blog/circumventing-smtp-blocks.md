---
title: "Circumventing SMTP Blocking by ISP using Digital Ocean"
date: 2021-10-27
description: "ISP blocking port 25? Not anymore! (Only $5 a month!)"
categories: ["tech"]
tags: ["networking", "homelab"]
draft: false
layout: post
---

I want to setup a mail server. [Easy][1]! (some restrictions apply). However, my
silly ISP is blocking connections on port 25 (the port for SMTP), **incoming and
outgoing**. Harsh... Given that I don't want to contact them and go through the
trouble of trying to convince them to open it for special ol' me, I decided that
I would simply use my Digital Ocean droplet to route all traffic on port 25 for
my mail server.

The tricky part of all of this is that I don't want to simply forward all
traffic from my mail server through the droplet like some kind of heathen. I
want *only* SMTP traffic to be routed through this machine. Network bandwidth is
expensive and I'd rather not route the rest of the services running on the mail
server to New York and back! Talk about slow...

## Network Topology

My problematic network setup looks something like this:

`mail (mail server) <-> router <-> ISP`

The problem is that all traffic going out of the router to the ISP will be filtered:

`mail -(smtp.gmail.com:25)-> router -(smtp.gmail.com:25)-> ISP -(BLOCKED)->`

`client -(mail.ranvier.net:25)-> ISP -(BLOCKED)-> router`

Ideally, we would like something like this:

`mail -(smtp.gmail.com:25)-> router -(droplet:51820(smtp.gmail.com:25))-> ISP -(droplet:51820(smtp.gmail.com:25))-> droplet -(smtp.gmail.com:25)-> Digital Ocean`

Where outgoing connections to port 25 from mail are forwarded by my router to a
Digital Ocean droplet, which can then perform SNAT for mail and pass the
connection along to where it ought to go.

The same would work in reverse to allow connections to the mail server on port
25 but just using a simple DNAT rule on the droplet for that. I'll leave the
ugly text diagram as an exercise for the reader if they feel up to it.

## iptables Magic?

After some quick google searching, I found that other people had the [same
idea][2]. So just some copy pasting and we're good to go? Nah. First of all, I
wanted to understand what was going on here. Secondly, I tried copy pasting (
:^) ) and it didn't work because I have a somewhat different environment and the
rules in that Server Fault post weren't entirely applicable.

The following iptables rule accomplishes a part of what we want:

`router`

```sh
# Mark these packets so they can be routed through droplet
iptables -A PREROUTING -t mangle -s {mail server internal IP} -p tcp --dport 25 -j MARK --set-mark 0x1000
```

This marks all packets originating from `mail` destined for port 25 with
`0x1000`. This, by itself, doesn't do anything. However, we can make ip rules
that use this mark for routing decisions.

## ip rules

We first have to make the configuration for our alternate routing table:

`router`

```sh
# Add entry to routing tables
cat /etc/iproute2/rt_tables | grep -v '200 smtproute' > /etc/iproute2/rt_tables
echo '200 smtproute' >> /etc/iproute2/rt_tables
```

Then, we add routes and a rule for this table:

`router`

```sh
# Setup secondary routing table
ip route add default dev wg0 table smtproute
ip rule add fwmark 0x1000 table smtproute priority 32765
```

This will apply the routing table `smtproute` to any packet that is marked with
`0x1000` and send said traffic out on the wireguard interface that connects
`router` and `droplet`.

## SNAT and DNAT on droplet

We've gotten the traffic from the mail server to the router and now finally to
the droplet. But we need to make sure that the traffic is NAT'd b/c the IP of
the mail server is on an internal network:

`droplet`

```sh
# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1  # Can be made persistent by editing in /etc/sysctl.conf
# NAT for traffic outgoing on internet interface
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

For traffic going into the mail server, we use a DNAT rule:

`droplet`

```sh
# Traffic incoming on port 25 should be routed to the mail server
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 25 -j DNAT --to-destination {mail server internal IP}:25
```

## Conclusion

If you want a TL; DR, here are all of the rules that I used to get this working:

### Router Configuration

```sh
# Add entry to routing tables
cat /etc/iproute2/rt_tables | grep -v '200 smtproute' > /etc/iproute2/rt_tables
echo '200 smtproute' >> /etc/iproute2/rt_tables

# Setup secondary routing table
ip route add default dev wg0 table smtproute
ip rule add fwmark 0x1000 table smtproute priority 32765

# Mark SMTP packets for alternate routing
iptables -A PREROUTING -t mangle --source {mail server internal IP} -p tcp --dport 25 -j MARK --set-mark 0x1000
```

### Droplet Configuration

```sh
# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1  # Can be made persistent by editing in /etc/sysctl.conf
# NAT for traffic outgoing on internet interface
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Traffic incoming on port 25 should be routed to the mail server
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 25 -j DNAT --to-destination {mail server internal IP}:25
```

This [Netfilter Diagram][3] was also very helpful in seeing how iptables and ip
rules interact in the kernel, as well as seeing how all of the other chains and
tables interact with each other.

[1]: https://mailcow.email/
[2]: https://unix.stackexchange.com/questions/21093/output-traffic-on-different-interfaces-based-on-destination-port
[3]: https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg

## 2024 Update - OpenWRT Deprecation of `iptables`

Updated in OpenWRT deprecated the use of `iptables`! This was unfortunate, but the following nf_tables commands work as a replacement:

```sh
nft delete table raw 2>/dev/null
nft add table raw
nft add chain raw prerouting {type filter hook prerouting priority -300\;}
nft add rule raw prerouting ip saddr 192.168.1.10 tcp dport 25 meta mark set 0x1000
```
