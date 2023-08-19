---
title: "Overview of Linux Encryption Solutions"
date: 2023-08-18
description: "A chain is only as strong as its weakest link"
tags: ["linux", "security", "research"]
---

Why encrypt? The better question, in my opinion, is why **not** encrypt? With
hardware acceleration for
[AES](https://en.wikipedia.org/wiki/AES_instruction_set) being an almost
universal feature in modern CPUs, the performance impact of encryption is
basically nill and the security benefits are massive. Encryption ensures that,
even in the case where an attacker has access to your data, they are not able to
do anything useful with it unless they have your encryption keys. Depending on
how they get access to this data and in what form the data is in, the usefulness
of encryption varies. If the attacker gains live-access to a system, its pretty
much game over if your encrypted data is unlocked and accessible at the time of
their access. This is why the *kind* of encryption you choose and *how you use
it* is critically important in any setup.

A few of my main motivations for encrypting my data are:

- To protect data in the case of an offline attack (e.g. my computer SSD gets
  stolen)

- To protect data in the case of an online attack (e.g. a server is hacked and
  my backups for other machines are stored there)

- To make systems that are insecure by design secure (e.g. using Stunnel or
  FS-level encryption with NFS (more about this later))

I would like to go over the different encryption options that are available on
Linux in this post. I will not be giving tutorials on how to set any of these
up, as there are plenty of great tutorials out there on that already. Rather I
want to list out the reasons you may want to go with one option or the other
depending on the use-case you have in mind. Having a place to start really helps
with... well, starting.

## Levels of Encryption

There are a multitude of levels at which you can encrypt data. Typically, the
lower you go, the more data will be secured and the more performant IO will be.
Going higher up the software stack grants more granularity and is potentially
less complex but at the cost of some performance and a possible risk of
accidentally exposing sensitive information.

### Block-Level Encryption

At the lowest unit of storage, just above the partition table on a traditional
GPT disk, we can encrypt at the block-level. This guarantees that all data IO on
a given partition will not be exposed if someone were to gain physical access to
the drive, assuming they do not have the encryption keys and a strong password
or key was used to prevent brute-force attacks. Unencrypted data never touches
the drive, as all IO operations are done through a mapping layer that encrypts
them as blocks are written. The most popular option by far in Linux to
accomplish this is
[LUKS](https://wiki.archlinux.org/title/Data-at-rest_encryption#Block_device_encryption)
, though other options do exist. A drawback of using LUKS is that **all** disk
IO must be encrypted when being written and must be decrypted when being read,
which can be a small but significant hit if you have large bandwidth workflows.
This is where filesystem-level encryption may come in handy.

### File-Level Encryption

Rather than encrypt all blocks on a partition, we can instead leave the system
in the clear and secure parts of it. This is similar to what you do when you use
a password manager on your machine. Instead of encrypting the entire darn hard
disk drive and storing your passwords in an Excel spreadsheet (you know who you
are), most password managers offer you the luxury of encrypting your passwords
for you on the filesystem. We can extend this model to any kind of file.

If you are looking for plain-ol file encryption tools, we've had that for ages!
[GnuPG](https://wiki.archlinux.org/title/GnuPG) is the old-fashioned approach.
[age](https://github.com/FiloSottile/age) is a newer and nicer tool for this
kind of thing. If you're looking for something a bit more automatic and
transparent, there are options!

### Filesystem-Level Encryption

[FUSE](https://wiki.archlinux.org/title/FUSE), or the Filesystem in USErspace
(clever acronym :p), provides an API for filesystems to be implemented in ...
I'll let you guess (ok fine, userspace). There are a few tools I found that take
advantage of this to provide an "overlay filesystem", which sets up a folder
that you can treat like a normal, unencrypted folder but when IO passes through
it, data is stored in an encrypted format somewhere else.
[gocryptfs](https://nuetzlich.net/gocryptfs/) is the most promising of these I
found, though [cryfs](https://www.cryfs.org/comparison) also came up as an
option.

What's nice about the FUSE based solutions is that the backing storage, where
the encrypted data is stored, can be copied around and moved with relative ease.
Good luck moving your 100GB `.img` file with your LUKS headers and blocks on it!
However, if you don't care as much about backend portability,
[fscrypt](https://github.com/google/fscrypt) (by Google! hope it wont be
canceled) takes advantage of Linux's built-in filesystem-level encryption
features. For example, if you have an EXT4 filesystem, this tool can be used to
make a single folder encrypted while the rest of the system remains unencrypted.
Pretty neat!

## Case Study: SSHFS v.s. NFSv3 + gocryptfs

This is a problem that I encountered in the real-world at my old workplace. Due
to constraints on the hardware we had available, we were stuck with a storage
server that only supported NFSv3 or SSHFS as viable storage options. NFSv4 has
awesome encryption options but did not work on this server and was darn
complicated to setup! (the nasty [3-headed
dog](https://en.wikipedia.org/wiki/Kerberos_(protocol)) warded us away with
success) NFSv3 does not support any form of encryption and thus would not be
acceptable without some kind of encryption placed on top. SSHFS supports
encryption, as it uses SSH as its communication layer, but was horribly buggy in
this server's implementation and would randomly stall during large reads and
writes.

This was when I came up with a disgusting but potentially workable idea: lets
use good'ol reliable NFSv3 BUT instead of serving a normal filesystem serve the
encrypted portion of a gocryptfs filesystem. Then, the client could run the
gocryptfs client on their machine and have data security! This unfortunately
would not get around the issues of UID/GID spoofing and MITM attacks that are
still possible but would at LEAST grant data confidentiality.

I never got around to implementing this, but I still believe it has some merit.
If anyone reads this post and has the *hutzpah* to try this out, please let me
know how it goes!

## Additional References

<https://wiki.archlinux.org/title/Data-at-rest_encryption>
<https://www.phoronix.com/scan.php?page=article&item=ext4-crypto-418&num=1>
<https://unix.stackexchange.com/questions/298004/share-the-encfs-encrypted-directory-via-nfs>
<https://github.com/rfjakob/gocryptfs/issues/156>
