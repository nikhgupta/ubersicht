command: "ruby scripts/equity_monitor.rb"
refreshFrequency: 30*60*1000

render: -> """
  <div id="equity-chart" class="line chart">
    <canvas class="equity-chart-area" width="1440" height="800"></canvas>
    <div class="equity-value">...</div>
  </div>
"""

addChart: (app, domEl, data, options) =>
  ctx = $(domEl).find(".equity-chart-area")
  window.chart = new Chart ctx, type: "line", data: data, options: options
  $(domEl).find(".equity-value").on 'click', =>
    app.run "open http://139.162.54.214/view/default -a 'Google Chrome.app'"

afterRender: (domEl) ->
  color1 = "rgba(255,255,100,0.6)"
  color2 = "rgba(255,100,100,0.6)"
  datasets = [{ label: "btc", data: [], fill: false, pointRadius: 0, borderColor: color1, backgroundColor: color1, yAxisID: "BTC"}]
  data     = { datasets: datasets }
  options  = { legend: { display: false }, scales: { xAxes: [{ type: 'time', display: false, }], yAxes: [{ id: "BTC", display: false, type: 'linear', position: 'left'}, { id: "USD", display: false, type: 'linear', position: 'right'}]}}
  setTimeout (=> @addChart(@, domEl, data, options)), 1000

updateChart: (json) =>
  for key, idx in ["btc"]
    window.chart.data.datasets[idx].data = json[key]
  window.chart.update()
  if json.equity > 0
    $(".equity-value").html(json.equity + " BTC (" + json.time_to_1btc + ")")

update: (output, domEl) ->
  json = JSON.parse(output)
  # keep the last 60 points in view
  setTimeout (=> @updateChart(json)), 2000

style: """
  color: white

  #equity-chart
    top: 0px;
    left: 0px;
    padding 0px
    width 100%
    height calc(100% - 120px)
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    z-index 5

  .equity-value
    bottom 70px
    left: 40px;
    padding 0px
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    color rgba(250,250,250,0.4)
"""
