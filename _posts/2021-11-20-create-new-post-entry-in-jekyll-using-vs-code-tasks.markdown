---
layout: post
title: "Create new post entry in Jekyll using VS Code Tasks"
categories: vscode
thumbnail: "/images/thumb/th_jekyll_code1.png"
image:
author: "rpfilomeno"
comments: true
tags:
 - jekyll
 - ruby
 - tasks
---


This will allow you to create new post in Jekyll without manually creating the file in ```_posts``` directory 

<!--break-->

by running

Add the following to your Gemfile:

```bash
gem 'thor'
gem 'stringex'
```
<!--break-->

Run ```bundle install``` and create a ```jekyll.thor``` file with the following contents:


```ruby
# Usage:
# thor jekyll:new The title of the new post
# thor jekyll:new The title of the new post --editor=vim

require "stringex"
class Jekyll < Thor
  desc "new", "create a new post"
  method_option :editor, :default => "code"
  def new(*title)
    title = title.join(" ")
    date = Time.now.strftime('%Y-%m-%d')
    filename = "_posts/#{date}-#{title.to_url}.markdown"

    if File.exist?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: post"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "categories:"
      post.puts "tags:"
      post.puts " -"
      post.puts "---"
    end

    system(options[:editor], filename)
  end
end
```

Define a new task and prompt in your ```.vscode/task.json``` file:

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        // ...
        {
            "label": "Create new post",
            "type": "shell",
            "command": "thor jekyll:new ${input:posttitle}",
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        }
    ],
    "inputs": [
        {
            "id": "posttitle",
            "description": "Post Title",
            "default": "Your new post title",
            "type": "promptString"
        },
    ]
}
```

Open the command pallete ```Ctrl+Shift+P``` and type ```Tasks: Run Task``` then select ```Create new post``` then enter the title on the prompt.

This will create a new file under ```_post``` directory and open it on VS Code.