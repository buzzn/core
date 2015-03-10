$(".metering_points").ready ->
  $(".metering_point").each ->
    id = $(this).attr('id').split('_')[2]
    width = $("#chart-container-" + id).width()
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=day_to_hours', (data) ->
      chart = new (Highcharts.Chart)(
        chart:
          type: 'column'
          renderTo: 'chart-container-' + id
          width: width
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
          dateTimeLabelFormats:
            millisecond:"%e.%b, %H:%M:%S.%L",
            second:"%e.%b, %H:%M:%S",
            minute:"%e.%b, %H:%M",
            hour:"%e.%b, %H:%M",
            day:"%e.%b.%Y",
            week:"Week from %e.%b.%Y",
            month:"%B %Y",
            year:"%Y"

        series: data))

endOfDay = (timestamp) ->
  end = new Date(timestamp)
  end.setHours(23,59,59,999)
  return end.getTime()

beginningOfDay = (timestamp) ->
  start = new Date(timestamp)
  start.setHours(0,0,0,0)
  return start.getTime()

$(".metering_point_detail").ready ->
  id = $(this).attr('id').split('_')[2]
  width = $("#chart-container-" + id).width()
  chart = undefined
  $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=day_to_hours', (data) ->
    chart = new (Highcharts.Chart)(
      chart:
        type: 'column'
        renderTo: 'chart-container-' + id
        width: width
        backgroundColor: '#5fa2dd'
        spacingBottom: 20
        spacingTop: 10
        spacingLeft: 20
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
        lineWidth: 1
        tickWidth: 1
        type: 'datetime'
        endOnTick: true
        min: beginningOfDay(data[0].data[0][0])
        max: endOfDay(data[0].data[0][0])
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
      plotOptions:
        column:
          borderWidth: 0
      tooltip:
        pointFormat: "{point.y:,.2f} kWh"
        dateTimeLabelFormats:
          millisecond:"%e.%b, %H:%M:%S.%L",
          second:"%e.%b, %H:%M:%S",
          minute:"%e.%b, %H:%M",
          hour:"%e.%b, %H:%M",
          day:"%e.%b.%Y",
          week:"Week from %e.%b.%Y",
          month:"%B %Y",
          year:"%Y"
      series: data)
    min_x = chart.series[0].data[0].x
  )
  checkIfPreviousDataExists()
  checkIfNextDataExists()

  $(".btn-chart-prev").on 'click', ->
    if actual_resolution == "day_to_hours"
      containing_timestamp = min_x - 24*3600*1000
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      chart.series[0].setData(data[0].data)
      chart.xAxis.min = beginningOfDay(data[0].data[0][0])
      chart.xAxis.max = endOfDay(data[0].data[0][0])
      min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
    )

  $(".btn-chart-next").on 'click', ->
    if actual_resolution == "day_to_hours"
      containing_timestamp = min_x + 24*3600*1000
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      chart.series[0].setData(data[0].data)
      chart.xAxis.min = beginningOfDay(data[0].data[0][0])
      chart.xAxis.max = endOfDay(data[0].data[0][0])
      min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
    )


actual_resolution = "day_to_hours"
min_x = 0

checkIfPreviousDataExists = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "day_to_hours"
      containing_timestamp = min_x - 24*3600*1000
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        $(".btn-chart-prev").attr('disabled', true)
      else
        $(".btn-chart-prev").removeAttr("disabled")
    )

checkIfNextDataExists = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "day_to_hours"
      containing_timestamp = min_x + 24*3600*1000
    $.getJSON('http://localhost:3000/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        $(".btn-chart-next").attr('disabled', true)
      else
        $(".btn-chart-next").removeAttr("disabled")
    )





