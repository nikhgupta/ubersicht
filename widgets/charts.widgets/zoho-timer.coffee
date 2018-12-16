command: "ruby scripts/zoho_timesheets.rb"
refreshFrequency: 15*60*1000

render: -> """
  <div id="zoho-timesheets-chart" class="line chart">
    <canvas class="zoho-chart-area" width="1200" height="60"></canvas>
  </div>
"""

afterRender: (domEl) ->
  ctx = $(domEl).find(".zoho-chart-area")
  color1 = "rgba(255,255,100,0.6)"
  color2 = "rgba(150,100,100,0.6)"
  color3 = "rgba(100,100,100,0.6)"
  color4 = "rgba(100,100,100,0.9)"
  datasets = [{ label: "billable", data: [], fill: false, pointRadius: 0, borderColor: color1, backgroundColor: color1},
              { label: "unbillable", data: [], fill: false, pointRadius: 0, borderColor: color2, backgroundColor: color2},
              { label: "cap", data: [], fill: false, pointRadius: 0, borderColor: color3, backgroundColor: color3},
              { label: "cap2", data: [], fill: false, type: 'line', pointRadius: 0, borderColor: color4, backgroundColor: color4}]
  data     = { datasets: datasets }
  options  = { legend: { display: false }, scales: { xAxes: [{ type: 'time', display: false, stacked: true }], yAxes: [{ display: false, stacked: true, type: 'linear', position: 'left', ticks: { min: 0, max: 3 }}]}}
  setTimeout (=> window.chart = new Chart ctx, type: "bar", data: data, options: options), 1000

updateChart: (json) =>
  for key, idx in ["billable", "unbillable", "cap", "cap2"]
    window.chart.data.datasets[idx].data = json[key]
  window.chart.update()


update: (output, domEl) ->
  json = JSON.parse(output)
  console.log(json)
  # keep the last 60 points in view
  setTimeout (=> @updateChart(json)), 2000

style: """
  color: white

  .chart
    bottom: 0px;
    left: 0%;
    padding 0px
    width 100%
    position: fixed;
    box-sizing: border-box;
    align-items: center;
"""
