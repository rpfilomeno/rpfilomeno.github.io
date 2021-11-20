---
layout: post
title:  "Installing Jekyll on WSL2 Ubuntu the correct way"
date:   2021-03-08 11:05:54 +0800
categories: wls2
tags:
 -wsl
 -windows
---

I you have installed Jekyll in WSL2 Ubuntu via apt-get then you might end up with this error:

```text
undefined method `delegate_method_as' for Jekyll::Drops::CollectionDrop:Class (NoMethodError) Did you mean? DelegateClass
```

Here is the quick fix:

```bash
PACKAGES="$(dpkg -l |grep jekyll|cut -d" " -f3|xargs )"
sudo apt remove --purge $PACKAGES
```

```bash
sudo gem install jekyll jekyll-feed jekyll-gist jekyll-paginate jekyll-sass-converter jekyll-coffeescript
```

```bash
bundle update
```
