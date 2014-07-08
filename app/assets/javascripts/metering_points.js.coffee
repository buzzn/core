MeteringPointsController = Paloma.controller("MeteringPoints")

MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  console.log gon.day_to_hours

  $.plot $("#day_to_hours"), [
    data: gon.day_to_hours
    color: "rgba(0, 40, 40, 0.95)"
    bars:
      show: true,
      lineWidth: 2,
      fill: true,
      barWidth: 0.66,
      fillColor: "rgba(220, 80, 80, 0.80)"
  ]



  $.plot $("#fake_day_to_hours"), [{
      data: gon.fake_day_to_hours
      label: "Heute"
      bars:
        show: true
        fill: true
        fillColor: "rgba(255,255,204, 0.8)"
        barWidth: 0.8
      color: "rgb(255,255,204)"
      highlightColor: "rgba(255,255,255,0.9)" 
    }, 
    {
      data: gon.fake_day_to_hours2
      label: "Gestern"
      bars:
        show: true
        fill: true
        fillColor: "rgba(0,102,102,0.6)"
        barWidth: 0.66
      color: "rgb(0,102,102)" 
      highlightColor: "rgba(0,0,0, 0.9)"
    }
  ], {
    series:
      hoverable: true
    bars:
      align: "center"
    legend:
      position: "nw"
      backgroundColor: "rgba(255, 102, 102, 0.8)"
    grid:
      show: true
      color: "white"
      backgroundColor:
        colors: ["rgb(255, 102, 102)", "rgb(255, 51, 102)"]
      hoverable: true
    tooltip: true
    tooltipOpts:
      content: 'Stunde: %x.0, Bezug: %y kWh'
    xaxis:
      min: -0.5
      max: 9.5
    axisLabels:
      show: true
    xaxes:[
      axisLabel: 'Stunde'
    ]
    yaxes:[
      axisLabel: 'Bezug (kWh)'
    ]
  }





  $.plot $("#fake_week_to_days"), [gon.fake_month_to_days], { 
      series:
        color: "white"
        points:
          show: true
        lines:
          show: true
          fill: true
          fillColor: "rgba(255,255,255, 0.2)"
        hoverable: true
        highlightColor: "white"
      grid: 
        show: true
        color: "white"
        backgroundColor: 
          colors: ["rgb(52,153,255)", "rgb(51,102,255)"]
        hoverable: true
      xaxis:
        minTickSize: 1
        tickDecimals: 0

      tooltip: true
      tooltipOpts:
        content: 'Tag: %x.0, Bezug: %y kWh'

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Tag'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }





