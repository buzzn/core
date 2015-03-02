$(".metering_points").ready ->
  $.getJSON('http://localhost:3000/metering_points/de0010688251510000000000002677128/chart?resolution=day_to_hours', (data) ->
    chart = new (Highcharts.Chart)(
      chart:
        type: 'column'
        renderTo: 'chart-container'
        backgroundColor:
              linearGradient: { x1: 1, y1: 0, x2: 1, y2: 1 }
              stops: [
                  [0, "rgba(0, 0, 0, 0)"],
                  [1, "rgba(0, 0, 0, 0.7)"]
              ]
        spacingBottom: 15,
        spacingTop: 20,
        spacingLeft: 20,
        spacingRight: 20
      exporting:
        enabled: false
      legend:
        enabled: false
      title:
        margin: 0
        text: ""
      credits:
        enabled: false
      xAxis:
        type: 'datetime'
        endOnTick: true
        min: beginningOfDay(data[0].data[0][0])
        max: endOfDay(data[0].data[0][0])
        dateTimeLabelFormats:
          minute: "%H:%M"
          hour: "%H:%M"
          day: "%e. %b"
          year: "%Y"
        labels:
          enabled: true
          style:
            color: '#FFF'
      yAxis:
        gridLineWidth: 0
        labels:
          enabled: true
          style:
            color: '#FFF'
          format: "{value} kWh"
        title:
          enabled: false

      tooltip:
        pointFormat: "{point.y:,.2f} kWh"
      series: data))

endOfDay = (timestamp) ->
  end = new Date(timestamp)
  end.setHours(23,59,59,999)
  return end.getTime()

beginningOfDay = (timestamp) ->
  start = new Date(timestamp)
  start.setHours(0,0,0,0)
  return start.getTime()

