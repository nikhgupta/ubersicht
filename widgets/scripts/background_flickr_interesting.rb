#!/usr/bin/env ruby

require 'json'
require 'date'
require 'open-uri'
require 'fileutils'

tolerance  = 50
flickr_dir = File.join(ENV['HOME'], "Pictures", "flickr")

date  = Date.today - rand * 1825 # 5 years
w, h, r = ARGV[0].to_f, ARGV[1].to_f, ARGV[2] == "random"

url  = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1"
url += "&method=flickr.interestingness.getList&extras=views,url_h,url_k,description"
url += "&api_key=ec2b72cb5efb5802040fb6516136fbe5&per_page=500&date=#{date}"

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

photos = photos.sort_by{|a| a[:views]}.reverse.take(3) unless r
url  = photos.sample[:url] rescue nil
path = File.join(flickr_dir, "#{date.strftime("%Y%m%d")}-#{File.basename(url)}") if url

if path && !File.exist?(path)
  FileUtils.mkdir_p(File.dirname(path))
  data = open(url).read rescue nil
  File.open(path, "wb"){|f| f.puts data} if data
  path = nil unless data
end

path ||= Dir.glob(File.join(flickr_dir, "*.jpg")).sample
puts File.basename(path)
