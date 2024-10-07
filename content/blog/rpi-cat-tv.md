---
title: "Playing Cat Videos for my Cat with a Raspberry Pi"
date: 2022-02-04T22:45:00-05:00
description: "Doing the least to get the most out of a Raspberry Pi Zero W as a 'dashboard'"
draft: false
categories: ["tech"]
tags: ["linux", "raspberry pi"]
layout: post
---

## Introduction

I want my cat to not be bored while I'm away from my apartment for most of the
day. She loves watching videos on my TV but I'm afraid one day she'll go a step
too far and damage it. I decided that I would go to Goodwill and find a cheap
monitor/TV for her to use. But damned if I'll put the video on every time she
wants to play with it! I decided a Raspberry Pi Zero W would be sufficient for
the job. Just load some videos on there and have them come on at specific times
during the day.

{{< image src="/img/katie.jpg" >}}

*What are you working on?*

## Requirements

- $5 dollar TV/monitor from Goodwill (Let me know if you find a cheaper one!)
- Raspberry Pi Zero W
- 32G Micro SD Card
- Mini HDMI to VGA adapter
- Micro USB power supply (at least 5V @ 1A)

## Installing Raspberry Pi OS

I decided to go with the [Raspberry Pi
Imager](https://github.com/raspberrypi/rpi-imager) utility because it has a nice
feature where if you open it and hit `CTRL` + `SHIFT` + `X`, you can reveal a
*secret* menu that lets you do stuff like change the hostname, add SSH keys, and
configure WiFi. I prefer this over having to do these things manually.

I went with the minimal 32-bit install of Raspberry Pi OS to keep things light
on the poor Pi Zero...

## Installing Required Packages

Because the minimal install is, well... minimal, you don't get much by default
with it. That's good imo! Better for things to break and having to add more than
to have a lot of bloat.

- xorg - Display server
- xterm - Terminal emulator
- vlc - Video player
- imagemagick - Image viewer
- git - Version control system

## Taking Control of the Display

I could have just installed `lightdm` and used something like firefox or chrome
to display the video from YouTube but that just doesn't cut it for what I want.
The Pi will be connected to the internet but I would prefer to keep its
communication to a minimum and I definitely don't want to stream videos all day,
as that would take up wayyy to much bandwidth. I downloaded a random video of
rats and birds running around from YouTube using
[youtube-dl](https://github.com/ytdl-org/youtube-dl) and saved that to the Pi's
SD card. I then wrote some scripts to start a basic Xorg server (to allow for
graphical windows to be rendered) and to play VLC on that server.

## Wrapping it up with git and Ansible

After getting everything working by hand, I then wrapped everything up in a git
repository and installed that repository on the pi using Ansible. It's in a bit
of a rough state, as I lost the time to work on it after I got it basically
working, but if you're interested in the code, its posted on GitHub here:

<https://github.com/decaby7e/dashpi>

## Conclusion

It was neat to see how slim I could get a Debian setup where I just wanted to
play a video. At first I thought maybe something like Chromium playing a YouTube
video would work well as well but I decided that might be too CPU intensive and
didn't want the Pi to have to maintain a constant network connection. In the
future, I think something like a button on the Pi would be cool, as right now
I'm limited to either SSHing in and playing the video by running the script or
waiting for it to come on from the timer. In any case, I think Katie very much
appreciates the company!
