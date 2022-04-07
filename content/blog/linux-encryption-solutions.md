---
title: "Overview of Encryption Solutions for Linux"
date: 2022-02-16T22:28:00-05:00
description: "Your chain is only as strong as its weakest link"
draft: true
tags: ["linux", "security", "research"]
---

INTRO

- block level
- fs level
  - fuse (arbitrary backing)
    - gocryptfs
    - encfs
    - cryfs
  - fscrypt (ext4 and some random ones)
    - fscrypt (the go tool from google)
- motivations
  - encrypt sensitive data to protect from online attacks
  - backups (same as reason above somewhat)
  - nfs security
- is sshfs faster than nfs+gocryptfs?

## References

- https://wiki.archlinux.org/title/Fscrypt#Encrypt_a_home_directory
- https://github.com/google/fscrypt#features
- https://wiki.archlinux.org/title/Data-at-rest_encryption
- https://nuetzlich.net/gocryptfs/
- https://www.cryfs.org/comparison
- https://www.phoronix.com/scan.php?page=article&item=ext4-crypto-418&num=1
- https://unix.stackexchange.com/questions/298004/share-the-encfs-encrypted-directory-via-nfs
- https://github.com/rfjakob/gocryptfs/issues/156
