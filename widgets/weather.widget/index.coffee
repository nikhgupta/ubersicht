# Author: Nikhil Gupta
# Package: Ubersicht
#
# Ubersicht widget that displays current weather by querying the Forecast API.
# Widget has been adapted from the official `pretty-weather` widget.
# Widget refreshes itself every 10 minutes.

command: ""
refreshFrequency: 10 * 60 * 1000

apiKey: "7bfbdd0b2afba249dc155346dc22bfdf"

default_location:
  position: coords:
    latitude:  26.8836669
    longitude: 75.7347992
    accuracy:  63
  address:
    city:    'Jaipur'
    country: 'India'

dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

getDate: (utcTime) ->
  date  = new Date(0)
  date.setUTCSeconds(utcTime)
  date

iconMapping:
  "rain"                :"\uf019"
  "snow"                :"\uf01b"
  "fog"                 :"\uf014"
  "cloudy"              :"\uf013"
  "wind"                :"\uf021"
  "clear-day"           :"\uf00d"
  "mostly-clear-day"    :"\uf00c"
  "partly-cloudy-day"   :"\uf002"
  "clear-night"         :"\uf02e"
  "partly-cloudy-night" :"\uf031"
  "unknown"             :"\uf03e"

getIcon: (data) ->
  return @iconMapping['unknown'] unless data

  if data.icon.indexOf('cloudy') > -1
    if data.cloudCover < 0.25
      @iconMapping["clear-day"]
    else if data.cloudCover < 0.5
      @iconMapping["mostly-clear-day"]
    else if data.cloudCover < 0.75
      @iconMapping["partly-cloudy-day"]
    else
      @iconMapping["cloudy"]
  else
    @iconMapping[data.icon]

render: (_) -> """
  <div id='pretty-weather'>
    <div class='icon info'></div>
    <p class='meta'>
      <span class='location'></span> <span class='temp'></span><br/>
      <span class='summary'></span>
    </p>
  </div>
"""

update: (output, domEl) ->
  @getLocation (e) =>
    [lat, lon] = [e.position.coords.latitude, e.position.coords.longitude]
    query = "#{lat},#{lon}?units=auto&exclude=minutely,hourly,alerts,flags"
    @queryForecastApi query, (data) =>
      if (today = data?.daily?.data[0])?
        date = @getDate today.time
        $(domEl).find("span.temp").text Math.round(today.temperatureMax)+'°'
        $(domEl).find('span.summary').text today.summary
        $(domEl).find('div.icon').text @getIcon(today)
        $(domEl).find('span.location').show()
        $(domEl).find('span.location').text e.address.city + ", " + e.address.country
        $(domEl).fadeIn  'fast'
      else
        $(domEl).fadeOut 'fast'

### HELPERS ###########################################################

# Query the Forecast.io API.
queryForecastApi: (query, callback) ->
  command = "curl -sS 'https://api.forecast.io/forecast/#{@apiKey}/#{query}'"
  @run command, (stderr, stdout) =>
    if stderr?.indexOf("curl: (6)") == -1
      data = null
      console.log "ERROR: when executing forecast.io api: #{stderr}"
    else if !stderr?
      try
        data = JSON.parse(stdout)
      catch err
        data = null
        console.log "ERROR: when parsing response: #{err.message}"
    callback data

# Get data for the user's current location.
getLocation: (cb) ->
  return cb(@default_location) unless window.hasOwnProperty("geolocation")
  window.geolocation.getCurrentPosition (data) =>
    cb(if data then data else @default_location)

style: """
  &
    top 0
    right 0
    font-family: "Oswald", Berlin, Helvetica Neue
    color: #fff
    width 200px
    padding 20px
    text-align right
    overflow hidden
    height 116px
    z-index 1

  #pretty-weather
    float right

    @font-face
      font-family Weather
      src url(__vendor/fonts/pretty-weather.svg) format('svg')

    div.icon
      font-family Weather
      font-size 48px
      text-anchor middle
      alignment-baseline baseline
      padding-right 20px
      margin-bottom 10px

    p.meta
      margin 0

      span.temp
        font-size: 20px
        text-anchor: middle
        alignment-baseline baseline

      span.summary
        text-align right
        padding 12px 0 0
        margin-top -20px
        font-size 14px
        max-width 200px
        line-height 1.4em
        alignment-baseline baseline
"""
