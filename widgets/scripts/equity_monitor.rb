#!/usr/bin/env ruby
require 'json'
require 'httparty'

data = HTTParty.get("http://139.162.54.214/data/default/all.json") rescue {}
data = data.map{|k, v| [k, v.map{|item| {x: Time.parse(item[0]).strftime("%Y-%m-%d"), y: item[1]}}]}.to_h
data["equity"] = data["btc"][-1][:y].to_f rescue 0
data["last_equity"] = data["btc"][-2][:y].to_f rescue 0
data['pct_gain'] = (data['equity']/data['last_equity']*100 - 100).round(2) rescue 0
puts data.to_json
