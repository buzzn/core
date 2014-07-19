$(".locations.show").ready ->

  for metering_point in gon.metering_points

    console.log metering_point

    $.plot $("#chart_#{metering_point.id}"), [metering_point['current']]


    # $.plot $("#metering_point_#{metering_point.id} .chart"), metering_point['current'], {
    #     series:
    #       color: "white"
    #       points:
    #         show: true
    #       lines:
    #         show: true
    #         fill: true
    #         fillColor: "rgba(255,255,255, 0.1)"
    #       hoverable: true
    #       highlightColor: "rgba(255, 255, 255, 0.5)"
    #     grid:
    #       show: true
    #       color: "white"
    #       borderWidth: 0
    #       hoverable: true
    #     xaxis:
    #       mode: "time"
    #       timeformat: "%H:%M:%S"
    #       tickDecimals: 0

    #     tooltip: true
    #     tooltipOpts:
    #       content: '%x Uhr, Bezug: %y Watt'

    #     axisLabels:
    #       show: true
    #     xaxes:[
    #       axisLabel: 'Uhrzeit'
    #     ]
    #     yaxes:[
    #       axisLabel: 'Bezug (Watt)'
    #     ]
    #   }