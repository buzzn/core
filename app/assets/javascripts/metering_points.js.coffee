$(".metering_points.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  unless gon.metering_point_mode is "out"
    secondFillColor = "rgba(30,115,189, 0.94)"
    secondHighlightColor = "rgba(30,115,189, 0.5)"
  else
    secondFillColor = "rgba(226,106,69,0.94)"
    secondHighlightColor = "rgba(226,106,69,0.5)"

  for chart_type in ['day_to_hours', 'month_to_days', 'year_to_months', 'actual_readings']

    if chart_type is 'day_to_hours' or chart_type is 'actual_readings'
      actualBarWidth = 0.66*3600*1000
      actualTimeFormat = "%H:00"
      actualXLabel = "Uhrzeit"
      actualToolTipOpts = (label, xval, yval, flotItem) ->
          "%s: " + new Date(xval).getHours() + ":00 bis " + new Date(xval + 3600*1000).getHours() + ":00 Uhr, Bezug: " + yval + " kWh"
    else if chart_type is 'month_to_days'
      actualBarWidth = 0.66*3600*1000*24
      actualTimeFormat = "%d.%m"
      actualXLabel = "Tag"
      actualToolTipOpts = "%s   Tag: %x, Bezug: %y kWh"
    else if chart_type is 'year_to_months'
      actualBarWidth = 0.66*3600*1000*24*30
      actualTimeFormat = "%b %Y"
      actualXLabel = "Monat"
      actualToolTipOpts = "%s   Monat: %x, Bezug: %y kWh"
    actualLabel = "Aktuell"

    $.plot $("##{chart_type}"), [{
        data: gon["#{chart_type}_past"]
        label: "Prognose"
        bars:
          show: true
          fill: true
          fillColor: secondFillColor
          barWidth: actualBarWidth
          lineWidth: 0
        highlightColor: secondHighlightColor
      },
      {
        data: gon["#{chart_type}_current"]
        label: "Aktuell"
        bars:
          show: true
          fill: true
          fillColor: "rgba(255,255,255,0.94)"
          barWidth: actualBarWidth
          lineWidth: 0
        highlightColor: "rgb(255,255,255)"
      }
    ], {
      series:
        hoverable: true
      bars:
        align: "center"
      legend:
        show: false
      grid:
        show: true
        color: "white"
        hoverable: true
        borderWidth: 0
      tooltip: true
      tooltipOpts:
        content: actualToolTipOpts
      xaxis:
        mode: "time"
        timeformat: actualTimeFormat
        timezone: "browser"
        minTickSize: [1, "hour"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: actualXLabel
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }





