#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'fileutils'

earth_view_dir = File.join(ENV['HOME'], "Pictures", "earth_view")
json_file = File.join(earth_view_dir, "earth_view.json")
json_url = "https://raw.githubusercontent.com/limhenry/earthview/master/wallpaper%20changer/data.json"

if !File.exist?(json_file) || File.stat(json_file).mtime < Time.now - 24 * 3600
  data = open(json_url).read rescue nil
  File.open(json_file, "w"){|f| f.puts data } if data
end

return unless File.readable?(json_file)

def get_name(image)
  name  = image["ID"].to_s + " - "
  name += image["Region"] + ", " if image["Region"] != "-"
  name += image["Country"]
  name += ".jpg"
end

data  = File.read(json_file).force_encoding('UTF-8')
image = JSON.parse(data).sample
url   = "https://" + image["Image URL"]
path  = File.join(earth_view_dir, get_name(image))

unless File.exist?(path)
  data = open(url).read rescue nil
  File.open(path, "wb"){|f| f.puts data} if data
  path = nil unless data
end

path ||= Dir.glob(File.join(earth_view_dir, "*.jpg")).sample
puts File.basename(path)
