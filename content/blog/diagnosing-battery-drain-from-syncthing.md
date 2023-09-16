---
title: "Why Is My Phone Dead In The Mountains?"
date: 2023-09-16
tags: ["debugging", "android"]
draft: false
layout: post
---

## A Lack of Battery Juice

The last thing you want when you don't have easily accessible AC power is for
your easily accessible portable DC power to crap out on you. But on a number of
hikes, that's just what happened to me!

I know the whole spiel about cold weather affecting battery life. To avoid this,
I keep my phone and portable charger close to by body in my backpack and
sometimes on my person. At night, it went in my sleeping bag with me. On one
occasion, I awoke to a pleasant warm sensation in the bag and after a quick pee
check realized it was my phone. And it was all out of its own juice! This was
never an issue at home because it goes on the charger at night. When I checked
the battery usage history in the settings menu, I noticed that it was Syncthing
eating up over 30-40% of the battery. And it would start around midnight.

## Sane Syncthing Settings

Typically, Syncthing isn't much of a battery hog. I have to be mindful about
syncing large files over mobile data or running on battery, but it wasn't
usually an issue. I figured that setting it to run only when plugged in would be
good enough. On hikes, the largest files that might be created would be videos
or pictures. And I'd actually like those to back up so I don't have another
Springstravaganza fiasco (oh that poor Pixel 4 XL).

So great. We've got "only run on AC power" and I'll keep an eye on battery usage
before bed to make sure we're not running into danger territory. Service isn't
always great, which can also eat battery, but a dead phone is better than losing
precious pictures (I've got backup comms if I really need them). But I'm still
somehow losing tons of battery at night, seemingly for no reason. What gives?!

## Who's the Culprit Then?

It turns out, after checking my backup logs, that I was missing a number of
Signal chat backups. "Hmm why would that... Eureka!"

Signal queues backups for midnight by default. This isn't a huge battery hog by
itself BUT it does generate very large files, hovering between 2-3GB. Then,
Syncthing politely picks these up and attempts to upload them using a horrible
3G connection. That is a recipe for disaster. And because the phone is plugged
into a portable charger at night, it thinks it's in the clear to upload files.
Agh!

## Solution Plz?

The solution? Just tell Syncthing not to run on battery saver :) If I really
want photos/videos to be backed up ASAP, I can turn it off and save battery by
not opening apps, lowering brightness, disabling wifi/bluetooth/etc..
Unfortunately, Signal only allows backups to be scheduled at a certain time
daily, and I don't feel like digging around in Signal settings every time I want
to save battery. Also, if for some reason some massive files are created by some
other app, this solution is more general and will keep those from causing
Syncthing to eat even more battery.
