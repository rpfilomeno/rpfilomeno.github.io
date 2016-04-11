---
layout: post
title:  "Testing Kamailio loadbalancer with SIPp"
date:   2016-04-11 16:05:54 +0800
categories: voip
comments: true
---

First of all lets describe our network setup:
<script src="https://gist.github.com/rpfilomeno/d46493eefaf70d6838c157305ab9778a.js"></script>

The a user from extension 300X registered to Asterisk 1 initiates a call to an extension 400X registered at Asterisk 2. Kamailio is registered as a trunk to both Asterisk 1 & 2; which intercepts the call which load balances it to either Asterisk X or Y where they do some fancy pre-processing to current call before its received by the callee.

Now for our testing purposes, we needed to remove the effect on performance by Asterisk 1 & 2 so we installed SIPp on another host which generates calls and receives them.

Installation Steps
-------------------

1. Download and Modify SIPp to auto respond always and include OPTIONS packet as well (-aa broken?), edit src/call.cpp:


```cpp
call::T_AutoMode call::checkAutomaticResponseMode(char * P_recv)
{
    if (strcmp(P_recv, "BYE")==0) {
        return E_AM_UNEXP_BYE;
    } else if (strcmp(P_recv, "CANCEL") == 0) {
        return E_AM_UNEXP_CANCEL;
    } else if (strcmp(P_recv, "PING") == 0) {
        return E_AM_PING;
    } else if ((strcmp(P_recv, "INFO") == 0) || (strcmp(P_recv, "NOTIFY") == 0) || (strcmp(P_recv, "UPDATE") == 0) || (strcmp(P_recv, "OPTIONS") == 0)
               ) {
        return E_AM_AA;
    } else {
        return E_AM_DEFAULT;
    }
}
```


Compile sipp-3.3.990 with RTP Support: http://sipp.sourceforge.net/doc/reference.html#Installing+SIPp

To run the test, from SIPp Box: 
```bash
# sipp 10.254.1.30 -i 10.254.1.40 -sf uac.xml -aa -inf accounts.csv -l 10000 -r 1 -rp 1000 -trace_msg -trace_err -trace_stat
```


**Parameter explanation**
<table class="table">
  <thead>
    <tr>
      <th>Parameter</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>10.254.1.30</td>
      <td>target Kamailio's IP on the LAN A side (see network diagram)</td>
    </tr>
    <tr>
      <td>-i 10.254.1.40</td>
      <td>make sure to bind SIPp on this IP especially if we are using IP Authentication on Kamailio</td>
    </tr>
    <tr>
      <td>-sf uac.xml</td>
      <td>use this scenario file that generates calls.</td>
    </tr>
    <tr>
      <td>-inf accounts.csv</td>
      <td>use this input CSV file, this is where the [field0],[field1],[field2] and [field3] values are derived in uac.xml. Edit this file accordingly in format: CallID;Kamailio LAN A IP;[authentication];Extension on Asterisk 2 (If running SIPp server mode, this wont matter);Asterisk 2 LAN B IP;</td>
    </tr>
    <tr>
      <td>-l 10000</td>
      <td>run 1000 calls.</td>
    </tr>
    <tr>
      <td>-r 1 -rp 1000</td>
      <td>make one call per 1000ms (1 secs)</td>
    </tr>
    <tr>
      <td>-trace_msg</td>
      <td>log all messages to a file (filename auto generated)</td>
    </tr>
    <tr>
      <td>-trace_err</td>
      <td>log all errors to a separate file (filename auto generated)</td>
    </tr>
    <tr>
      <td>-trace_stat</td>
      <td>generate a CSV file with statistics which is good for making graphs (default 1 minute interval) </td>
    </tr>
  </tbody>
</table>


Make sure to edit the accounts.csv, change 10.254.1.30 and 10.254.7.31 accordingly.

Make sure to edit the uac.xml, change Route: _&lt;sip:10.254.1.30;r2=on;lr=on;nat=yes&gt;,&lt;sip:10.254.3.30;r2=on;lr=on;nat=yes&gt;_ accordingly since sipp-3.3.990 can't reliably generate this header so we had to hard code this for now. 

(Many thanks to Gohar Ahmed for helping me figure this out, check out his blog http://saevolgo.blogspot.com/)


You may run a SIPp on Asterisk 2 box to test higher concurrent calls (eg: testing more than 200 concurrent calls).

Lets shutdown Asterisk 1 & 2: 
```bash
# asterisk -rx "core stop now"
```

To run a server listening to incoming calls (server mode), run:
```bash
# sipp 10.254.7.30 -i 10.254.7.31 -sf uas.xml -aa -trace_msg -trace_err -trace_stat
```


