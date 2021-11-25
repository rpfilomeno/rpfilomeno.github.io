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
      post.puts "categories: personal;"
      post.puts "thumbnail: \"/images/thumb/th_lorem.png\""
      post.puts "image: \"/images/lorem.png\""
      post.puts "author: \"rpfilomeno\""
      post.puts "comments: true"
      post.puts "tags:"
      post.puts " - random"
      post.puts "---"
      post.puts "Summary of your post that shows up in the preview."
      post.puts "<!--break-->"
      post.puts "Put here the main body of your post."
    end

    system(options[:editor], filename)
  end
end
