---
layout: post
title:  "Resyncing Your Windows PC Time Server After Leaving The Domain"
thumbnail: "/images/thumb/th_lorem.png"
image: "/images/lorem.png"
author: "rpfilomeno"
categories: windows
comments: true
tags:
 - troubleshooting
---

Today I tried to upload my certificate to AWS IAM. 

<!--break-->

Command line:

```
C:\SSL>aws iam upload-server-certificate 
--server-certificate-name wildcard_domain_net 
--certificate-body file://public.crt 
--private-key file://private.key
```

 And I got this error:


```
A client error (SignatureDoesNotMatch) occurred when calling the UploadServerCertificate operation: 
Signature expired: 20160512T092519Z is now earlier than 2016 0512T092623Z (20160512T094123Z - 15 min.)
```

This means my local time is not correct, and this happened to me because my PC has been recently 
disconnected from our domain so it was still configured to get NTP data from the domain server.

To quickly fix this just run cmd.exe as Administrator and execute:

```
C:\Windows\system32>w32tm /config /manualpeerlist:pool.ntp.org,0x8 /syncfromflags:MANUAL
```

Followed by:

```
C:\Windows\system32>w32tm /config /update
```