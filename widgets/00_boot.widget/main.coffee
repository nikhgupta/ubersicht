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

render: -> """
  <div id="result-area"></div>
"""

afterRender: (domEl) ->
  styles = [
    "node_modules/font-awesome/css/font-awesome.min.css",
    "node_modules/toastr/build/toastr.min.css",
    "00_boot.widget/main.css",
    "00_boot.widget/font-awesome-animations.css",
  ]

  scripts = [
    "node_modules/toastr/build/toastr.min.js",
  ]

  for style in styles
    html = "<link rel='stylesheet' href='/#{style}' type='text/css'>"
    $("head link[rel='stylesheet']").last().after(html)

  for script in scripts
    html = "<script src='/#{script}' type='text/javascript' charset='utf-8'></script>"
    $("body").append(html)

  if toastr?
    # toastr.options.timeOut = 0
    toastr.options.closeButton = true
    toastr.options.progressBar = true
    toastr.options.newestOnTop = true
    toastr.options.positionClass = "toast-bottom-right"

style: """
  top     0
  right   0
"""
