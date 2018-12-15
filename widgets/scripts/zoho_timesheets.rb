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
time_entries = get_resource("projects/timeentries", key="time_entries")
time_entries = time_entries.group_by do |en|
  Time.parse(en['log_date']).to_i
end.sort_by{|d,_| d}.to_h
min_ts = time_entries.keys.min
max_ts = time_entries.keys.max

data = (min_ts..max_ts).step(86400).map do |ts|
  date = Time.at(ts).strftime("%Y-%m-%d")
  entries = time_entries[ts] || []
  entries = entries.map do |en|
    project = projects[en['project_id']]
    billable = en['is_billable'] && project['billing_type'] == 'based_on_project_hours'

    duration = (Time.parse(en['log_time']) - Time.parse("00:00"))/3600
    billable = billable ? duration : 0
    [billable, duration - billable, billable*project['rate']]
  end

  data = 3.times.map{|i| entries.map{|col| col[i]}.sum}.push(3)
  data = data.map{|entry| {x: date, y: entry}}
end

data = %w[billable unbillable revenue cap].map.with_index do |field, idx|
  [field, data.map{|item| item[idx]}]
end.to_h

puts data.to_json
