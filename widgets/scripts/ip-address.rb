#!/usr/bin/env ruby

require 'httparty'
url = "http://ip-api.com/json"
data = HTTParty.get(url) rescue {}
ip = data['query']
loc = data['country']

if ip
  puts "#{ip}, #{loc}"
else
  puts "Not Connected!!"
end
