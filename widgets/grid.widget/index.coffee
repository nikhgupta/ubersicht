animation: "tada"
animationTimeout: 2000

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
  { icon: "th",          enabled: 1, toggle: "backgrounds.widget/bg_grid.coffee"}
  { icon: "microchip",   enabled: 1, toggle: "system.widgets/htop.coffee"}
  { icon: "shield",      enabled: 1, script: "ruby scripts/toggle-vpn.rb SG" }
  { icon: "lock",        enabled: 1, script: "osascript -e 'tell application \"System Events\" to keystroke \"q\" using {command down,control down}'" }

  { icon: "refresh",     enabled: 1, refresh: "" }
  { icon: "picture-o",   enabled: 1, timeout: 2000, script: "ruby scripts/background_change.rb" }
  { icon: "braille",     enabled: 1, toggle: "backgrounds.widget/matrix.coffee" }
  { icon: "flickr",      enabled: 1, script: "ruby scripts/background_change.rb backgrounds.widget/flickr-wall.coffee &>/dev/null" }

  # { icon: "wifi",        enabled: 0, script: "whoami" }
  # { icon: "heartbeat",   enabled: 0, type: "output", repeat: 1000, script: "whoami" }
  # { icon: "github",      enabled: 0, type: "html",   script: "ruby scripts/github_contributions.rb" }
  # { icon: "terminal",    enabled: 0, script: "output-from-terminal.rb" }

  # { icon: "envelope",    enabled: 0, script: "send-mail.rb" }
  # { icon: "map-marker",  enabled: 0, script: "map-given-location.rb" }
  # { icon: "sticky-note", enabled: 0, script: "take-note.rb" }
  # { icon: "headphones",  enabled: 0, script: "play-songs.rb" }

  # { icon: "linux",       script: "run-kali-on-virtualbox.rb" }
]

command: ""
refreshFrequency: false
currentXHR: null
currentTimer: null
res: "#result-area"

iconHtml: (option) ->
  "<li class='button icon' data-icon='#{option.icon}' data-state='0'
    data-type='#{if option.type? then option.type else ""}'
    data-enabled='#{option.enabled}' data-repeat='#{option.repeat?}'>
    <i class='fa fa-fw faa-#{@animation} fa-#{option.icon}'></i></li>"

render: -> """
  <ul class="list grid-list">
    #{( @iconHtml(option) for option in @gridMap ).join("")}
  </ul>
"""

afterRender: (domEl) ->
  self = @

  # make sure to toggle icons as to what is active or inactive

  $(domEl).on 'click', '.button[data-enabled="1"]', ->

    # set some variables to be used later
    icon = $(@).attr("data-icon")
    active = $(@).attr("data-state") == "1"
    mapping = $.grep(self.gridMap, (e) => e.icon == icon)?[0]
    togglable = mapping.type in ["output", "html"]

    # disable all animations, and set/remove animation on current Element
    $(domEl).find(".button .fa").removeClass("animated")
    $(@).find(".fa")[if active then "removeClass" else "addClass"]("animated")

    # if we have a togglable result area, and it is currently active, we disable
    # the active state and also, remove any relevant UI elements.
    if active && togglable
      $(@).attr("data-state": "0")
      $(@).find(".fa").removeClass("fa-active fa-spin")
      $(self.res).html("").removeAttr("class")
      self.abortTasks()
    else if !active && !togglable
      $(@).attr("data-state": "0")
      $(@).find(".fa").toggleClass("fa-active") if mapping.toggle > 0
      self.worker(mapping, @, togglable)
    else if !active
      $(domEl).find(".button").attr("data-state": "0")
      $(domEl).find(".fa").removeClass("fa-active fa-spin")
      $(self.res).html("").removeAttr("class").html("loading..").addClass("active")
      $(@).find(".fa").addClass("fa-active")
      $(@).attr("data-state": "1")
      self.abortTasks()
      if mapping.repeat?
        $(@).find(".fa").addClass("fa-spin")
        self.currentTimer = setInterval ( => self.worker(mapping, @, togglable)), mapping.repeat
      self.worker(mapping, @, togglable)

abortTasks: ->
  @currentXHR.abort() if @currentXHR
  clearInterval(@currentTimer) if @currentTimer

# When we are activating a task, lets run the specified command. If such
# a task is already active for "togglable" tasks, we cancel that task!
#
# Finally, we display the output for "togglable" tasks in a dedicated wide
# area, or for other tasks inside a notification.
#
worker: (mapping, el, togglable)->
  mapping.script = "./scripts/toggle_widget #{mapping.toggle}" if mapping.toggle
  mapping.script = "./scripts/refresh_widget #{mapping.refresh}" if mapping.refresh?

  @currentXHR = @run mapping.script, (se, so) =>
    setTimeout ( -> $(el).find(".fa").removeClass("animated")), @animationTimeout
    if togglable # and !$(@res).hasClass(mapping.icon)
      $(@res).addClass("#{mapping.type} active #{mapping.icon}").html(so)
    else if mapping.toggle
      $(el).find(".fa")[if so == "true" then "addClass" else "removeClass"]("fa-active")
    else if !togglable
      timeout = if mapping.timeout? then mapping.timeout else 10000
      toastr.error(se, null, {timeOut: timeout}) if se?.length > 0
      toastr.info(so, null, {timeOut: timeout}) if so?.length > 0 and !se?.length > 0

style: """
  &
    z-index: 10000
    position: fixed
    bottom: -10px
    right: 20px
    position: fixed
    height 200px
    width 200px

  .button
    display: inline-block
    background: #fff
    border-radius: 4px
    margin: 4px
    height: 42px
    width: 42px
    .fa
      color: #333333
      font-size: 28px
      padding: 8px
"""
