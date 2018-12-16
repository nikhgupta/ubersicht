#!/usr/bin/env ruby
require 'json'
require 'httparty'

def get_resource(endpoint, key=nil)
  orgid, apikey = ENV['ZOHO_ORG_ID'], ENV['ZOHO_BOOKS_TOKEN']
  url = "https://books.zoho.in/api/v3/#{endpoint}?organization_id=#{orgid}"
  data = HTTParty.get(url, headers: {"Authorization": "Zoho-authtoken #{apikey}"})
  key ? data[key] : data[endpoint]
rescue StandardError
  []
end

data = {}
projects = get_resource("projects").map{|pr| [pr["project_id"], pr]}.to_h
time_entries = get_resource("projects/timeentries", key="time_entries")

if projects.any? && time_entries.any?
  time_entries = time_entries.group_by do |en|
    Time.parse(en['log_date']).to_i
  end.sort_by{|d,_| d}.to_h
  min_ts = time_entries.keys.min
  max_ts = time_entries.keys.max

  data = (min_ts-86400..Time.now.to_i+86400).step(86400).map do |ts|
    date = Time.at(ts).strftime("%Y-%m-%d")
    entries = time_entries[ts] || []
    entries = entries.map do |en|
      project = projects[en['project_id']]
      billable = en['is_billable'] && project['billing_type'] == 'based_on_project_hours'

      duration = (Time.parse(en['log_time']) - Time.parse("00:00"))/3600
      billable = billable ? duration : 0
      [billable, duration - billable, billable*project['rate']]
    end

    data = 3.times.map{|i| entries.map{|col| col[i]}.sum}.push(3, 3)
    data = data.map{|entry| {x: date, y: entry}}
  end

  data = %w[billable unbillable revenue cap cap2].map.with_index do |field, idx|
    [field, data.map{|item| item[idx]}]
  end.to_h
  data['hours_this_month'] = data['unbillable'].select{|k| Time.parse(k[:x]) >= (Date.today - 30).to_time}.map{|k|k[:y]}.sum
  data['hours_this_month'] +=  data['billable'].select{|k| Time.parse(k[:x]) >= (Date.today - 30).to_time}.map{|k|k[:y]}.sum
else
  data['billable'] = 31.times.map do |i|
    {x: (Time.now - i*86400).strftime("%Y-%m-%d"), y: 0}
  end
  data['cap'] = 90.times.map do |i|
    {x: (Time.now - i*86400).strftime("%Y-%m-%d"), y: 3}
  end
  data['cap2'] = data['cap'].map(&:clone)
  data['unbillable'] = data['revenue'] = data['billable']
  data['hours_this_month'] = 0
end

data["cap"][0]['y'] = 0
data["cap"][-1]['y'] = 0
data['hours_daily'] = (data['hours_this_month'].to_f/30).round(2)
data['hours_this_month'] = data['hours_this_month'].to_f.round(2)
puts data.to_json
