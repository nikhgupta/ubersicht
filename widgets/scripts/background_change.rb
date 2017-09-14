#!/usr/bin/env ruby

require 'fileutils'

select = ARGV[0]

backgrounds = [
  { enabled: 1, name: "MapBox", path: "mapbox.widget/index.coffee" },
  { enabled: 0, name: "Grid", path: "backgrounds.widget/bg_grid.coffee" },
  { enabled: 1, name: "EarthView", path: "backgrounds.widget/earth-view.coffee" },
  { enabled: 0, name: "Matrix", path: "backgrounds.widget/matrix.coffee" },
  { enabled: 1, name: "Flickr", path: "backgrounds.widget/flickr-wall.coffee" }
].select{|a| a[:enabled] > 0}

def active?(path)
  name = path.gsub(/[^a-zA-Z0-9]/, '-')
  scpt = "tell application \"Übersicht\" to get hidden of widget id \"#{name}\""
  `osascript -e '#{scpt}'`.strip == "false"
end

def modify_script(path, hide: true)
  name = path.gsub(/[^a-zA-Z0-9]/, '-')
  if active?(path) == hide
    script = "tell application \"Übersicht\" to set hidden of widget id \"#{name}\" to #{hide}"
  else
    script = "tell application \"Übersicht\" to refresh widget id \"#{name}\""
  end
  `osascript -e '#{script}'`
end

backgrounds.each{|bg| bg[:active] = active?(bg[:path])}

activate   = backgrounds.detect{|i| i[:path] == select}
activate ||= backgrounds.reject{|i| i[:active]}.sample || backgrounds.sample
backgrounds.each do |bg|
  modify_script(bg[:path], hide: activate[:name] != bg[:name])
end
puts "Activated: #{activate[:name]}"
