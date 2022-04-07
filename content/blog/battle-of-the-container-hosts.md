---
title: "Battle of the Container Hosts - Alpine + Docker Compose v.s. Rocky + Podman Compose"
date: 2022-02-10T01:33:00-05:00
description: "Which distro + container composition framework will win?"
draft: true
tags: ["docker", "linux", "containers", "devops", "research"]
---

## Motivation

I like minimalism. Docker is so nice! Podman is nice too but not as comfortable?
Relies on systemd / custom units for container persistence (ew?)? Rocky seems
nice but is more RHEL. Yuck... Alpine is super minimal and apk is FAST :)

Want the host to be like a hypervisor: has consistent and minimal tooling (IMMUTABLE BASE OS + ISO POSSIBLE?????!!!!)
Alpine is great for this. Rocky not so much??

## Specifications

Rocky Linux vX, podman + podman-compose vX.X

Alpine Linux v3.16, docker + docker-compose vX.X

## Testing

Speed for setup, runtime, etc.

Ease of deployment

Package support

etc. etc.

## Conclusions

Which is the best (objectively and subjectively)?
