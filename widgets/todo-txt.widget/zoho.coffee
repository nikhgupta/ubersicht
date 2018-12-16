# Author: Nikhil Gupta
# Package: Ubersicht
#
# Ubersicht widget that displays current weather by querying the Forecast API.
# Widget has been adapted from the official `pretty-weather` widget.
# Widget refreshes itself every 10 minutes.

command: "ruby scripts/zoho_projects.rb"
refreshFrequency: 15 * 60 * 1000

render: (_) -> """
"""

update: (output, domEl) ->
  html = "<div id='zoho-projects'>#{output}</div>"
  $(domEl).html(html)

style: """
  &
    top 0px
    left 0px
    width 100%
    margin 0px
    z-index 1
    overflow hidden
    font-family monospace
    color #B1B9BF
    text-align left

  #zoho-projects
    padding 20px
    .project
      color #fefefe
    .customer
      color #CE6644
"""

