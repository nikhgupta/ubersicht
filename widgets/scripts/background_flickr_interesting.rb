#!/usr/bin/env ruby

require 'json'
require 'date'
require 'open-uri'
require 'fileutils'

tolerance  = 50
FLICKR_DIR = File.join(ENV['HOME'], "Pictures", "flickr")

date = Date.today - rand * 1825 # 5 years
w, h = ARGV[0].to_f, ARGV[1].to_f

url  = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1"
url += "&method=flickr.interestingness.getList&extras=views,url_h,url_k,description"
url += "&api_key=#{ENV['FLICKR_KEY']}&date=#{date}&per_page=500"

def fetch_json(url)
  data = open(url, open_timeout: 5, read_timeout: 20).read
  data = JSON.parse(data)
  raise data["message"] if data["stat"] == "fail"
  data
rescue StandardError => e
  # STDERR.puts "[Flickr] #{e.class} - #{e.message} while fetching: #{url}"
  path = Dir.glob(File.join(FLICKR_DIR, "*.jpg")).sample
  puts File.basename(path)
  exit 0
end

if path = Dir.glob(File.join(FLICKR_DIR, "#{date.strftime("%Y%m%d")}-*.jpg")).sample
  puts File.basename(path)
  exit 0
end

photos = fetch_json(url)["photos"]["photo"]

photos = photos.map do |photo|
  next if photo["description"]["_content"].empty?

  ar = photo["width_h"].to_f/photo["height_h"].to_f
  next if (ar * h - w).abs > tolerance

  url = nil
  if photo["height_h"].to_i > h && photo["width_h"].to_i > w
    url = photo["url_h"]
  elsif photo["height_k"].to_i > h && photo["width_k"].to_i > w
    url = photo["url_k"]
  end

  next if !url || photo["views"].to_i < 5000
  { url: url, views: photo["views"].to_i, description: photo["description"]["_content"] }
end.compact

path = nil
photos = photos.sort_by{|a| -a[:views]}.take(3)

def get_photo(photo, date)
  path = File.join(FLICKR_DIR, "#{date.strftime("%Y%m%d")}-#{File.basename(photo[:url])}")
  if path && !File.exist?(path)
    FileUtils.mkdir_p(File.dirname(path))
    data = open(photo[:url], open_timeout: 5, read_timeout: 20).read rescue nil
    File.open(path, "wb"){|f| f.puts data} if data
  end
  File.basename(path) if path && data
end

path = get_photo(photos.shift, date) while path.nil?
# photos.each{|photo| Process.detach(Process.fork{ get_photo(photo, date) })}
path ||= Dir.glob(File.join(FLICKR_DIR, "*.jpg")).sample
puts File.basename(path)
