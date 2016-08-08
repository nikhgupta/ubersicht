command: "ruby -e '
  require \"nokogiri\";
  require \"open-uri\";
  begin;
    html = Nokogiri::HTML(open(\"https://github.com/nikhgupta\"));
    puts html.search(\"div.flush\").last.to_s;
  rescue SocketError;
  end;
'"

refreshFrequency: 15 * 60 * 1000

style: """
  &
    z-index: 1
    top:   0
    left: -5px
    height: 100%
    width: 120px
    position: fixed

  .github-contributions
    font-family "Oswald"
    transform: rotate(90deg) translate(50%, 0)
    opacity: 0.5

  h3
    display: none
    font-size: 26px;
    color: #131;
    text-align: center;
    margin: 0;
    transform: rotate(-90deg) translate(-80px, -80px);

  h3 span
    float right
    font-size 0.7em
    padding-top 10px

  h3 span a
    color rgba(255,255,255,0.3)

  .boxed-group-inner
    background rgba(0,0,0,0.7)
    background transparent
    color #fff
    font-size 13px

  .calendar-graph
    height 126px
    text-align center

  svg:not(:root)
    overflow hidden

  .contrib-footer
    display none
    font-size 11px
    padding 0 10px 12px

  .contrib-column.contrib-column-first
    border-left none

  .contrib-column
    padding 15px 0
    text-align center
    border-left 4px solid rgba(0,0,0,0.3)
    border-top 4px solid rgba(0,0,0,0.3)
    font-size 11px

  .table-column
    display table-cell
    width 1%
    padding-right 10px
    padding-left 10px
    vertical-align top

  .contrib-number
    font-weight 300
    line-height 1.3em
    font-size 19px
    display block
    color #ddd

  rect,#contributions-calendar rect.day
    /* stroke: #111 */
    fill-opacity: 0.5
    shape-rendering crispedges

  #contributions-calendar rect.day[fill='#44a340'],
  #contributions-calendar rect.day[fill='#d6e685'],
  #contributions-calendar rect.day[fill='#8cc665'],
  #contributions-calendar rect.day[fill='#1e6823']
      fill-opacity: 0.7

  .calendar-graph text.month
    font-size 11px
    fill rgba(255,255,255,0.7)
    fill transparent
  .calendar-graph text.wday
    fill rgba(255,255,255,0.7)
    fill transparent
    font-size 9px

  .calendar-graph
    margin 0
  .calendar-graph.days-selected rect.day
    opacity 0.5
  .calendar-graph.days-selected rect.day.active
    opacity 1

  rect.max
    fill #ffc644
  g.bar
    fill #1db34f
  g.active rect
    fill #bd380f
  .left
    float left
  .text-muted
    color #aaa
"""

render: (output) -> """
  <div class="github-contributions">
    #{output}
  </div>
"""

afterRender: (domEl) ->
  window.components or= {}
  window.components.github_contrib = $(domEl)

  if $(domEl).find("#contributions-calendar .calendar-graph").length > 0
    html  = "<i class='fa fa-github darkred'></i> Github Commits "
    html += "<span><a href='https://github.com/nikhgupta'>@nikhgupta</a></span>"

    $(domEl).find("h3").html($(domEl).find("h3").text().replace(/[^\d+]/g, ''))
    $(domEl).find(".day[fill='#eeeeee']").attr("fill", "#111")
    $(domEl).fadeIn 'fast'

  else if $(domEl).find("#contributions-calendar .graph-loading").length > 0
    @refresh()
