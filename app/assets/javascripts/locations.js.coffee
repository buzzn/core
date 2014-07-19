$(".locations.show").ready ->



  for metering_point_id in gon.metering_point_ids

    console.log metering_point_id

    $.getJSON "/metering_points/#{metering_point_id}.json", (json) ->


      # $.plot $("#metering_point_#{metering_point_id} .chart"), [json.data], {
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