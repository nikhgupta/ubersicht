# Author: Nikhil Gupta
# Package: Ubersicht
#
# Ubersicht widget that displays an interactive wallpaper for current location.
#
# Customizations Available:
# - Easy customization of initial map ZoomLevel
# - Easily disable or enable Mapbox Interactive Controls/Features
# - Randomly, use a theme from your favorite map themes, or choose one in particular.
# - Allows setting up a default location to be used when geolocation isn't available.
#
# Simulations Available:
# - Simulate movement of your location by setting 'fakeTravel' to true.
#
# Behind the scenes:
# - Automatic inclusion of Mapbox CSS and JS in the widget (could be improved).
# - Prevent calls to the Mapbox API if location isn't updated.
# - zoom control is sent to bottomright position.
# - attribution for the map is hidden.
# - geocoder is setup such that upon selecting a result, it is hidden.
# - fly to current location available
# - map keeps zooming itself out the longer you stay at a given location, such
# that each zoom out duration is twice the last one. Moreover, as soon as
# a change in location is detected, map fully zooms onto that location.
#
# Things to note:
# - The widget needs to have the lowest z-index to send it to background, but
# still you would want to keep the 'z-index' positive, so that you are able to
# interact with the map properly. Personally, 'z-index' for all other widgets is
# '1' in my setup, while for this widget it is '0'.
# - In order for the geocoder search feature to work, you can set the
# ubersicht interactive key to `^` (Ctrl), so that you can easily click, or add
# input in the geocoder form.
#
# Things to Add:
# - Track of last 24 hrs of navigation
# - zoom out interferes with map interaction
# - add more markers of interest - done
# - fix bug where map needs a reload to display missing tiles
#

zoomMinLevel: 7
zoomMaxLevel: 14
default_location: [26.8836669, 75.7347992]
mapboxJS: "//api.mapbox.com/mapbox.js/v2.4.0/mapbox.js"
mapboxCSS: "//api.mapbox.com/mapbox.js/v2.4.0/mapbox.css"
disableInteractions: ["keyboard", "scrollWheelZoom", "boxZoom"]
enableZoomOut: false
disableZoomControl: true
disableLocatorControl: false

# In order to see that the map works correctly, when moving, set the following
# to true and set a lower refreshFrequency
fakeTravel: false
refreshFrequency: 2 * 60 * 1000

# A list of your favorite mapbox themes. If 'useFixedTheme' is set, map will
# always use that particular theme, or otherwise will randomly choose one on
# each refresh of the widget.
useFixedTheme: 3
favoriteMapboxThemes: [
  "mapbox.b0v97egc"   # woodcut
  "mapbox.4iecw76a"   # space station
  "aj.03e9e12d"       # better pencil
  "mapbox.dark"       # dark theme
]

# pointsOfInterest: [
#   {
#     type: "Feature",
#     geometry:
#       type: "Point",
#       coordinates: [ 88.3465494, 22.5743445 ]
#     properties:
#       title: "Custom House"
#       description: "15/1, Strand Road, Kolkata WB"
#       icon:
#         html: "<div class='pin secondary'></div>"
#         className: ""
#         iconSize: null
#   }
#   {
#     type: "Feature"
#     geometry:
#       type: "Point"
#       coordinates: [88.3089369,22.5259265]
#     properties:
#       title: "Concor Terminal"
#       description: "Sonarpur Rd, Majerhat, Mominpore, Kolkata WB"
#       icon:
#         html: "<div class='pin secondary'></div>"
#         className: ""
#         iconSize: null
#   }
# ]

################################ WIDGET START ##################################

render: -> """
  <div id='mapbox' data-counter="0" data-zoom-level="#{@zoomMaxLevel}"></div>
"""

# Simply, injects the required CSS and JS for Mapbox. Since, this happens only
# once when the widget is, initially, rendered - this works fine, but still can
# be improved, significantly.
#
# Using AJAX for JS inclusion allows caching, which is really useful.
#
afterRender: (domEl, _) ->
  $("head link[rel='stylesheet']").last().after("<link rel='stylesheet' href='#{@mapboxCSS}' />")
  $.getScript @mapboxJS, => @updateOrShowMapbox('mapbox')


