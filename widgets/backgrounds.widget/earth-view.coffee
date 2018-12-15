command: "ruby scripts/background_earth_view.rb"
refreshFrequency: "10m"

render: (output) -> """
  <div class="earth-view-wallpaper"></div>
"""

update: (output, domEl) ->
  if output.length > 0
    img = new Image()
    $el = $(domEl)
    img.onload = ->
      $el.find("div").addClass('old')
      $div = $("<div class='container' />")
      $div.css "display": "none", "background-image": "url('#{img.src}')"
      $div.fadeIn 'slow', -> $el.find("div.old").remove()
      $div.append($("<div class='shadow' />"))
      $div.append($("<div class='overlay' />"))
      $el.append($div)
    img.src = "/images/earth_view/#{output}"

style: """
  position: absolute;
  z-index: -1001;
  left: 0px;
  top: 0px;
  width: 100%;
  height: 100%;
  background-color: rgba(0,0,0,0.6);
  color: white;

  div.container
    position: absolute;
    top: 0px;
    left: 0px;
    width: 100%;
    height: 100%;
    background-size: cover;
    div.shadow
      position: absolute;
      bottom: 0px;
      left: 0px;
      width: 100%;
      height: 25%;
      background: -webkit-linear-gradient(270deg, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 100%);
    div.overlay
      position: absolute;
      bottom: 0px;
      left: 0px;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.6)
"""
