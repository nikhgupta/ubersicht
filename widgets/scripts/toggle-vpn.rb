
#!/usr/bin/env ruby

# Script to toggle VPN connection
require 'json'
require 'open-uri'
require 'packetfu'
require 'shellwords'

vpn_name = "nixalite-#{ARGV.first.downcase}" if !ARGV.first.to_s.strip.empty?
vpn_name = "nixalite" if vpn_name == "nixalite-sg"

def get_external_ip(print: true)
  url = "https://extreme-ip-lookup.com/json/"
  res = JSON.parse(open(url).string)
  location = [ res['city'], res['region'], res['country'] ].detect{|a| !a.strip.empty?}
  puts "Current IP: #{"%15s" % res['query']}<br/>Location: #{location}"
  res
end

script = <<-OSASCRIPT
tell application "Tunnelblick"
    get state of first configuration where name = "#{vpn_name}"
    if (result = "EXITING") then
      connect #{vpn_name}
      repeat until result = "CONNECTED"
          delay 1
          get state of first configuration where name = "#{vpn_name}"
      end repeat
    else
      disconnect all
      repeat until result = "EXITING"
          delay 1
          get state of first configuration where name = "#{vpn_name}"
      end repeat
    end if
end tell
OSASCRIPT

`osascript -e #{Shellwords.escape(script)} &>/dev/null`

get_external_ip
