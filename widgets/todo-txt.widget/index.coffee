# Author: Nikhil Gupta
# Package: Ubersicht
#
# Ubersicht widget that displays current weather by querying the Forecast API.
# Widget has been adapted from the official `pretty-weather` widget.
# Widget refreshes itself every 10 minutes.

command: "python scripts/todo_txt_parser.py ~/Documents/todo/todo.txt"
refreshFrequency: 10 * 60 * 1000

render: (_) -> """
"""

update: (output, domEl) ->
  html = "<div id='todo-txt'>#{output}</div>"
  $(domEl).html(html)

style: """
  &
    bottom 0px
    right 0px
    width 1440px
    margin 0px
    z-index 1
    overflow hidden
    background rgba(0, 0, 0, 0.7)
    font-family monospace
    color #B1B9BF

  #todo-txt
    padding 20px
    .column
      width 640px
      padding 20px
      float left
    .column.major
      font-size: 3.2em;
      text-align: center;
      vertical-align: middle;
      color:#e0f0f0
    .context
      color #CC9F45
    .project
      color #CE6644

    .task
      font-size 1em
    .task.priority-c
      .priority
        font-weight bold
        color #DFCC74
    .task.priority-b
      .priority
        font-weight bold
        color #1C7C54
    .task.priority-a
      font-weight bold
      .priority
        font-weight bold
        color #9E1F30
"""
