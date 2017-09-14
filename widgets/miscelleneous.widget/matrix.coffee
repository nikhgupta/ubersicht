# For use with Übersicht ==> http://tracesof.net/uebersicht/
# Coded by Porco-Rosso ==> https://github.com/Porco-Rosso
# from Stereostance.com
# v1.0.0
# GNU GPL V2

command: ""

refreshFrequency: 138000

render: (output) -> """<canvas id="matrix-bg"></canvas>"""

afterRender: (output, domEl) ->
  q = document.getElementById('matrix-bg')
  w = q.width  = window.screen.width
  h = q.height = window.screen.height
  p = Array(256).join(1).split('')
  c = q.getContext('2d')
  setInterval (->
    c.fillStyle = 'rgba(0,0,0,0.05)'
    c.fillRect 0, 0, w, h
    c.fillStyle = 'rgba(0,255,0,1)'
    p = p.map (v, i) ->
      r = Math.random()
      c.fillText String.fromCharCode(Math.floor(2720 + r * 33)), i * 10, v
      v += 10
      if v > 768 + r * 1e4 then 0 else v
  ), 33

# Adjust the opacity value if you would still like to see your wallpaper behind the visualization
style: """
  top: 0px
  left: 0px
  z-index: -100
  opacity: 0.6

  canvas
    width 1440px
    height 900px
    background-color #333
"""
