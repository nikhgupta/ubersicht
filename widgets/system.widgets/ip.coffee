command: "ruby scripts/ip-address.rb"
refreshFrequency: '15s'

render: -> """
  <div class="ip-address"></div>
"""

afterRender: (domEl) ->
  $(domEl).on 'click', =>
    @run "open https://extreme-ip-lookup.com/json/ -a 'Google Chrome.app'"

update: (output, domEl) ->
  $(domEl).html(output)

style: """
  top: 10px
  left: 10px
  padding: 0 20px
  box-sizing: border-box
  color rgba(255,255,255,1)
  z-index 10
"""
