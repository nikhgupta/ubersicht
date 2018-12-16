#!/usr/bin/env ruby
require 'json'
require 'httparty'

def get_resource(endpoint, key=nil)
  orgid, apikey = ENV['ZOHO_ORG_ID'], ENV['ZOHO_BOOKS_TOKEN']
  url = "https://books.zoho.in/api/v3/#{endpoint}?organization_id=#{orgid}"
  data = HTTParty.get(url, headers: {"Authorization": "Zoho-authtoken #{apikey}"})
  key ? data[key] : data[endpoint]
end

projects = get_resource("projects").map{|pr| [pr["project_id"], pr]}.to_h

fixed  = projects.select{|id,pr| pr["billing_type"] == "fixed_cost_for_project" && pr["status"] == "active"}
hourly = projects.select{|id,pr| pr["billing_type"] == "based_on_project_hours" && pr["status"] == "active"}

print hourly.sort_by{|k,v| -v['rate']}.map{|k| "H <strong class='customer'>#{k[1]['customer_name']}</strong> - <span class='project'>#{k[1]["project_name"]}</span>"}.join("<br/>\n")
print "<br/>\n"
puts  fixed.sort_by{|k,v| -v['rate']}.map{|k| "F <strong class='customer'>#{k[1]['customer_name']}</strong> - <span class='project'>#{k[1]["project_name"]}</span>"}.join("<br/>\n")
