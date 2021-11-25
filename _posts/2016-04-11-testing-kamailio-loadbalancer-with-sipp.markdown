---
layout: post
title:  "Testing Kamailio load balancer with SIPp"
thumbnail: "/images/thumb/th_text-diagram.png"
image: "/images/lorem.png"
author: "rpfilomeno"
categories: voip
comments: true
tags:
 - troubleshooting
---

Here are thr steps to test Kamailio under load.

<!--break-->

First of all lets describe our network setup:
<script src="https://gist.github.com/rpfilomeno/d46493eefaf70d6838c157305ab9778a.js"></script>

The a user from extension _300X_ registered to _Asterisk 1_ initiates a call to an extension _400X_ registered at _Asterisk 2_. _Kamailio_ is registered as a _trunk_ to both Asterisk 1 & 2; which intercepts the call which load balances it to either _Asterisk X or Y_ where they do some _fancy_ pre-processing to current call before its received by the callee.

Now for our testing purposes, we needed to remove the effect on performance by Asterisk 1 & 2 so we installed SIPp on another host which generates calls and receives them.

### Installation and Execution Steps


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


Compile _sipp-3.3.990_ with [RTP Support](http://sipp.sourceforge.net/doc/reference.html#Installing+SIPp).

To run the test, from SIPp Box: 
```bash
# sipp 10.254.1.30 -i 10.254.1.40 -sf uac.xml -aa -inf accounts.csv -l 10000 -r 1 -rp 1000 -trace_msg -trace_err -trace_stat
```

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
      <td>-sf <a href="https://gist.github.com/rpfilomeno/7445a628a3cbc0ceaaf8e9afe182578b#file-uac-xml">uac.xml</a></td>
      <td>use this scenario file that generates calls.</td>
    </tr>
    <tr>
      <td>-inf <a href="https://gist.github.com/rpfilomeno/8673ee9dc7355274dfd98d187bbde925#file-accounts-csv">accounts.csv</a></td>
      <td>use this input CSV file, this is where the <em>[field0]</em>,<em>[field1]</em>,<em>[field2]</em> and <em>[field3]</em> values are derived in uac.xml. <br>Edit this file accordingly in format: 
		<em>
		CallID;Kamailio LAN A IP;[authentication];Extension on Asterisk 2;Asterisk 2 LAN B IP;
		</em>
	</td>
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

Make sure to edit the uac.xml, change Route:
```
<sip:10.254.1.30;r2=on;lr=on;nat=yes>,<sip:10.254.3.30;r2=on;lr=on;nat=yes>```
accordingly since sipp-3.3.990 can't reliably generate this header so we had to hard code this for now. 

You may run a SIPp on Asterisk 2 box to test higher concurrent calls (eg: testing more than 200 concurrent calls).

Lets shutdown Asterisk 1 & 2: 
```bash
# asterisk -rx "core stop now"
```

To run a server listening to incoming calls (server mode), run:
```bash
# sipp 10.254.7.30 -i 10.254.7.31 -sf uas.xml -aa -trace_msg -trace_err -trace_stat
```

Makes sure to edit the [uas.xml](https://gist.github.com/rpfilomeno/5827e6ecf5863f74f53d41b1e15fa707#file-uas-xml) to include the IP routes.

Now lets see how effective is Kamailio in this setup, here are the results I had:
<table class="table">
  <thead>
    <tr>
      <th>Test Name</th>
      <th>Concurrent Calls</th>
      <th>Success</th>
      <th>Failed</th>
      <th>Dead Calls</th>
      <th>Retransmissions</th>
      <th>Average Response Time</th>
      <th>Average Call Rate Per Seconds</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Test1</td>
      <td>200</td>
      <td>1000</td>
      <td>0</td>
      <td>0</td>
      <td>3</td>
      <td>2.52747</td>
      <td>03.615000</td>
    </tr>
    <tr>
      <td>Test2</td>
      <td>300</td>
      <td>998</td>
      <td>2</td>
      <td>5</td>
      <td>252</td>
      <td>3.15839</td>
      <td>04.550000</td>
    </tr>
    <tr>
      <td>Test3</td>
      <td>400</td>
      <td>993</td>
      <td>7</td>
      <td>12</td>
      <td>1355</td>
      <td>3.61512</td>
      <td>13.049000</td>
    </tr>
    <tr>
      <td>Test4</td>
      <td>600</td>
      <td>831</td>
      <td>169</td>
      <td>127</td>
      <td>3554</td>
      <td>4.05337</td>
      <td>13.04900</td>
    </tr>
  </tbody>
</table>

We stop at _Test 4_ seeing Failed Calls spiked up at 169 calls, this was significant from our base capacity of 50 concurrent calls already.

Many thanks to [Gohar Ahmed](http://saevolgo.blogspot.com/) for helping me figuring most of the bugs.
