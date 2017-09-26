#!/usr/bin/env ruby
possible_endpoints = ["monitor", "sidekiq"]

require 'json'
require 'mechanize'

def parse_lsof_for(host: "127.0.0.1", filter: "TCP:listen",
                   program: nil, descriptors: "pnfc")
  data, item = [], {}
  command    = "lsof -bwaPi@#{host} -s#{filter} -F#{descriptors}"
  command   += " -c#{program}" unless program.to_s.strip.empty?
  output     = `#{command}`.strip.split("\n")

  output.each do |line|
    case line[0].to_sym
    when :p
      data << item unless item.empty?
      item = {pid: line[1..-1].to_i}
    when :c
      item.merge!(command: line[1..-1])
    when :n
      item[:hosts] ||= []
      item[:hosts] << line[1..-1]
    end
  end
  data << item

  data.select!{|i| i[:command] == program.to_s} unless program.to_s.strip.empty?
  data
end

data = parse_lsof_for(program: :ruby, host: "127.0.0.1")

unless data && data[0] && data[0][:hosts]
  puts "No server running for Ruby!"
  exit 1
end

agent = Mechanize.new do |a|
  a.read_timeout = 5
  a.open_timeout = 5
end

res = nil
possible_endpoints.each do |endpoint|
  data[0][:hosts].each do |host|
    url = "http://#{host}/#{endpoint}/stats"
    res = JSON.parse(agent.get(url).body)
    break if res
  end unless res
end

puts res["sidekiq"].to_json
