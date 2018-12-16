#!/usr/bin/env ruby
require 'json'
require 'httparty'

data = HTTParty.get("http://139.162.54.214/data/default/all.json")
data = data.map{|k, v| [k, v.map{|item| {x: Time.parse(item[0]).strftime("%Y-%m-%d"), y: item[1]}}]}.to_h
puts data.to_json
