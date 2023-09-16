---
title: "Alpine Linux and docker-compose make a great combo!"
date: 2022-02-10T01:33:00-05:00
description: "Skip the hypervisor for a slimmer solution"
draft: false
tags: ["linux", "devops", "containers", "docker"]
layout: post
---

I have toyed with Docker for about 4 years now and what I can say is that it has
made the process of deploying and maintaining software on my servers easier,
more secure, and much more portable. I stuck to Ubuntu for years but started to
grow tired with the constant push for snapd, lxc, netplan, etc. on my servers
when all I wanted to do was run a few services on Docker. This isn't to say that
these couldn't be useful tools, but I prefer for my OS to be a blank slate that
I build from the bottom up rather than "here have 2000 packages that you won't
use 90% of most of the time".

Anyone familiar with Docker has probably seen the name Alpine from time to time.
[Alpine Linux](https://alpinelinux.org/) is a minimal and secure Linux
distribution with its own package manager,
[apk](https://git.alpinelinux.org/apk-tools/), that is used frequently in Docker
images due to its small size and blazing fast package installation. A bit more
research showed that this distribution is good for a lot more than just
containers and seems to do rather well on bare metal. This seemed like a good
candidate for a base OS that I could run Docker on top of and keep as slim as
possible.

## My Current Setup

```sh
stem:~# neofetch 
       .hddddddddddddddddddddddh.          root@stem.lan 
      :dddddddddddddddddddddddddd:         ------------- 
     /dddddddddddddddddddddddddddd/        OS: Alpine Linux vX.XX x86_64 
    +dddddddddddddddddddddddddddddd+       Host: OptiPlex 9020 00 
  `sdddddddddddddddddddddddddddddddds`     Kernel: XXXXXXXXXX 
 `ydddddddddddd++hdddddddddddddddddddy`    Uptime: 12 hours, 17 mins 
.hddddddddddd+`  `+ddddh:-sdddddddddddh.   Packages: 261 (apk) 
hdddddddddd+`      `+y:    .sddddddddddh   Shell: ash 
ddddddddh+`   `//`   `.`     -sddddddddd   Terminal: /dev/pts/0 
ddddddh+`   `/hddh/`   `:s-    -sddddddd   CPU: Intel i5-4590 (4) @ 3.700GHz 
ddddh+`   `/+/dddddh/`   `+s-    -sddddd   Memory: 5700MiB / 7862MiB 
ddd+`   `/o` :dddddddh/`   `oy-    .yddd
hdddyo+ohddyosdddddddddho+oydddy++ohdddh                           
.hddddddddddddddddddddddddddddddddddddh.                           
 `yddddddddddddddddddddddddddddddddddy`
  `sdddddddddddddddddddddddddddddddds`
    +dddddddddddddddddddddddddddddd+
     /dddddddddddddddddddddddddddd/
      :dddddddddddddddddddddddddd:
       .hddddddddddddddddddddddh.
```

```sh
axon:~# neofetch
       .hddddddddddddddddddddddh.          root@axon.ranvier.net 
      :dddddddddddddddddddddddddd:         --------------------- 
     /dddddddddddddddddddddddddddd/        OS: Alpine Linux vX.XX x86_64 
    +dddddddddddddddddddddddddddddd+       Host: KVM/QEMU
  `sdddddddddddddddddddddddddddddddds`     Kernel: XXXXXXXXXX
 `ydddddddddddd++hdddddddddddddddddddy`    Uptime: 93 days, 5 hours, 1 min 
.hddddddddddd+`  `+ddddh:-sdddddddddddh.   Packages: 253 (apk) 
hdddddddddd+`      `+y:    .sddddddddddh   Shell: ash 
ddddddddh+`   `//`   `.`     -sddddddddd   Resolution: 1024x768 
ddddddh+`   `/hddh/`   `:s-    -sddddddd   Terminal: /dev/pts/0 
ddddh+`   `/+/dddddh/`   `+s-    -sddddd   CPU: AMD EPYC 7542 (1) @ 2.899GHz 
ddd+`   `/o` :dddddddh/`   `oy-    .yddd   Memory: 202MiB / 983MiB 
hdddyo+ohddyosdddddddddho+oydddy++ohdddh
.hddddddddddddddddddddddddddddddddddddh.                           
 `yddddddddddddddddddddddddddddddddddy`                            
  `sdddddddddddddddddddddddddddddddds`
    +dddddddddddddddddddddddddddddd+
     /dddddddddddddddddddddddddddd/
      :dddddddddddddddddddddddddd:
       .hddddddddddddddddddddddh.
```

These are my two main servers, and just look at that package count! Setting
these up consisted mainly of just installing Alpine on the machine, installing
docker and docker-compose, and then running my docker-compose.yaml files for
each of my services. I keep the services in their own self-contained folders, so
that migration is as simple as running `docker-compose down`, copying a folder
from one server to another, and then running `docker-compose up`. I tried this
out when I was migrating from Ubuntu to Alpine at first and it worked pretty
much flawlessly (with the exception of needing to make a few mount points on the
Alpine box for shared data).

So far, this has worked out great. `apk` is a blast to use compared to most
other package managers; its fast, simple, reliable, and has a huge package
repository to pick from. It uses a similar format (APKBUILD) to Arch (PKGBUILD),
which I might start to research for my own personal package management.
