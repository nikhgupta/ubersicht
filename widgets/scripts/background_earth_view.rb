#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'fileutils'

earth_view_dir = File.join(ENV['HOME'], "Pictures", "Ubersicht", "EarthView")
FileUtils.mkdir_p(earth_view_dir)
json_file = File.join(earth_view_dir, "earth_view.json")
json_url = "https://raw.githubusercontent.com/limhenry/earthview/master/wallpaper%20changer/data.json"

def fetch(url)
  open(url, open_timeout: 5, read_timeout: 20).read
end

def get_name(image)
  name  = image["ID"].to_s + " - "
  name += image["Region"] + ", " if image["Region"] != "-"
  name += image["Country"]
  name += ".jpg"
  name.gsub(/[^a-z0-9\.-_]/i, '-').gsub(/--+/, '-')
end

if !File.exist?(json_file) || File.stat(json_file).mtime < Time.now - 24 * 3600
  data = fetch(json_url) rescue nil
  File.open(json_file, "w"){|f| f.puts data } if data
end

return unless File.readable?(json_file)

data  = File.read(json_file).force_encoding('UTF-8')
image = JSON.parse(data).sample
url   = "https://" + image["Image URL"]
path  = File.join(earth_view_dir, get_name(image))

unless File.exist?(path)
  FileUtils.mkdir_p(File.dirname(path))
  data = fetch(url) rescue nil
  File.open(path, "wb"){|f| f.puts data} if data
  path = nil unless data
end

path ||= Dir.glob(File.join(earth_view_dir, "*.jpg")).sample
puts File.basename(path)
