---
title: "Painless and Automated Backups"
date: 2023-09-16
categories: ["tech"]
tags: ["homelab"]
draft: false
layout: post
---

The times I've needed backups the most were when I didn't have them. I finally
got fed up with data loss and went all in on a self-hosted, automated,
redundant, and secure backup solution for all my personal devices.

## Data Sources

In my personal arsenal, I've got:

- 1 desktop computer
- 1 laptop
- 2 servers
- 1 phone

Each of these has their own set of data that I'd like to be able to recover in
the case of any data loss. For example, all the computers have system
configuration (e.g. `/etc/`, `/home/username/.config`) that would really be a
pain to have to reconstruct from scratch. I'm a big fan for reproducible systems
and so ideally this configuration could be version controlled and deployed with
something like Nix or Ansible. Alas, I don't really find it practical at the
time to make changes, track those changes in a configuration management tool
like the ones mentioned, apply those changes again to see if it worked, etc. So
just backing those files up and picking through them manually to prune
old/unused files will suffice for now.

I also have user files on all of my personal devices (desktop, laptop, and
phone). This includes things like photos I take on my phone, notes, code
repositories, etc. In addition to the local files, I have a special folder on
all these devices labeled `sync` that contains files I'd like to share between
them all, like some documents, pictures, and notes. This folder is continuously
synced between all these devices with [Syncthing](https://syncthing.net/). I've
been using this system for years now and it has rarely failed me.

## Requirements for A Backup System

In the past, I've taken backups manually before doing risky operations like
reinstalling an OS or migrating from the cloud to a local NAS. This doesn't
really cut it for the long term, as I'd like to have backups happen across all
devices daily and without the need for intervention. Thankfully, I have a server
with my main storage pool of 2TB on it that can be exposed to all devices. The
next issue was how do I grant access to this device from each device?

### Isolating Client Access to Server

If there were only one machine backing up to one server, I'd simply grant that
machine SSH access to the server, restrict access to the SSH account's home
directory, and call it a day. The issue with this is that the server I host my
storage on also runs lots of other services and I'd prefer to not grant all the
machines in my network direct access to the machine, with only Linux user
accounts isolating them.

The next best step is a Docker container with OpenSSH installed. I can then
mount the backup directory to this container with a bind mount and add SSH keys
from each client to the container. To make this a bit easier, I created a shell
script that parses this YAML file:

```yaml
sources:
  HOSTNAME:
    uid: 100
    key: 'ssh-ed25519 ...'
  ...
```

This way, each machine will have the same UID on every creation of the container
and their SSH keys will automagically be installed to the user account in the
container. In a more paranoid world, I might even consider granting each machine
its own container for further isolation, but this seems strong enough. In the
home directory of the container, each machine has access to only its backup
directory.

![Diagram that represents the system detailed above](/img/containerized-backup-server.svg)

### Restic for Snapshots and Encryption

Now that I can get the data from the machines to the container, the next step
was to implement some kind of snapshot system and encryption-at-rest. Though the
storage volume the backups are stored on is encrypted, when the system is
running it isn't. Having an additional layer of encryption also means I don't
have to worry what medium I happen to be using for my backups.

[Restic](https://restic.net/) came up in my search as the most comprehensive,
polished, and easy to use solution that satisfies all of the requirements listed
above. I installed it on all my servers and workstations and created some
scripts for specifying when to run backup jobs, what files to ignore, and how to
prune old snapshots. Good ol' cron came in handy for the scheduling.

Restic also provides a [great guide on how to run it without
root](https://restic.readthedocs.io/en/stable/080_examples.html#backing-up-your-system-without-running-restic-as-root)
which I took advantage of. I also created a user account called `restic` on each
machine and installed the binaries, scripts, and secrets in that home directory.
I could easily see this being automated with Ansible to be scaled to a larger
organization. Clients could queue up to a larger server and wait their turn to
avoid overloading the server all at once.

### What About my Phone?

The last piece of the puzzle was my phone! I was bummed that I couldn't run
restic on the phone directly. But I came up with a nice solution that came with
some pleasant side effects too.

I setup Syncthing on my phone to synchronize **all** files to a folder on my
NAS. I set a `.stignore` file to ignore folders like `Android/` which I don't
really care to backup. I then added backup and pruning scripts on my server
under its own `restic` user that backups the phone files. In addition to this, I
created a folder for my pictures and videos to be backed up to. A `rsync` script
runs every minute (Syncthing could probably work here too, but `rsync`+`cron` is
nice and simple) and does a one-way sync from the phone's main Syncthing folder
to the phone media folder. This means that I can delete anything I want from the
phone's media folders and so long as the script has picked those files up it
will still exist in the server's media folder for the phone. The files aren't
deleted from the server because I'm not running `rsync --delete` (that argument
is usually muscle memory for me). Farewell Google Photos!

### Monitoring

This is all very nice IF it works. After setting things up initially, there were
all kinds of little issues: filesystem permission errors, typos, all that mumbo
jumbo. To catch these for the future, I just enabled emailing in cron. I get an
email every day at midnight that reports the status of each machine's backup and
pruning job results. That script that backs up the phone media doesn't return
output by design, but when it does it sends an error email every minute. This
has led to some unwieldy spam! It doesn't happen often enough to be an issue,
thankfully, and so for the moment I just deal with it and cleanup about 1000
emails from my inbox.

## What's Next?

I am very happy with this solution. It feels satisfying to see emails every day
detailing how much data was backed up, what snapshots are currently stored, and
how much deduplicated data was cleaned up. Thankfully, I haven't had to use it
yet!

So that I don't get bit in the ass yet again, I really need to go in and do a
mock recovery. This would involve going through each machine, selecting a few
snapshots, and restoring their contents into a temporary directory. Files should
be inspected and configuration/services run if needed to ensure there isn't any
pattern of corruption.

It would also probably be wise to stagger backups more to avoid overloading my
server. Right now, I manually stagger each cron job by about 10 minutes, but I
believe this would be a job better done by the server. My simple bash script may
need to evolve a bit!

If you're not already doing backups, I get it. Its a lot of work to do for
something that you might never use. But having the peace of mind knowing your
data is safe is priceless. If you only have one or two machines, a manual
strategy is probably just fine. Syncthing is great for continuous backups and I
used it for years. Having so many more machines now makes a solution like this
make much more sense for me.

---

Suggestions? Recommendations? Please, let me know at `decaby7e at ranvier dot net`!
