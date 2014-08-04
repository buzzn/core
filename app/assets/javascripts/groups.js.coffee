$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  for register_chart in gon.register_charts
    $.plot $("#register_#{register_chart.id} #chart"), [register_chart['current']], {
      series:
        color: "white"
        points:
          show: true
        lines:
          show: true
          fill: true
          fillColor: "rgba(255,255,255, 0.1)"
        hoverable: true
        highlightColor: "rgba(255, 255, 255, 0.5)"
      grid:
        show: true
        color: "white"
        borderWidth: 0
        hoverable: true
      xaxis:
        mode: "time"
        timeformat: "%H:%M"
        tickDecimals: 0
        timezone: "browser"

      tooltip: true
      tooltipOpts:
        content: (label, xval, yval, flotItem) ->
          new Date(xval).getHours() + ":00 bis " + new Date(xval).getHours() + ":59 Uhr, Bezug: " + yval + " kWh"

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (Watt)'
      ]
    }