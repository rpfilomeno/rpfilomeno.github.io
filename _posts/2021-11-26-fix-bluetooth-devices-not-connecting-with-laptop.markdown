---
layout: post
title:  "Fix Bluetooth Not Connecting with Laptop"
categories: windows
thumbnail: "/images/thumb/th_bluetooth-chip.png"
image: "/images/bluetooth-chip.png"
author: "rpfilomeno"
comments: true  
tags:
 - bluetooth
 - windows
 - drivers
 - xiaomi
---

If you are encountering problem with some bluetooth devices (eg: non-branded, Xiaomi speakers) not able to connect to laptop then its because of a wrong driver that Windows installed by default.

<!--break-->

The Broadcom BCM20702A0 driver is required for some bluetooth devices and the problem is Windows and 3rd party driver installers misidentify this with another chip, this happens commonly in older devices.

Download the driver below and install as administrator.

<a href="https://drive.google.com/file/d/1kegR3i8VVdJ9THgoWikoneqoTa1E2Lgk/view?usp=drivesdk">https://drive.google.com/file/d/1kegR3i8VVdJ9THgoWikoneqoTa1E2Lgk/view?usp=drivesdk</a>