$(".locations.show").ready ->

  for register in gon.registers

    $.plot $("#register_#{register.id} #chart"), [register['current']], {
      series:
        color: "white"
        points:
          show: false
        bars:
          show: true
          fill: true
          fillColor: "rgba(255,255,255, 0.94)"
          barWidth: 0.66 * 3600 * 1000
          lineWidth: 0
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
        max: gon.end_of_day
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