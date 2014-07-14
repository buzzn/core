MeteringPointsController = Paloma.controller("MeteringPoints")

MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  $.plot $(".chart_container#fake_real_time_data"), [gon.fake_real_time_data], {
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
        timeformat: "%H:%M:%S"
        tickDecimals: 0

      tooltip: true
      tooltipOpts:
        content: '%x Uhr, Bezug: %y Watt'

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (Watt)'
      ]
    }

  console.log gon.day_to_hours
  console.log gon.metering_point_mode

  $.plot $(".chart_container#day_to_hours"), [
    data: gon.day_to_hours
    color: "rgba(0, 40, 40, 0.95)"
    bars:
      show: true,
      lineWidth: 2,
      fill: true,
      barWidth: 0.66,
      fillColor: "rgba(220, 80, 80, 0.80)"
  ], {
    grid:
      color: "white"
      borderWidth: 0
    }



  unless gon.metering_point_mode is "out"
    secondFillColor = "rgba(30,115,189, 0.94)"
    secondHighlightColor = "rgba(30,115,189, 0.5)"
  else
    secondFillColor = "rgba(226,106,69,0.94)"
    secondHighlightColor = "rgba(226,106,69,0.5)"


  $.plot $(".chart_container#fake_day_to_hours"), [{
      data: gon.fake_day_to_hours2
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
      data: gon.fake_day_to_hours
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




  $.plot $(".chart_container#fake_week_to_days"), [gon.fake_week_to_days], {
      series:
        hoverable: true
        highlightColor: "rgb(255, 255, 255)"
      bars:
          show: true
          fill: true
          fillColor: "rgba(255, 255, 255, 0.94)"
          align: "center"
          barWidth: 60*60*1000*20
          lineWidth: 0
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
        minTickSize: [1, "day"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Datum'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }


  $.plot $(".chart_container#fake_month_to_days"), [gon.fake_month_to_days], {
      series:
        hoverable: true
        highlightColor: "rgb(255, 255, 255)"
      bars:
          show: true
          fill: true
          fillColor: "rgba(255, 255, 255, 0.94)"
          align: "center"
          barWidth: 60*60*1000*20
          lineWidth: 0
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
        tickSize: [5, "day"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Datum'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }



  $.plot $(".chart_container#fake_year_to_months"), [gon.fake_year_to_months], {
      series:
        hoverable: true
        highlightColor: "rgb(255, 255, 255)"
      bars:
          show: true
          fill: true
          fillColor: "rgba(255, 255, 255, 0.94)"
          align: "center"
          barWidth: 60*60*1000*24*25
          lineWidth: 0
      grid:
        show: true
        color: "white"
        hoverable: true
        borderWidth: 0
      tooltip: true
      tooltipOpts:
        content: 'Monat: %x, Bezug: %y kWh'
      xaxis:
        mode: "time"
        timeformat: "%b %Y"
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Monat'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }



  $.plot $(".chart_container#fake_years_to_year"), [gon.fake_years_to_year], {
      series:
        hoverable: true
        highlightColor: "rgb(255, 255, 255)"
      bars:
          show: true
          fill: true
          fillColor: "rgba(255, 255, 255, 0.94)"
          align: "center"
          barWidth: 60*60*1000*24*25*8
          lineWidth: 0
      grid:
        show: true
        color: "white"
        hoverable: true
        borderWidth: 0
      tooltip: true
      tooltipOpts:
        content: 'Jahr: %x, Bezug: %y kWh'
      xaxis:
        mode: "time"
        timeformat: "%Y"
        tickSize: [1, "year"]
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Jahr'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }





