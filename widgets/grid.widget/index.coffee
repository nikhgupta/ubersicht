iconColor: "black"

gridMap: [
  { icon: "AirportUtility", script: "ip-address.rb" }
  { icon: "Github", script: "toggle-github-contributions.rb" }
  { icon: "finderV2", script: "toggle-proxy.rb" }
  { icon: "terminal", script: "output-from-terminal.rb" }

  { icon: "mail", script: "send-mail.rb" }
  { icon: "googlemaps", script: "map-given-location.rb" }
  { icon: "battlenet", script: "ip-address.rb" }
  { icon: "Facebook_V2", script: "post-to-facebook.rb" }

  { icon: "Notability", script: "take-note.rb" }
  { icon: "googleMusicManager", script: "play-songs.rb" }
  { icon: "Numbers", script: "show-financial-or-some-other-stats.rb" }
  { icon: "Drive_Server", script: "run-kali-on-virtualbox.rb" }

  { icon: "PopClip", script: "lock-screen.rb" }
  { icon: "systeminformation", script: "show-system-information.rb" }
  { icon: "soundconverter", script: "self-heartbeat.rb" }
  { icon: "selfcontrol", script: "toggle-self-control.rb" }
]


command: ""
refreshFrequency: false

iconHtml: (icon) -> "<li class='button' data-icon='#{icon}'><img src='__icons/#{@iconColor}/#{icon}.png' /></li>"

render: -> """
  <ul class="grid-list #{@iconColor}-grid">
    #{( @iconHtml(option.icon) for option in @gridMap ).join("")}
  </ul>
"""

afterRender: (domEl, _) ->
  $(domEl).find(".button").css("background-color", "rgba(255,255,255,0.8)") if @iconColor is "black"

style: """
  &
    z-index: 1
    position: fixed
    top: 30px
    left: 0px
    position: fixed

  ul
    width: 240px

  img
    height: 40px
    padding: 4px

  .button
    width: 48px
    height: 48px
    border-radius: 4px
    display: inline-block
    background-color: rgba(0,0,0,0.6)
    margin: 5px
    box-shadow: 1px 2px 2px rgba(0,0,0,0.3)

  .button.clicked
    animation: bounce 1.2s ease-out

  .button[data-icon^="sep"] img
    width: 0
    padding: 0 12px

  ul.black-list .button[data-icon^="sep"] img { width: 2px }

  @keyframes bounce
    0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
    40% { transform: translateY(-30px); }
    60% { transform: translateY(-15px); }
"""
