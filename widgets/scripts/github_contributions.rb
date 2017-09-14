#!/usr/bin/env ruby

require 'open-uri'

url = "https://github.com/users/nikhgupta/contributions"
puts "<div><h3>Github Contributions</h3>#{open(url).read}</div>"