# `update` is, also, fired on the first rendering of the widget, after
# `afterRender`, but Mapbox isn't available at this moment, and hence, we skip
# it for this particular moment.
#
update: (domEl, _) -> @updateOrShowMapbox 'mapbox' if L?.mapbox?

# Primary logic for displaying the Mapbox.
#
# Note that, I call shell for obtaining the API key (more on that later).
#
# Storing the current coordinates allows us to compare them with next one, and
# prevent unuseful calls to the Mapbox API.
#
# Map is only initialized once, or Mapbox spits a warning/error. All
# initialization related code is run at this point.
#
updateOrShowMapbox: (el) ->
  _lat     = parseFloat $("#mapbox").attr("data-lat")
  _lon     = parseFloat $("#mapbox").attr("data-lon")
  _counter = parseFloat $("#mapbox").attr("data-counter")
  _zoom    = parseFloat $("#mapbox").attr("data-zoom-level")

  @getEnvironmentVariable "MAPBOX_API_TOKEN", (ev) =>
    L.mapbox.accessToken = ev
    @getGeoJson (coords, features) =>
      console.log _lat, _lon, _counter, _zoom, coords
      if _lat is coords[0] and _lon is coords[1]
        return unless @enableZoomOut
        zoomLevel = @getZoomLevel(_counter, _zoom)
        $("#mapbox").attr("data-counter", if zoomLevel == _zoom then _counter + 1 else 0)
        $("#mapbox").attr("data-zoom-level", zoomLevel)
        @map.setView(coords, zoomLevel)
      else
        $("#mapbox").attr("data-lat", coords[0])
        $("#mapbox").attr("data-lon", coords[1])
        $("#mapbox").attr("data-counter", 0)
        $("#mapbox").attr("data-zoom-level", @zoomMaxLevel)
        @setupMapbox(el, coords) unless @map?
        @map.setView(coords, @zoomMaxLevel)
        console.log features
        @layer.setGeoJSON features
        @map.fitBounds @layer.getBounds().pad(0.5) if @pointsOfInterest?.length > 0
        window.map = @map

# Setup Mapbox.
# - zoomControl is sent to bottomright position.
# - attributionControl is hidden.
# - disables controls/features as per user requested.
# - geocoder control is setup such that upon selecting a result, it is hidden.
# - add a layer that will hold our marker(s).
# - add a button that will take the user to its current location
#
setupMapbox: (el, coords) ->
  @map = L.mapbox.map(el, @mapboxTheme(), zoomControl: false, attributionControl: false)
  @map[interaction].disable() for interaction in @disableInteractions

  geocoder = L.mapbox.geocoderControl('mapbox.places', autocomplete: true, position: "bottomright")
  geocoder.addTo(@map).on 'found', (res) ->
    $("##{el}").innerHTML = JSON.stringify(res.results.features[0])
  geocoder.on 'select', (res) ->
    $(".leaflet-control-mapbox-geocoder-results a").fadeOut().remove()
    $(".leaflet-control-mapbox-geocoder-form input").val("")
  $("leaflet-control-mapbox-geocoder-results a").on 'click', -> e.preventDefault()

  L.control.zoom(position: 'bottomright').addTo(@map) unless @disableZoomControl
  @layer = L.mapbox.featureLayer().addTo(@map)
  @layer.on 'layeradd', (e) -> e.layer.setIcon(L.divIcon(e.layer.feature.properties.icon))
  @layer.on 'click', (e) => @map.panTo e.layer.getLatLng()
  @addLocatorButton() unless @disableLocatorControl

# Add a locator button to the map, which points to the current location of the
# user when clicked.
#
addLocatorButton: ->
  L.Control.Locator = L.Control.extend
    options: position: "bottomright", maxZoom: 15, app: null
    onAdd: (map) ->
      container = L.DomUtil.create('div', 'leaflet-control-locate leaflet-bar leaflet-control')
      @_map = map
      @_link = L.DomUtil.create('a', 'leaflet-bar-part leaflet-bar-part-single', container)
      @_icon = L.DomUtil.create('span', "fa fa-location-arrow", @_link)
      L.DomEvent.on @_link, 'click', (e) =>
        e.stopPropagation() and e.preventDefault()
        @options.app.getLocation? (coords) => @options.app.flyTo(coords, @options.maxZoom)
      container
  @map.addControl(new L.Control.Locator(maxZoom: @zoomMaxLevel, app: @))

