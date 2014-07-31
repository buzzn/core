$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  for metering_point in gon.metering_points

    $.plot $("#chart_#{metering_point.id} #chart"), [metering_point['current']], {
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
          new Date(xval).getHours() + ":00 bis " + new Date(xval + 3600*1000).getHours() + ":00 Uhr, Bezug: " + yval + " kWh"

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (Watt)'
      ]
    }