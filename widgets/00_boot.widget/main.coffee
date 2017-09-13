# Author: Nikhil Gupta
# Package: Ubersicht
#
# Ubersicht (meta)widget that sets up all the necessary dependencies, e.g.
# styles, scripts, fonts etc. to be used by other widgets. This must be loaded
# first by Ubersicht.
#
# `window.components` holds the html element for widgets that have been
# rendered, while `window.helpers` stores the global helper functions, if any.

command: ""
refreshFrequency: false

style: """
  top     0
  right   0
"""

afterRender: (domEl) ->
  styles = [
    "00_boot.widget/main.css",
    "00_boot.widget/font-awesome-animations.css",
    "__vendor/fonts/oswald.css",
    "__vendor/font-awesome-4.7.0/css/font-awesome.min.css",
    # "//api.mapbox.com/mapbox.js/v2.2.4/mapbox.css"
    # "__vendor/css/jquery.raty.css",
  ]

  scripts = [
    # "__vendor/js/flot/base.js",
    # "__vendor/js/flot/time.js",
    # "__vendor/js/jquery.raty.js",
    # # "__vendor/js/jquery.smooth.js",
    # "//api.mapbox.com/mapbox.js/v2.2.4/mapbox.js"
  ]

  for style in styles
    html = "<link rel='stylesheet' href='/#{style}' type='text/css'>"
    $("head link[rel='stylesheet']").last().after(html)

  for script in scripts
    html = "<script src='/#{script}.nouber' type='text/javascript' charset='utf-8'></script>"
    $("body").append(html)