# fly to a given location on map
flyTo: (coords, zoomLevel) ->
  @map.setView coords, zoomLevel,
  pan:  { animate: true, duration: 2 },
  zoom: { animate: true, duration: 2 }

# Convert the coordinates we obtained from `getLocation` to something that can
# be used up by the mapbox.
#
getGeoJson: (cb) ->
  @getLocation (coords) =>
    @pointsOfInterest ||= []
    features = @pointsOfInterest.concat([{
      type: 'Feature'
      geometry:
        type: "Point"
        coordinates: [coords[1], coords[0]]
      properties: icon:
        className: 'map-marker'
        html: "<div class='pin'></div><div class='pulse'></div>"
        iconSize: null
    }])
    cb(coords, features)

# Get data for the user's current location.
#
# Has support for faking user location - which helps a lot in development :)
# If geolocation isn't supported or unavailable, we fall back to default
# location specified by the user.
#
getLocation: (cb) ->
  console.log @
  if @fakeTravel
    _lat = parseFloat($("#mapbox").attr("data-lat")) || @default_location[0]
    _lon = parseFloat($("#mapbox").attr("data-lon")) || @default_location[1]
    return cb([_lat + 0.005, _lon + 0.005])

  return cb(@default_location) unless window.hasOwnProperty("geolocation")
  window.geolocation.getCurrentPosition (data) =>
    cb(if data then [data.position.coords.latitude, data.position.coords.longitude] else @default_location)

# Note that, I store my environment variables in '~/.zshenv.local', which isn't
# versioned, but is still loaded by interactive programs, and which contains:
#
#   export MAPBOX_API_TOKEN="some-token"
#   launchctl setenv MAPBOX_API_TOKEN "some-token"
#
getEnvironmentVariable: (str, cb) ->
  @run "zsh -cl 'echo $#{str}'", (stderr, stdout) =>
    if stderr?
      console.log "Error retrieving environment variable: #{stderr}"
    else
      cb $.trim(stdout)

# get Zoom Level based on how long we have been sitting idle in this location
getZoomLevel: (counter, zoom) ->
  return @zoomMinLevel if zoom <= @zoomMinLevel
  if counter > ((@zoomMaxLevel - zoom) + 1) ** 2 then zoom - 1 else zoom

# Choose a theme specified by the user, or randomly.
mapboxTheme: ->
  return @favoriteMapboxThemes[@useFixedTheme - 1] if @useFixedTheme?
  @favoriteMapboxThemes[Math.floor(Math.random() * @favoriteMapboxThemes.length)]

style: """
  &
    z-index: 0
    width 100%
    height 100%

  #mapbox
    top 0
    left 0
    width 100%
    height 100%
    position: absolute
    cursor: default
    &:after
      content: ""
      display: block
      position: absolute
      top: 0
      left: 0
      height: 100%
      width: 100%
      background-color: rgba(0,0,0,0.7)
      pointer-events: none
    .mapbox-logo
      display none
    .leaflet-control-locate a
      padding: 3px 7px
      font-size: 14px

  .pin
    width 30px
    height 30px
    border-radius 50% 50% 50% 0
    background #000
    position absolute
    transform rotate(-45deg)
    left 50%
    top 50%
    margin -20px 0 0 -20px
    &:after
      content ''
      width 14px
      height 14px
      margin 8px 0 0 8px
      background #ff0
      position absolute
      border-radius 50%
    &.secondary
      background #08f
      &:after
        background #048

  .pulse
    background rgba(0,0,0,0.2)
    border-radius 50%
    height 14px
    width 14px
    position absolute
    left 50%
    top 50%
    margin 11px 0px 0px -12px
    transform rotateX(55deg)
    z-index -2
    &:after
      content ""
      border-radius 50%
      height 40px
      width 40px
      position absolute
      margin -13px 0 0 -13px
      animation pulsate 120s ease-out
      animation-iteration-count infinite
      opacity 0.0
      box-shadow 0 0 1px 2px #000
      animation-delay 1.1s

  @keyframes pulsate
    0%
      transform scale(0.1, 0.1)
      opacity 0.0
    50%
      opacity 1.0
    100%
      transform scale(1.2, 1.2)
      opacity 0
"""
