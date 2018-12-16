command: "ruby scripts/equity_monitor.rb"
refreshFrequency: 30*60*1000

render: -> """
  <div id="equity-chart" class="line chart">
    <canvas class="equity-chart-area" width="1280" height="800"></canvas>
    <div class="equity-value"></div>
  </div>
"""

afterRender: (domEl) ->
  ctx = $(domEl).find(".equity-chart-area")
  color1 = "rgba(255,255,100,0.6)"
  color2 = "rgba(255,100,100,0.6)"
  datasets = [{ label: "btc", data: [], fill: false, pointRadius: 0, borderColor: color1, backgroundColor: color1, yAxisID: "BTC"},
              { label: "usd", data: [], fill: false, pointRadius: 0, borderColor: color2, backgroundColor: color2, yAxisID: "USD"}]
  data     = { datasets: datasets }
  options  = { legend: { display: false }, scales: { xAxes: [{ type: 'time', display: false, }], yAxes: [{ id: "BTC", display: false, type: 'linear', position: 'left'}, { id: "USD", display: false, type: 'linear', position: 'right'}]}}
  setTimeout (=> window.chart = new Chart ctx, type: "line", data: data, options: options), 1000

updateChart: (json) =>
  for key, idx in ["btc"]
    window.chart.data.datasets[idx].data = json[key]
  window.chart.update()
  $(".equity-value").html(json.btc.slice(-1)[0].y + " BTC")


update: (output, domEl) ->
  json = JSON.parse(output)
  console.log(json, json.btc.slice(-1))
  # keep the last 60 points in view
  setTimeout (=> @updateChart(json)), 2000

style: """
  color: white

  .chart
    bottom: 0px;
    left: 0px;
    padding 0px
    width 100%
    height 100%
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    z-index 10000

  .equity-value
    bottom 70px
    left: 40px;
    padding 0px
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    color rgba(250,250,250,0.4)
"""
