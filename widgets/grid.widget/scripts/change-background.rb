#!/usr/bin/env ruby

require 'fileutils'

backgrounds = [
  { enabled: 1, name: "MapBox", path: "mapbox.widget/index.coffee" },
  { enabled: 0, name: "Grid", path: "backgrounds.widget/bg_grid.coffee" },
  { enabled: 1, name: "EarthView", path: "backgrounds.widget/earth_view.coffee" },
  { enabled: 0, name: "Matrix", path: "backgrounds.widget/matrix.coffee" },
  { enabled: 1, name: "Flickr", path: "backgrounds.widget/flickr-wall.coffee" }
].select!{ |item| item[:enabled] > 0 }

ROOT_PATH = File.realpath(File.dirname(File.dirname(File.dirname(__FILE__))))

def modify_script(path, enable: false)
  path = File.join(ROOT_PATH, path)

  case
  when File.exist?(path) && enable
    FileUtils.mv(path, "#{path}.disabled")
  when File.exist?("#{path}.disabled") && enable
    FileUtils.mv("#{path}.disabled", path)
  end
end

active = backgrounds.sample
backgrounds.each do |bg|
  modify_script(bg[:path], enable: active[:name] == bg[:name])
end
puts "Activated: #{active[:name]}"
