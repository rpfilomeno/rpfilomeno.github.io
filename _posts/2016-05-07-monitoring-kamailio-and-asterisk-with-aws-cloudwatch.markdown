---
layout: post
title:  "Monitoring Kamailio and Asterisk with AWS CloudWatch"
thumbnail: "/images/thumb/th_voip-aws-mon.jpg"
image: "/images/voip-aws-mon.jpg"
author: "rpfilomeno"
categories: aws
comments: true
tags:
 - voip
 - asterisk
 - kamailio
---

Today I'm announcing the release to my new project <a href="https://github.com/rpfilomeno/voip-mon-aws-cloudwatch">VOIP Statistics to AWS CloudWatch (voip-mon-aws-cloudwatch)</a>, it is a monitoring script for Kamailio and Asterisk for AWS CloudWatch written in PHP. 

<!--break-->

This works similarly to AWS CloudWatch Monitoring Script (Linux).

Requirements
------------

* PHP 5.5 and above
* Composer
* Asterisk
* Kamailio


Installation
------------

1. Git clone to any Linux instance with Kamailio or Asterisk installed, 
for example to ~/home/ec2-user/ using 
```git clone https://github.com/rpfilomeno/voip-mon-aws-cloudwatch.git```

2. Go to the project's root directory by ```cd ./voip-mon-aws-cloudwatch/```

3. Make the mon-put-instance-data.php executable ```sudo chmod +x mon-put-instance-data.php```

4. Install Composer ```curl -sS https://getcomposer.org/installer | php```

5. Install the dependencies by ```php composer.phar update```

6. Create your aws [credentials file](http://docs.aws.amazon.com/aws-sdk-php/v3/guide/guide/credentials.html#credential-profiles)


Usage
-----

### Monitoring Kamailio

1. Test the script for monitoring Kamailio with 
```./mon-put-instance-data.php stats --t kamailio```

2. Install to Crontab with ```crontab -e```
<pre>
*/5 * * * * php /home/ec2-user/voip-mon-aws-cloudwatch/mon-put-instance-data.php stats --s kamailio
</pre>


### Monitoring Asterisk

1. Test the script for monitoring Kamailio with 
```./mon-put-instance-data.php stats --t asterisk```

2. Install to Crontab with ```crontab -e```
<pre>
*/5 * * * * php /home/ec2-user/voip-mon-aws-cloudwatch/mon-put-instance-data.php stats --s asterisk
</pre>