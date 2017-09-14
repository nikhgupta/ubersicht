#!/usr/bin/env ruby

require 'open-uri'

url = "https://github.com/users/nikhgupta/contributions"
puts open(url).read
