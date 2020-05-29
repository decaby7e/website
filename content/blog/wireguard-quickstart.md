---
title: "Wireguard Quickstart"
date: 2020-05-28T23:47:53-04:00
draft: true
tags: ['wireguard', 'tutorial']
---

# Wireguard Quickstart Guide

I know! You are a very busy person and taking the time to read my wonderful and extensive tutorials isn't on your list of priorities :'( Fortunately, I understand and forgive you for this and this section will help you jump right into using Wireguard.

## Installing Wireguard

For Ubuntu >= 19.10, Wireguard comes built right in! Just install the utility scripts:

```bash
$ apt install wireguard
```

For older versions of Ubuntu:

```bash
$ sudo add-apt-repository ppa:wireguard/wireguard
$ sudo apt-get update
$ sudo apt-get install wireguard
```

If you'd like to see more installation options, check out [the offical website](https://www.wireguard.com/install/).

## Files to Know

```bash
$ tree /etc/wireguard/
/etc/wireguard/
└── wg0.conf

0 directories, 1 file
```

All configuration for Wireguard lives in `/etc/wireguard`. Every configuration file in this directory represents a Wireguard interface, which may be one or more *tunnels* between network peers.

## Traditional Catch-All VPN

{{< image src="/img/wireguard-quickstart-trad.svg" >}}

TODO

## Connecting to a Private Network (e.g. Home or work)

{{< image src="/img/wireguard-quickstart-priv.svg" alt="image is taking a break" >}}

TODO

## Commands to Know

Check status of tunnel(s) ~~~~~~~~~~ `wg`

Bring up a tunnel ~~~~~~~~~~~~~~~~~~ `wg-quick up TUNNEL_NAME`

Bring down a tunnel ~~~~~~~~~~~~~~~~ `wg-quick down TUNNEL_NAME`

Automatically start a tunnel ~~~~~~~ `systemctl enable wg-quick@TUNNEL_NAME`

## References

[Official Installation Instructions](https://www.wireguard.com/install/)
[(Un)Official Wireguard Documentation](https://docs.sweeting.me/s/wireguard)
