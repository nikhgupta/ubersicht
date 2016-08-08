iconColor: "white"

normalIcons:
  finder:    "open -a Finder.app"
  "Contacts": "open ~"
  "Archiver": "open ~/Downloads"

  sep1: ""
  mail:      "open -a Mail.app",
  chrome_v2: "open -a 'Google Chrome.app'"
  skype: "open -a Skype.app"
  textedit: "open -a VimR.app"
  utorrent: "open -a uTorrent.app"
  # vlc_v2: "open -a VLC.app"
  "PopcornTime": "open -a PopcornTime.app"

  # dropbox: "open ~/Dropbox"
  # imovie: "open ~/Movies"
  # itunes: "open ~/Music"
  # photos: "open ~/Pictures"
  # appcleaner: "open /Applications"
  # applescript: "open ~/Code"

  sep2: ""
  # "Calendar": "open -a Calendar.app"
  # reminders_V2: "open -a Reminders.app"
  # notes: "open -a Notes.app"
  photobooth: "open -a Photos.app"
  googleMusicManager: "open -a iTunes.app"
  messages_v2: "open -a Messages.app"
  facetime: "open -a Facetime.app"
  # "Keynote": "open -a Keynote.app"
  # "Numbers": "open -a Numbers.app"
  # "Documents_v4": "open ~/Documents"
  # "pages": "open -a pages.app"
  # safari_solid_v2: "open -a Safari.app"
  # appstore: "open -a 'App Store.app'"

  sep3: ""
  terminal:  "open -a iTerm.app"
  timemachine: "open /System/Library/PreferencePanes/TimeMachine.prefpane"
  activitymonitor: "open -a 'Activity Monitor.app'"
  # systeminformation: "open -a 'System Information.app'"

  # bluetoothfileexchange: "open -a 'Bluetooth File Exchange.app'"
  # diskutility: "open -a 'Disk Utility.app'"
  # "AirportUtility": "open -a 'Airport Utility.app'"
  # "AndroidFileTransfer": "open -a 'Android File Transfer.app'"
  # "Notability": "open -a SimpleNote.app"

  # sep4: ""
  # github: "open 'https://github.com/nikhgupta'"
  # facebook: "open 'https://facebook.com/nikhgupta'"

specialIconMap: [ "Drive_External", "Drive_TimeMachine", "Drive_USB2", "trash_empty/full" ]
requireInputMap: [ "googlemaps" ]

command: ""
refreshFrequency: false

iconHtml: (icon) -> "<li class='button' data-icon='#{icon}'><img src='__icons/#{@iconColor}/#{icon}.png' /></li>"

render: -> """
  <ul class="dock-list #{@iconColor}-list">
    #{( @iconHtml(icon) for icon, command of @normalIcons ).join("")}
  </ul>
"""

afterRender: (domEl) ->
  self = @
  for icon, command of @normalIcons
    $(domEl).on 'click', "[data-icon='#{icon}']", ->
      self.run "#{self.normalIcons[$(@).data('icon')]}"

  $(domEl).find("[data-icon]").on 'click', ->
    $(@).addClass "clicked"
    setTimeout ( => $(@).removeClass 'clicked'), 1600

style: """
  &
    z-index: 1
    position: fixed
    bottom: 0
    left: 36%
    width: auto
    height: auto
    transform: translate(-30%,-50%)

  img
    height: 48px

  .button
    display: inline-block

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
