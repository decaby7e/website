---
title: "{U,G}IDs and Docker"
date: 2022-05-31
description: "Why identity in the container matters outside the container"
tags: ["linux", "docker", "infosec"]
draft: false
layout: post
---

If you've ever used Docker before (or any Linux-based containerization for that
matter), you may be familiar with the mess it can leave on your filesystem. You
start up your web server or database container and soon enough you have weird
users like `systemd-timesync` owning your files. That can't be right though: you
were just running a web server! I'm going to delve into this topic for people
who may be unfamiliar with Linux identity services and how containers interact
with this model on the host machine, leading to unexpected (and potentially
dangerous!) side-effects.

## Linux Identity Overview

In Linux, access control is done primarily through two constructs: users
(identified with their UID) and groups (identified through their GID). When
accessing a file, the system checks if the effective UID matches the owner of
the file. If it does, it allows access and modification to the file according to
some permissions (read, write, and execute). If their UID does not match the
owner of the file but they are a part of the group that owns the file, it will
match the permissions set for the group of that file. Otherwise, a default
permission set for all other users is applied.

In practice, this gives the following view of a file in a Linux filesystem:

```sh
decaby7e@envy > ls -al
total 56
drwxr-xr-x  9 decaby7e decaby7e 4096 Apr  6 15:42 .
drwxr-xr-x  7 decaby7e decaby7e 4096 Mar 18 17:53 ..
drwxr-xr-x  2 decaby7e decaby7e 4096 Aug  8  2021 archetypes
-rw-r--r--  1 decaby7e decaby7e   77 Aug  8  2021 config.toml
drwxr-xr-x  3 decaby7e decaby7e 4096 May 11 10:15 content
-rwxr-xr-x  1 decaby7e decaby7e  186 Apr  6 15:41 deploy.sh
drwxr-xr-x  8 decaby7e decaby7e 4096 May 31 23:16 .git
-rw-r--r--  1 decaby7e decaby7e   35 Mar 10 08:29 .gitignore
-rw-r--r--  1 decaby7e decaby7e    0 Mar 10 08:28 .hugo_build.lock
drwxr-xr-x  6 decaby7e decaby7e 4096 Nov  5  2021 layouts
drwxr-xr-x 11 decaby7e decaby7e 4096 Apr  6 15:42 public
-rw-r--r--  1 decaby7e decaby7e  262 Aug  8  2021 README.md
drwxr-xr-x  3 decaby7e decaby7e 4096 Aug  8  2021 resources
drwxr-xr-x  6 decaby7e decaby7e 4096 Mar 10 08:27 static
-rw-r--r--  1 decaby7e decaby7e  419 Aug  8  2021 TODO.md
```

The column of characters on the left shows the owner, group, and other
permissions as a list of characters, with each empty space representing the lack
of that type of permission and the presence of a character representing the
possession of that permission.

My username and group (decaby7e) is displayed as the primary user and group
owner respectively of these files. However, the system actually uses the UID and
GID to store this information, and thus it is possible for these names to change
without the owner and group of the file changing. In my case, my UID/GID is
1000/1000.

## What does the container see?

One of the ways that Docker isolates containers from the host machine is through
the use of **kernel namespaces**. Some of these namespaces, that are not enabled
by default, are the user and group namespaces. Thus, when you run `ls` in a
container on a directory that has been bind-mounted into that container, you
will see the same exact owners as a user on the host would see. Additionally,
when you run as a UID (which defaults to the root UID of 0) in a container, the
side-effects you leave on the filesystem in the container are the same as the
ones you would leave on the host (e.g. owning a file in a container as root will
leave a corresponding change of the file's owner on the host. This is because
they are the same file and the bind-mount does not do any remapping of UIDs from
users running in the container).

## Why is this a problem?

1. Certain vulnerabilites (e.g. CVE-2019-5736) are able to take advantage of the
   lack of isolation that is left from not using seperate UID namespaces to
   achieve privilage escalation on the host machine from compromised containers.

2. Additionally, if your filesystem is not secured properly, it can lead to
   inadvertent data leakage on the host machine from container users changing
   file ownership in unpredictable ways (a container user changes the ownership
   of a file that allows a system user on the host machine to access files it
   otherwise shouldn't be able to).

## Solution: User Namespaces

The solution is to use user namespaces. It used to be the case (2020 and before)
that this was not widely supported and even to date lots of people using Docker
are still using privileged containers. However, tools like Podman allow you to
[run rootless
containers](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
and I believe Kubernetes also allows this.

## Takeaways

I learned some valuable lessons about ownership and user permissions from
researching this topic:

- File permissions should be thought of not only as a property of the
  file-system but also a discrete and verifiable step in the entire
  configuration of the system.

- Moving files from one machine to another will almost always require a complete
  update of the ownership of the files involved in said migration.

- Ownership of files should be reapplied as much as possible, ideally by the
  container modifying said files and in an automated fashion.

- UID/GID mappings on the host are important for portability. If a container is
  moved from one host to another, this configuration should be transfered along
  with container configuration and application state data.
