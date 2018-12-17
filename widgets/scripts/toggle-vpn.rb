
#!/usr/bin/env ruby

# Script to toggle VPN connection
require 'json'
require 'open-uri'
require 'packetfu'
require 'shellwords'

vpn_name = "nixalite-#{ARGV.first.downcase}" if !ARGV.first.to_s.strip.empty?
vpn_name = "nixalite" if vpn_name == "nixalite-sg"

script = <<-OSASCRIPT
tell application "Tunnelblick"
    get state of first configuration where name = "#{vpn_name}"
    if (result = "EXITING") then
      connect "#{vpn_name}"
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

`osascript -e #{Shellwords.escape(script)}`

puts `ruby #{ENV['HOME']}/Code/dotcastle/ubersicht/widgets/scripts/ip-address.rb`
