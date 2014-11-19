$(".metering_points.show").ready ->

  # Javascript to enable link to tab
  hash = document.location.hash
  $(".nav-pills a[href=" + hash + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    return

  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    target_click = e.target.toString().slice(e.target.toString().lastIndexOf("#"), e.target.length)
    if target_click == "#charts"
      init_charts()

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  unless gon.metering_point_mode is "out"
    secondFillColor = "rgba(30,115,189, 0.94)"
    secondHighlightColor = "rgba(30,115,189, 0.5)"
  else
    secondFillColor = "rgba(226,106,69,0.94)"
    secondHighlightColor = "rgba(226,106,69,0.5)"


  init_charts = ->
    for register in gon.charts_data

      for chart_type in gon.chart_types

        console.log "##{chart_type} #register_#{register.id}"

        if chart_type is 'day_to_hours' or chart_type is 'actual_readings'
          actualBarWidth = 0.66*3600*1000
          actualTimeFormat = "%H:00"
          actualXLabel = "Uhrzeit"
          actualToolTipOpts = (label, xval, yval, flotItem) ->
              "%s: " + new Date(xval).getHours() + ":00 bis " + new Date(xval).getHours() + ":59 Uhr, Bezug: " + yval + " kWh"
          actualMax = gon.end_of_day
          actualMinTickSize = [1, "hour"]
        else if chart_type is 'month_to_days'
          actualBarWidth = 0.66*3600*1000*24
          actualTimeFormat = "%d.%m"
          actualXLabel = "Tag"
          actualToolTipOpts = "%s   Tag: %x, Bezug: %y kWh"
          actualMin = gon.beginning_of_month
          actualMax = gon.end_of_month
          actualMinTickSize = [1, "day"]
        else if chart_type is 'year_to_months'
          actualBarWidth = 0.66*3600*1000*24*30
          actualTimeFormat = "%b %Y"
          actualXLabel = "Monat"
          actualToolTipOpts = "%s   Monat: %x, Bezug: %y kWh"
          actualMin = gon.beginning_of_year
          actualMax = gon.end_of_year
          actualMinTickSize = [1, "month"]
        actualLabel = "Aktuell"



        $.plot $("##{chart_type} #register_#{register.id} #chart"), [{
            data: register[chart_type]['past']
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
            data: register[chart_type]['current']
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
            minTickSize: actualMinTickSize
            min: actualMin
            max: actualMax
          axisLabels:
            show: true
          xaxes:[
            axisLabel: actualXLabel
          ]
          yaxes:[
            axisLabel: 'Bezug (kWh)'
          ]
        }

  if hash == "#charts" || hash == "#tab_charts" || hash == ""
    init_charts()





