$(".metering_points").ready ->
  $(".metering_point").each ->
    id = $(this).attr('id').split('_')[2]
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=day_to_hours', (data) ->
      chart = new (Highcharts.Chart)(
        chart:
          type: 'column'
          renderTo: 'chart-container-' + id
          backgroundColor:
                linearGradient: { x1: 1, y1: 0, x2: 1, y2: 1 }
                stops: [
                    [0, "rgba(0, 0, 0, 0)"],
                    [1, "rgba(0, 0, 0, 0.7)"]
                ]
          spacingBottom: 0,
          spacingTop: 0,
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
          lineWidth: 0
          tickWidth: 0
          type: 'datetime'
          endOnTick: true
          min: beginningOfDay(data[0].data[0][0])
          max: endOfDay(data[0].data[0][0])
          labels:
            enabled: false
            style:
              color: '#FFF'
        yAxis:
          gridLineWidth: 0
          labels:
            enabled: false
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

