---
layout: post
title:  "Fixing AWS EC2 Multiple Interfaces and Elastic IP with Asymmetric Network Routing"
date:   2016-04-11 16:05:54 +0800
categories: aws
comments: true
---

I have 15 CentOS instances on AWS EC2 with multiple interfaces (on different subnets) and since by default asymmetrical routing is enforced the traffic intended to those extra interfaces will be drop.

The best explanation and solution I found is available on [Jensd's I/O buffer blog](http://jensd.be/468/linux/two-network-cards-rp_filter), however configuring 15 hosts manually (and more eventually) seemed a tiring task for me so I wrote bash script that can be dropped into a host and enable symmetric network routing.

```sh
#!/bin/bash
LIST=`ip addr show | grep 'inet ' | awk '{print $2,$7}'`
TAB=1
PRIORITY=100
while read -r line; do
    IP=`echo $line | awk '{print $1}'`
    NAME=`echo $line | awk '{print $2}'`
    if [ ! -z "$NAME" ]; then
        BASEIP=`echo $IP | cut -d"." -f1-3`
        
        BASEIP=`echo $IP | cut -d"/" -f1`

        TAB=$(($TAB+1))
        PRIORITY=$(($PRIORITY+100))
    fi
done <<< "$LIST"
```

