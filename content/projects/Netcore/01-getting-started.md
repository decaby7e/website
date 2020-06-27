---
title: "Getting Started"
date: 2020-06-10T23:24:31-04:00
description: ''
draft: False
tags: ['netcore', 'webdev']
---

## Plain and simple IPAM for the system administrator that wants something that Just Works™️ with minimal configuration

In this project, I'm hoping to create something that can be both highly useful (both at my workplace and in my own home) and educational as I begin to learn more and more about web development. I'm retroactively writing this post, after much of the project has already been planned out, so that I can reflect on what I've done so far and what I hope to do in the future. First, I want to write out the structure that I started with in this project and the structure that I replaced this initial one with when I realized that the former was going to be much too rigid for what I was going for.

## Features

I chose to create Netcore *mainly* due to a desire to improve the workflow that my workplace follows when adding, modifying, and removing hosts from our networks. While most people use commercial IPAM solutions, Active Directory, or a combination of the two, my workplace, some time in the past, chose to take a custom approach. This approach is centered around a file known affectionately as the `CISE Hostfile`, which follows its own custom syntax and relies on custom scripts to generate the corresponding network configuration files. While this seems to be an *ok* approach for small networks, our network can be considered rather large, leaving us in a suboptimal position for managing hosts. That being said, Netcore is created with the features of our legacy system in mind, albeit with the goal of general use always being the priority.

### Features

- REST API
- Add, remove, edit, import, and export networks
- Add, remove, edit, import, and export hosts
  - Hosts can reside in multiple networks
- Add, remove, and edit DNS records
- Logging of actions taken by any user (who, what, and when)
- LDAP integration for authentication and ownership of hosts/networks by groups/people
- Integration with DNS / DHCP servers
  - Only information needed being hostnames and the user to connect as
  - In my case, I will be using BIND9 and DHCPD in Docker containers on the servers
- Import and export a CISE Hostfile
  - Compatibility for work environment - will be removed in the future once project becomes more general

## Legacy Structuring

The previous structure of this project used Django, a web framework built in Python. Django is rather powerful and provides many features out of the box like CSRF, authentication, etc. that allows you to get straight to focusing on your app rather than remaking the basics. Django does have its flaws though, and one of these can be found in the ability to create reactive frontends. I may be missing something in my efforts with Django, but from what I can gather

## New Structuring

## Conclusion

I hope to continue writing more posts about this project and if anyone wants to give feedback on how I can improve things, feel free to contact me or make a pull request (if I make this project public sometime soon).