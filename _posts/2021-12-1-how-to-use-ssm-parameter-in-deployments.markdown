---
layout: post
title:  "How to use SSM Parameter Store in Deployment Pipelines"
thumbnail: "/images/thumb/th_aws-logo.png"
image: "/images/aws-logo.png"
author: "rpfilomeno"
categories: aws
comments: true
tags:
 - windows
 - ssm
 - codepipeline
 - apache
---

AWS [SSM Parameter Store](https://docs.aws.amazon.com/kms/latest/developerguide/services-parameter-store.html) is a way to manage your application parameters and deploy them as configuration files.

<!--break-->

First we need to make sure to follow some key naming convention that the keys must named in a path type structure such as ```/root/path1/keyname1```, this is done so we can easily retrieve all the parameters under ```/root/path1``` then export ```keyname1``` as the [Apache mod_env environment key](https://httpd.apache.org/docs/2.4/mod/mod_env.html).

Example SSM Parameter entry:

<table class="table table-dark">
 <thead>
  <tr>
   <th scope="col">path</th>
   <th scope="col">value</th>
   <th scope="col">securestring(?)</th>
  </tr>
 </thead>
 <tbody>
 <tr>
  <td>/root/dbconfigs/DBhost</td><td>192.168.0.1</td><td>no</td>
 </tr>
 <tr>
  <td>/root/dbconfigs/DBusername</td><td>my-username</td><td>no</td>
 </tr>
 <tr>
  <td>/root/dbconfigs/DBpassword</td><td>***********</td><td>yes</td>
 </tr>
 </tbody>
</table>


This will be written to an Apache config as:

```
SetEnv DBhost 192.168.0.1
SetEnv my-username
SetEnv my-password
```

*Note: the value of DBpassword is automatically decoded from a securestring*

Here is a script the will pull all those parameters and convert them into Apache config file, you can use this script during build ([buildspec.yml](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)) or deploy ([appspec.yml](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)) phase:

```
#!/bin/sh
BYPATH="/root/dbconfigs/"                # the SSM PATH
FILE="/etc/httpd/conf.d/dbconfigs.conf"  # the mod_env confile file
NEXTTOKEN="null"                         # stores the pagination Id for SSM query

sudo yum -y install jq                   # installs the json parser

## retrieve the SSM path
JSONRESP=$(aws ssm get-parameters-by-path --path $BYPATH --with-decryption --region ap-southeast-2)

## write to the Apache config file as "SetEnv keyname1 somevalue-stored-in-ssm-under-this-key"
echo $JSONRESP | jq --compact-output --raw-output '.Parameters[] | "\(.Name) \(.Value)"' | awk -v q='"' -v p=$BYPATH '{gsub(p, "");print "SetEnv", $1, q$2q}' > $FILE


## find if theres a next page
NEXTTOKEN=$(echo $JSONRESP | jq --compact-output --raw-output '.NextToken')

## redo the same thing for each page
while [ $NEXTTOKEN != "null" ]
do
  JSONRESP=$(aws ssm get-parameters-by-path --path $BYPATH --with-decryption --region ap-southeast-2 --next-token $NEXTTOKEN)
  NEXTTOKEN=$(echo $JSONRESP | jq --compact-output --raw-output '.NextToken')
  echo $JSONRESP | jq --compact-output --raw-output '.Parameters[] | "\(.Name) \(.Value)"' | awk -v q='"' -v p=$BYPATH '{gsub(p, "");print "SetEnv", $1, q$2q}' >> $FILE
done

exit 0
```
