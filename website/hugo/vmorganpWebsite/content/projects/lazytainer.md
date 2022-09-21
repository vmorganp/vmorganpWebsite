---
title: 'Lazytainer'
date: 2022-09-21T00:10:46-07:00
tags: ['project']
---

Lazy load your docker containers

[Check it out](https://github.com/vmorganp/Lazytainer)

# Why

I self host some services using my own hardware at home. I wanted to reduce my security threat surface and save some watts and RAM.

# How

I made a container, which checks for traffic to other containers, and if a minimum amount is not met, it automatically stops those containers until they recieve traffic again
