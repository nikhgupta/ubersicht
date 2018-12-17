#!/usr/bin/env ruby
require 'json'
require 'httparty'

data = HTTParty.get("http://139.162.54.214/data/default/all.json") rescue {}
data = data.map{|k, v| [k, v.map{|item| {x: Time.parse(item[0]).strftime("%Y-%m-%d"), y: item[1]}}]}.to_h
data = data.map{|k,v| [k, v[-31..-1]]}.to_h
data["equity"] = data["btc"][-1][:y].to_f rescue 0
data["last_equity"] = data["btc"][-2][:y].to_f rescue 0
data["last_equity_30"] = data["btc"][-31][:y].to_f rescue 0
data['pct_gain'] = (data['equity']/data['last_equity']*100 - 100).round(2) rescue 0
data['pct_gain_30'] = ((data['equity']/data['last_equity_30'])**(1.0/30)*100 - 100) rescue 0
data['time_to_1btc'] = data['pct_gain_30'] > 0 ? (Math.log(1.0/data['equity'])/Math.log(1+data['pct_gain_30']/100.0)) : 0
data['time_to_1btc'] = (Time.now + data['time_to_1btc']*86400).strftime("%d/%m/%Y")
puts data.to_json
