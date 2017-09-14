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
  { icon: "wifi",        enabled: 1, script: "ruby ip-address.rb" }
  { icon: "heartbeat",   enabled: 1, type: "output", refresh: 1000, script: "ruby ip-address.rb" }
  { icon: "github",      enabled: 1, type: "html",   script: "ruby github-contributions.rb" }
  { icon: "shield",      script: "toggle-proxy.rb" }
  { icon: "terminal",    script: "output-from-terminal.rb" }
  { icon: "envelope",    script: "send-mail.rb" }
  { icon: "map-marker",  script: "map-given-location.rb" }
  { icon: "user-secret", script: "ip-address.rb" }
  { icon: "facebook",    script: "post-to-facebook.rb" }
  { icon: "sticky-note", script: "take-note.rb" }
  { icon: "headphones",  script: "play-songs.rb" }
  { icon: "bar-chart",   script: "show-financial-or-some-other-stats.rb" }
  { icon: "linux",       script: "run-kali-on-virtualbox.rb" }
  { icon: "lock",        script: "lock-screen.rb" }
  { icon: "microchip",   script: "show-system-information.rb" }
  { icon: "user-times",  script: "toggle-self-control.rb" }
]


command: ""
refreshFrequency: false
currentXHR: null
currentTimer: null
res: "#result-area"

iconHtml: (option) ->
  "<li class='button icon' data-icon='#{option.icon}' data-state='0'
    data-type='#{if option.type? then option.type else ""}'
    data-enabled='#{option.enabled}' data-refresh='#{option.refresh?}'>
    <i class='fa fa-fw faa-#{@animation} fa-#{option.icon}'></i></li>"

render: -> """
  <ul class="list grid-list">
    #{( @iconHtml(option) for option in @gridMap ).join("")}
  </ul>
"""

afterRender: (domEl) ->
  self = @

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
      self.worker(mapping, @, togglable)
    else if !active
      $(domEl).find(".button").attr("data-state": "0")
      $(domEl).find(".fa").removeClass("fa-active fa-spin")
      $(self.res).html("").removeAttr("class").html("loading..").addClass("active")
      $(@).find(".fa").addClass("fa-active")
      $(@).attr("data-state": "1")
      self.abortTasks()
      if mapping.refresh?
        $(@).find(".fa").addClass("fa-spin")
        self.currentTimer = setInterval ( => self.worker(mapping, @, togglable)), mapping.refresh
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
  command = "cd ./grid.widget/scripts; #{mapping.script}"
  @currentXHR = @run command, (se, so) =>
    console.log(se, so)
    setTimeout ( -> $(el).find(".fa").removeClass("animated")), @animationTimeout
    if togglable # and !$(@res).hasClass(mapping.icon)
      $(@res).addClass("#{mapping.type} active #{mapping.icon}").html(so)
    else if !togglable
      timeout = if mapping.timeout? then mapping.timeout else 10000
      toastr.error(se, null, {timeOut: timeout}) if se?
      toastr.info(so, null, {timeOut: timeout}) if so?

style: """
  &
    z-index: 1
    position: fixed
    top: 50px
    left: 50px
    position: fixed
    height 200px
    width 200px

  ul
    margin 0
    padding 0

  .button
    display: inline-block
    background: #fff
    border-radius: 4px
    margin: 4px
    .fa
      color: #333333
      font-size: 28px
      padding: 8px
"""
