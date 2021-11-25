---
layout: post
title:  "Installing Jekyll on WSL2 Ubuntu the correct way"
categories: wls2
thumbnail: "/images/thumb/th_jekyll.png"
image: "/images/jekyll.png"
author: "rpfilomeno"
comments: true
tags:
 - wsl2
 - windows
 - jekyll
---


If you have installed Jekyll in WSL2 Ubuntu via apt-get then you might end up with this error:

```text
undefined method `delegate_method_as' for Jekyll::Drops::CollectionDrop:Class (NoMethodError)
```
<!--break-->

Here is the quick fix:

```bash
PACKAGES="$(dpkg -l |grep jekyll|cut -d" " -f3|xargs )"
sudo apt remove --purge $PACKAGES
```

```bash
sudo apt autoremove
```

```bash
sudo gem install jekyll jekyll-feed jekyll-gist jekyll-paginate jekyll-sass-converter jekyll-coffeescript
```

```bash
bundle update
```

If you encounter this error when running ```gem install```:

```text
ERROR:  While executing gem ... (ArgumentError)
    wrong number of arguments (given 4, expected 1)
```

You can use this fix:

```bash
gem uninstall psych
```

```bash
gem install activesupport -v '6.0.4.1' --source 'https://rubygems.org/'
```

