command: "ruby scripts/zoho_timesheets.rb"
refreshFrequency: 15*60*1000

render: -> """
  <div class="zoho-timesheets-chart" class="line chart">
    <canvas class="zoho-chart-area" width="1200" height="60"></canvas>
    <div class="zoho-this-month">...</div>
    <div class="zoho-notice">
      <div class="main"></div>
      <div class="sub">
        I'm ugly. I'm very ugly.<br/>
        Suddenly, you are having a great urge to hide me.</br>
        Why not do some work, instead, and I am promise to go away..
      </div>
    </div>
  </div>
"""

addChart: (app, domEl, data, options) =>
  ctx = $(domEl).find(".zoho-chart-area")
  window.chart = new Chart ctx, type: "bar", data: data, options: options
  $(".zoho-this-month").on 'click', =>
    app.run "open 'https://books.zoho.in/app' -a 'Google Chrome.app'"

afterRender: (domEl) ->
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
  setTimeout (=> @addChart(@, domEl, data, options)), 2000

updateChart: (json) =>
  for key, idx in ["billable", "unbillable", "cap", "cap2"]
    window.chart.data.datasets[idx].data = json[key]
  window.chart.update()
  total = json?.hours_daily
  today = json.billable?.slice(-1)?[0]?.y
  if total? and total > 0
    $(".zoho-this-month").html(json?.hours_this_month + " hrs")
    if total < 2 and today < 4
      setTimeout ( =>
        $(".zoho-notice .main").html("Are we not working this month?")
        $(".zoho-notice .main, .zoho-notice .sub").fadeIn()
      ), 1000
    else if today < 3
      setTimeout ( =>
        $(".zoho-notice .main").html("You are not done for the day!")
        $(".zoho-notice .main, .zoho-notice .sub").fadeIn()
      ), 1000
    else
        $(".zoho-notice .main, .zoho-notice .sub").fadeOut()

update: (output, domEl) ->
  json = JSON.parse(output)
  setTimeout (=> @updateChart(json)), 3000

style: """
  color: white

  .zoho-timesheets-chart
    bottom: 0px;
    left: 0%;
    padding 0px
    width 100%
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    z-index 5

  .zoho-this-month
    bottom 70px
    left: 260px;
    padding 0px
    position: fixed;
    box-sizing: border-box;
    align-items: center;
    color rgba(250,250,250,0.4)
    z-index 10

  .zoho-notice
    top 0
    left 0
    height 25%
    width 100%
    position fixed
    display flex
    align-items center
    justify-content center
    padding 20px 20px 20px 220px
    box-size border-box
    z-index 11
    font-size 32px
    background-color rgba(0,0,0,0.8)
    .main
      color red
      display none
    .sub
      padding 40px
      font-size 14px
      color #ccc
      text-align right

"""
