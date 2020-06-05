---
title: "Wireguard Quickstart"
date: 2020-05-28T23:47:53-04:00
draft: false
tags: ['wireguard', 'tutorial']
---

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

All configuration for Wireguard lives in `/etc/wireguard`. Every configuration file in this directory represents a Wireguard interface, which may contain one or more *tunnels* between network peers.

## General Configuration

No matter what setup you choose to implement, there are a few common variables between all approaches.

1. Generate private and public keys on your **client and server** machine

```bash
cd /etc/wireguard/
wg genkey | tee privatekey | wg pubkey > publickey
```

## Traditional Catch-All VPN

{{< image src="/img/wireguard-quickstart-trad.svg" >}}

This setup is akin to what you would see with a traditional VPN service from someone like NordVPN or Private Internet Access. You might also do something like this with OpenVPN by yourself. The idea is that all of your traffic from whatever device your on is proxied to another device that will route it on your behalf. This is a key step in keeping your internet traffic private.

1. On the client, add a peer to your interface that routes all IPs (`0.0.0.0/0`)

`/etc/wireguard/wg0.conf` with permissions `600`

```ini
[Interface]
PrivateKey=<PRIVATE KEY>
Address=192.168.30.10/32
ListenPort=51820

[Peer]
PublicKey=<SERVERS PUBLIC KEY>
AllowedIPs=0.0.0.0/0
Endpoint=<SERVER IP>:51820
```

## Connecting to a Private Network (e.g. Home or work)

{{< image src="/img/wireguard-quickstart-priv.svg" alt="image is taking a break" >}}

If you would like to access a private network (e.g. your home so you can access a NAS or computers that you would like to keep private) from a remote location, Wireguard can also be of use!

1. On the client, add a peer to your interface that routes only the IPs of the remote network (`10.5.0.0/24`)

`/etc/wireguard/wg0.conf` with permissions `600`

```ini
[Interface]
PrivateKey=<PRIVATE KEY>
Address=192.168.30.10/32
ListenPort=51820

[Peer]
PublicKey=<SERVERS PUBLIC KEY>
AllowedIPs=10.5.0.0/24
Endpoint=<SERVER IP>:51820
```

This configuration is identical to the last, but we instead only route the IPs we want rather than absolutely everything.

## Commands to Know

Check status of tunnel(s) ~~~~~~~~~~ `wg`

Bring up a tunnel ~~~~~~~~~~~~~~~~~~ `wg-quick up TUNNEL_NAME`

Bring down a tunnel ~~~~~~~~~~~~~~~~ `wg-quick down TUNNEL_NAME`

Automatically start a tunnel ~~~~~~~ `systemctl enable wg-quick@TUNNEL_NAME`

## References

[Official Installation Instructions](https://www.wireguard.com/install/)

[(Un)Official Wireguard Documentation](https://docs.sweeting.me/s/wireguard)
