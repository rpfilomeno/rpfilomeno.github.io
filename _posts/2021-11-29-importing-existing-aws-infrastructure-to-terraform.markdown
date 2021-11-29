---
layout: post
title:  "Importing Existing AWS Infrastructure to Terraform"
thumbnail: "/images/thumb/th_terraform-logo.png"
image: "/images/terraform-logo.png"
author: "rpfilomeno"
categories: aws
comments: true
tags:
 - windows
 - terraform
 - terraformer
 - iac
---

We all know about Terraform, the leading Infrastructure as Code platform, however what will you do if you already built the infrastructure? How will you still be able to leverage Terraform without needing to rewrite hundreds of definitions from scratch.<!--break--> As of this time in writing there is no existing way to import all resources at once using Terraform: 

> The terraform import command is used to import existing infrastructure.
>
> The command currently can only import one resource at a time. This means you can't yet point Terraform import to an entire collection of resources such as an AWS VPC and import all of it. This workflow will be improved in a future version of Terraform.
>
> --- https://www.terraform.io/docs/cli/import/usage.html')

Thats where [Terraformer](https://github.com/GoogleCloudPlatform/terraformer) comes useful: A CLI tool that generates tf/json and tfstate files based on existing infrastructure (reverse Terraform). On this guide we will be using Terraformer and Terraform in Windows to show you all the fixes for the quirks installation.

## Installation of Terraformer

- For Windows using [Chocolatey](https://chocolatey.org/)
    - Install as admininstrator ``choco install terraformer``
    - Download the provvider plugin at https://releases.hashicorp.com/terraform-provider-aws/3.63.0/terraform-provider-aws_3.63.0_windows_amd64.zip
    - Crate the provider directory at ``C:\.terraform.d\plugins\windows_amd64`` and unzip the downloaded plugin here.



## Installation of Terraform

- For Windows using [Chocolatey](https://chocolatey.org/)
    - Install as admininstrator ``choco install terraform``



## Credentials

- Create the ``C:\Users\USERNAME\.aws\config`` with the following content:
```
[default]
region = ap-southeast-2
```
- Create the ``C:\Users\USERNAME\.aws\credentials`` withh th following content:
```
[default]
aws_access_key_id = XXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXX
```



## Creating an Import Plan

- Execute ``terraform init`` where providers.tf file is loccated, add flag ``-reconfigure`` if updating versions of the provider plugins.
- Execute ``terraformer  plan aws --output hcl --resources="*" --verbose`` to create an import plan saved at ``.\generated\aws\terraformer\plan.json`` for all resources located at AWS default region.



## Importing using Terraformer

- Execute ``terraformer import plan .\generated\aws\terraformer\plan.json`` to begin importing the resources information and storing their states.



## Validating/Applying changes with Terraform

- Change to the generated direvtory such as ``.\generated\aws\dynamodb``
- Execute ``terraform state replace-provider -- -/aws hashicorp/aws`` to update provider in state file.
- Execute ``terraform init`` to reinitialize.s
- Execute ``terraform validate`` to check errors in the configuration under this directory.
- Execute ``terraform plan`` to check for changes or ``terraform apply`` to plan and apply changes

