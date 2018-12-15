command: "ps -ecmo %mem,pid,rss,%cpu,command | " +
  "/usr/local/opt/coreutils/libexec/gnubin/numfmt " +
  "--header --to=iec --field 3 --from-unit 1024 | head"
refreshFrequency: 3000

render: -> """
  <div class="htop"><pre></pre></div>
"""

afterRender: (domEl) ->
  $(domEl).on 'click', =>
    @run "open -a 'Activity Monitor.app'"

update: (output, domEl) ->
  $(domEl).find("pre").html(output)

style: """
  top: 10px
  left: 10px
  padding: 0 20px
  box-sizing: border-box
  width: 350px
  height 200px
  background rgba(0,0,0,0.4)
  -webkit-mask-image: -webkit-radial-gradient(44% 35%, closest-corner, rgba(0,0,0,0.6) 20%, rgba(0,0,0,0))

  pre
    color: white
    white-space: pre
    font-family: "Ubuntu Mono", monospace !important
    font-weight: normal
    overflow hidden
"""
