MeteringPointsController = Paloma.controller("MeteringPoints")

MeteringPointsController.prototype.show = () ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"


  unless gon.metering_point_mode is "out"
    secondFillColor = "rgba(30,115,189, 0.94)"
    secondHighlightColor = "rgba(30,115,189, 0.5)"
  else
    secondFillColor = "rgba(226,106,69,0.94)"
    secondHighlightColor = "rgba(226,106,69,0.5)"

  for chart_type in ['day_to_hours','week_to_dayes']

    $.plot $("##{chart_type}"), [{
        data: gon["#{chart_type}_past"]
        label: "Gestern"
        bars:
          show: true
          fill: true
          fillColor: secondFillColor
          barWidth: 0.66*3600*1000
          lineWidth: 0
        highlightColor: secondHighlightColor
      },
      {
        data: gon["#{chart_type}_current"]
        label: "Heute"
        bars:
          show: true
          fill: true
          fillColor: "rgba(255,255,255,0.94)"
          barWidth: 0.66*3600*1000
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
        content: '%s:   Uhrzeit: %x, Bezug: %y kWh'
      xaxis:
        mode: "time"
        timeformat: "%H:00"
        minTickSize: [1, "hour"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }





