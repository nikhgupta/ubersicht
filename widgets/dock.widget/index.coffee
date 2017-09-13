animation: "tada"
animationTimeout: 2000

# You can add scripts to `scripts` folder inside this widget.
# Commands are run by first changing to this directory. For example, specifying:
#
#   { icon: "apple", enabled: 1, script: "open -a Finder.app" }
#
# will run:
#
#   cd ./dock.widget/scripts; open -a Finder.app
#
dockMap: [
  { icon: "apple",         enabled: 1, script: "open -a Finder.app" }
  { icon: "home",          enabled: 1, script: "open ~" }
  { icon: "download",      enabled: 1, script: "open ~/Downloads" }
  { icon: "envelope",      enabled: 1, script: "open -a Mail.app" }
  { icon: "chrome",        enabled: 1, script: "open -a 'Google Chrome.app'" }
  { icon: "skype",         enabled: 1, script: "open -a Skype.app" }
  { icon: "pencil-square", enabled: 1, script: "open -a VimR.app" }
  { icon: "play-circle",   enabled: 1, script: "open -a VLC.app" }
  { icon: "headphones",    enabled: 1, script: "open -a iTunes.app" }
  { icon: "comments",      enabled: 1, script: "open -a Messages.app" }
  { icon: "telegram",      enabled: 1, script: "open -a 'Telegram Desktop.app'" }
  { icon: "video-camera",  enabled: 1, script: "open -a Facetime.app" }
  { icon: "terminal",      enabled: 1, script: "open -a iTerm.app" }
  { icon: "clock-o",       enabled: 1, script: "open /System/Library/PreferencePanes/TimeMachine.prefpane" }
  { icon: "tachometer",    enabled: 1, script: "open -a 'Activity Monitor.app'" }
  { icon: "book",          enabled: 1, script: "open -a SimpleNote.app" }
]

# otherIcons:
  # torrent: "open -a uTorrent.app"
  # popcorn: "open -a PopcornTime.app"

  # dropbox: "open ~/Dropbox"
  # movie: "open ~/Movies"
  # music: "open ~/Music"
  # images: "open ~/Pictures"
  # documents: "open ~/Documents"
  # apps: "open /Applications"
  # code: "open ~/Code"

  # calendar: "open -a Calendar.app"
  # reminders: "open -a Reminders.app"
  # notes: "open -a Notes.app"
  # photos: "open -a Photos.app"
  # keynote: "open -a Keynote.app"
  # numbers: "open -a Numbers.app"
  # pages: "open -a pages.app"
  # safari: "open -a Safari.app"
  # appstore: "open -a 'App Store.app'"

  # system: "open -a 'System Information.app'"

  # bluetooth: "open -a 'Bluetooth File Exchange.app'"
  # diskutility: "open -a 'Disk Utility.app'"
  # wifi: "open -a 'Airport Utility.app'"
  # android: "open -a 'Android File Transfer.app'"

  # github: "open 'https://github.com/nikhgupta'"
  # facebook: "open 'https://facebook.com/nikhgupta'"

command: ""
refreshFrequency: false

iconHtml: (option) ->
  "<li class='button' data-icon='#{option.icon}'
    data-enabled='#{option.enabled}' data-script='#{option.script}'>
  <i class='fa fa-fw faa-#{@animation} fa-#{option.icon}'></i></li>"

render: -> """
  <ul class="dock-list">
    #{( @iconHtml(option) for option in @dockMap ).join("")}
  </ul>
"""

afterRender: (domEl) ->
  self = @
  for option in @dockMap
    $(domEl).on 'click', "[data-icon='#{option.icon}'][data-enabled=1]", ->
      unless $(@).find('i').hasClass "animated"
        $(@).find('i').addClass "animated"
        setTimeout ( => $(@).find('i').removeClass 'animated'), self.animationTimeout
        setTimeout ( =>
          mapping = $.grep(self.dockMap, (e) => e.icon == $(@).data('icon'))?[0]
          self.run "cd ./dock.widget/scripts; #{mapping.script}"
        ), 500

style: """
  &
    z-index: 1
    position: fixed
    bottom: 0
    left: 36%
    width: auto
    height: auto
    transform: translate(-30%,-50%)

  .button
    display: inline-block
    .fa
      color: #efefef
      font-size: 36px
      padding: 4px
"""
