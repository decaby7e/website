---
title: "Overview of Linux Encryption Solutions"
date: 2022-02-16T22:28:00-05:00
description: "Your chain is only as strong as its weakest link"
draft: true
tags: ["linux", "security", "research"]
---

Why encrypt? The better question, in my opinion, is why **not** encrypt? With
hardware acceleration for AES [1] being almost universal, the performance impact
of encryption is basically null and the security benefits are massive.
Encryption ensures that, even in the case where an attacker has access to your
data, they are not able to do anything useful with it unless they have your
encryption keys. Depending on how they get access to this data and in what form
the data is in, the usefulness of encryption varies. If the attacker gains
live-access to a system, its pretty much game over if your encrypted data is
unlocked and accessible at the time of their access. This is why the *kind* of
encryption you choose and *how you use it* is critically important in any setup.

A few of my main motivations for encrypting my data are:

- To protect data in the case of an offline attack (e.g. my computer SSD gets
  stolen)

- To protect data in the case of an online attack (e.g. a server is hacked and
  my backups for other machines are stored there)

- To make systems that are insecure by design secure (e.g. using Stunnel or
  FS-level encryption with NFS (more about this later))

## Block-Level Encryption

## Filesystem-Level Encryption

- fuse (arbitrary backing)
  - gocryptfs
  - encfs
  - cryfs
- fscrypt (ext4 and some random ones)
  - fscrypt (the go tool from google)

## File-Level Encryption

## Case Study: SSHFS v.s. NFS + gocryptfs

## References

1. https://en.wikipedia.org/wiki/AES_instruction_set

https://wiki.archlinux.org/title/Fscrypt#Encrypt_a_home_directory
https://github.com/google/fscrypt#features
https://wiki.archlinux.org/title/Data-at-rest_encryption
https://nuetzlich.net/gocryptfs/
https://www.cryfs.org/comparison
https://www.phoronix.com/scan.php?page=article&item=ext4-crypto-418&num=1
https://unix.stackexchange.com/questions/298004/share-the-encfs-encrypted-directory-via-nfs
https://github.com/rfjakob/gocryptfs/issues/156
