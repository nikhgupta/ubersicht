#!/usr/bin/env ruby

require 'httparty'

url = "https://extreme-ip-lookup.com/json/"
res = HTTParty.get(url) rescue {}
location = [ res['city'], res['region'], res['country'] ].detect{|a| !a.to_s.strip.empty?}
if res['query']
  puts "Current IP: #{"%15s" % res['query']}<br/>Location: #{location}"
else
  puts "Not Connected!!"
end
