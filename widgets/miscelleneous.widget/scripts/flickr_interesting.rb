#!/usr/bin/env ruby

require 'json'
require 'date'
require 'open-uri'
require 'fileutils'

tolerance  = 50
flickr_dir = File.join(ENV['HOME'], "Pictures", "flickr")

w, h, r = ARGV[0].to_f, ARGV[1].to_f, ARGV[2] == "random"

url  = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1"
url += "&method=flickr.interestingness.getList&extras=views,url_h,url_k,description"
url += "&api_key=ec2b72cb5efb5802040fb6516136fbe5&per_page=500"

photos = JSON.parse(open(url).read)["photos"]["photo"] rescue []

photos = photos.map do |photo|
  next if photo["description"]["_content"].empty?

  ar = photo["width_h"].to_f/photo["height_h"].to_f
  next if (ar * h - w).abs > tolerance

  if photo["height_h"].to_i > h && photo["width_h"].to_i > w
    url = photo["url_h"]
  elsif photo["height_k"].to_i > h && photo["width_k"].to_i > w
    url = photo["url_k"]
  end

  { url: url, views: photo["views"].to_i, description: photo["description"]["_content"] }
end.compact

photo = r ? photos.sample : photos.sort_by{|a| a[:views]}[-1]

if photo
  path = File.join(flickr_dir, Date.today.to_s, File.basename(photo[:url]))
else
  path = Dir.glob(File.join(flickr_dir, "**", "*.jpg")).sample
end

return unless path

unless File.exist?(path)
  FileUtils.mkdir_p(File.dirname(path))
  pid = Process.spawn("wget -ct 3 '#{photo[:url]}' -O '#{path}' &>/dev/null")
  Process.wait pid
end

puts File.join(File.basename(File.dirname(path)),File.basename(path))
