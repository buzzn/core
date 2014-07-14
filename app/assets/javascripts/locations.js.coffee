LocationsController = Paloma.controller("Locations")

LocationsController.prototype.show = () ->
  #$('.inlinebar').sparkline 'html',
    #type: 'bar',
    #height: 60,
    #width: 300

  $.plot $(".chart_container#fake_location_display"), [gon.fake_real_time_data], {
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