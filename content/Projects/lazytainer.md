---
title: Lazytainer
date: 2022-09-21
tags:
  - project
---

Lazy load your docker containers

[Check it out](https://github.com/vmorganp/Lazytainer)

# Why

I self host some services using my own hardware at home. I wanted to reduce idle use of system resources, specifically RAM (looking at you minecraft servers). It should also theoretically help with power use and security threat surface. Since it takes a moment to spin up, a cursory scan will not return any active ports, assuming a service isn't actively being used.

# How

Using the go programming language, I made a container, which checks for traffic to other containers. If a minimum amount is not met, it automatically stops those containers until they receive traffic again. The README for this project is far more descriptive if you really want to dig in to how it works.
