animation: "burst"
animationTimeout: 3000

# You can add scripts to `scripts` folder inside this widget.
# Commands are run by first changing to this directory. For example, specifying:
#
#   { icon: "apple", enabled: 1, script: "ruby some-script.rb" }
#
# will run:
#
#   cd ./grid.widget/scripts; ruby some-script.rb
#
gridMap: [
  { icon: "wifi", script: "ruby ip-address.rb", enabled: 1 }
  { icon: "github", script: "toggle-github-contributions.rb" }
  { icon: "shield", script: "toggle-proxy.rb" }
  { icon: "terminal", script: "output-from-terminal.rb" }

  { icon: "envelope", script: "send-mail.rb" }
  { icon: "map-marker", script: "map-given-location.rb" }
  { icon: "user-secret", script: "ip-address.rb" }
  { icon: "facebook", script: "post-to-facebook.rb" }

  { icon: "sticky-note", script: "take-note.rb" }
  { icon: "headphones", script: "play-songs.rb" }
  { icon: "bar-chart", script: "show-financial-or-some-other-stats.rb" }
  { icon: "linux", script: "run-kali-on-virtualbox.rb" }

  { icon: "lock", script: "lock-screen.rb" }
  { icon: "microchip", script: "show-system-information.rb" }
  { icon: "heartbeat", script: "self-heartbeat.rb" }
  { icon: "user-times", script: "toggle-self-control.rb" }
]


command: ""
refreshFrequency: false

iconHtml: (icon, enabled=0) ->
  "<li class='button' data-icon='#{icon}' data-enabled='#{enabled}'>
  <i class='fa fa-fw faa-#{@animation} fa-#{icon}'></i></li>"

render: -> """
  <ul class="grid-list">
    #{( @iconHtml(option.icon, option.enabled) for option in @gridMap ).join("")}
  </ul>
"""

afterRender: (domEl) ->
  self = @
  for option in @gridMap
    $(domEl).on 'click', "[data-icon='#{option.icon}'][data-enabled=1]", ->
      unless $(@).find('i').hasClass "animated"
        $(@).find('i').addClass "animated"
        setTimeout ( => $(@).find('i').removeClass 'animated'), self.animationTimeout
        setTimeout ( =>
          mapping = $.grep(self.gridMap, (e) => e.icon == $(@).data('icon'))?[0]
          self.run "cd ./grid.widget/scripts; #{mapping.script}", (stderr, stdout) =>
            console.log("STDERR: #{stderr}") if stderr?
            console.log("STDOUT: #{stdout}") if stdout?
        ), 500

style: """
  &
    z-index: 1
    position: fixed
    top: 30px
    left: 0px
    position: fixed

  ul
    width: 240px

  .button
    display: inline-block
    background: #efefef
    border-radius: 4px
    margin: 4px
    .fa
      color: #333333
      font-size: 28px
      padding: 8px
"""
