MeteringPointsController = Paloma.controller("MeteringPoints")

MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  $.plot $("#fake_real_time_data"), [gon.fake_real_time_data], { 
      series:
        color: "white"
        points:
          show: true
        lines:
          show: true
          fill: true
          fillColor: "rgba(255,255,255, 0.1)"
        hoverable: true
        highlightColor: "white"
      grid: 
        show: true
        color: "white"
        borderWidth: 0
        hoverable: true
      xaxis:
        mode: "time"
        timeformat: "%H:%M:%S"
        tickSize: [2, "second"]
        tickDecimals: 0

      tooltip: true
      tooltipOpts:
        content: 'Uhrzeit: %x, Bezug: %y kW'

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (kW)'
      ]
    }

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
        barWidth: 0.8*3600*1000
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
        barWidth: 0.66*3600*1000
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
      hoverable: true
      borderWidth: 0
    tooltip: true
    tooltipOpts:
      content: 'Uhrzeit: %x, Bezug: %y kWh'
    xaxis:
      mode: "time"
      timeformat: "%H:00"
      tickSize: [1, "hour"]
    axisLabels:
      show: true
    xaxes:[
      axisLabel: 'Uhrzeit'
    ]
    yaxes:[
      axisLabel: 'Bezug (kWh)'
    ]
  }




  $.plot $("#fake_month_to_days2"), [gon.fake_month_to_days2], { 
      series:
        color: "rgb(202,255,112)"
        hoverable: true
        highlightColor: "rgb(202,255,112)"
      bars:
          show: true
          fill: true
          fillColor: "rgba(202,255,112, 0.8)"
          align: "center"
          barWidth: 60*60*1000*20
      grid: 
        show: true
        color: "white"
        hoverable: true
        borderWidth: 0
      tooltip: true
      tooltipOpts:
        content: 'Datum: %x, Bezug: %y kWh'
      xaxis:
        mode: "time"
        timeformat: "%d.%m.%y"
        tickSize: [1, "day"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Datum'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }





