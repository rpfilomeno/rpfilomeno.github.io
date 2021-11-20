---
layout: post
title:  "Accessing Amazon AWS EC2 instance in VPC with loadbalancer"
thumbnail: "/images/thumb/th_lorem.png"
image: "/images/lorem.png"
author: "rpfilomeno"
categories: aws
comments: true
tags:
 - cloud
 - troubleshooting
---

I was working on project using AWS and found out that EC2 instances with private subnets in VPC must have a "shadow" subnet with routing to the Internet gateway or else external LB will not be accessible.

<!--break-->

First of all create your Internet Gateway and NAT Gateway under VPC, this is an important concept in AWS VPC; your IG gateway provides incoming connection while your NAT gateway provides outgoing connection. 

My VPC subnet for example is (10.100.0.0./16) then define your private subnets as:

<table class="table">
  <thead>
    <tr>
      <th>Name</th>
      <th>Subnet</th>
      <th>Availability</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>subnet1-a</td>
      <td>10.100.1.0/24</td>
      <td>zone a</td>
    </tr>
    <tr>
      <td>subnet2-b</td>
      <td>10.100.2.0/24</td>
      <td>zone b</td>
    </tr>
    <tr>
      <td>subnet1-a-shadow</td>
      <td>10.100.10.0/24</td>
      <td>zone a</td>
    </tr>
    <tr>
      <td>subnet2-b-shadow</td>
      <td>10.100.20.0/24</td>
      <td>zone b</td>
    </tr>
  </tbody>
</table>

Create your EC2 instances _host1-a_ and _host2-b_ under subnet _subnet1-a_ and _subnet1-b_ respectively, check that the create hosts are using the IP address correctly and you can access the Internet.

In your _Route Table_ you should have 2 routes, the _Main_ route should point to your NAT gateway so EC2 instances by default should have Internet access via the NAT gateway, I name this _VPC-RT-NAT_:


<table class="table">
  <thead>
    <tr>
      <th>Destination</th>
      <th>Target</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>10.100.0.0/16</td>
      <td>local</td>
    </tr>
    <tr>
      <td>0.0.0.0/0</td>
      <td><em>nat-08bbb950567fc5300</em>></td>
    </tr>
  </tbody>
</table>

Then the other route I named _VPC-RT-PUBLIC_ points to my Internet Gateway

<table class="table">
  <thead>
    <tr>
      <th>Destination</th>
      <th>Target</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>10.100.0.0/16</td>
      <td>local</td>
    </tr>
    <tr>
      <td>0.0.0.0/0</td>
      <td><em>igw-5e67e11b</em></td>
    </tr>
  </tbody>
</table>

Now go back to your _Subnets_ page under _VPC Services_ and edit the route table for subnets _subnet1-a-shadow_ and _subnet2-b-shadow_, change it to use _VPC-RT-PUBLIC_ route table.

Next; on the _EC2 Services_; create new interfaces under _Network Interfaces_ pages:

<table class="table">
  <thead>
    <tr>
      <th>Network Interface</th>
      <th>Subnet ID</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>eni-3c6bc01a</td>
      <td>subnet1-a-shadow</td>
      <td>Shadow interface for host1-a </td>
    </tr>
    <tr>
      <td>eni-3c6bc02b</td>
      <td>subnet2-b-shadow</td>
      <td>Shadow interface for host2-b</td>
    </tr>
  </tbody>
</table>
Attach these newly created interfaces to their respective EC2 instance hosts. Note that when you login into you hosts and use _ifconfig -a_ command, the added interfaces will not assign the private IPs under these _shadow_ subnets, only the IPs for _subnet1-a_ and _subnet2-b_ and this is normal -- thats why we call them _shadows_.

Finally create your load balancer and select subnets _subnet1-a-shadow_ and _subnet2-b-shadow_ and after a few minutes when the DNS updates you should be able to ping and access your LB's through its DNS name.