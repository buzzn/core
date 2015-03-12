actual_resolution = "day_to_hours"
chart_data_min_x = 0
chart = undefined


$(".metering_points").ready ->
  $(".metering_point").each ->
    id = $(this).attr('id').split('_')[2]
    width = $("#chart-container-" + id).width()
    $.getJSON('/metering_points/' + id + '/chart?resolution=day_to_hours', (data) ->
      partial_chart = new (Highcharts.Chart)(
        chart:
          type: 'column'
          renderTo: 'chart-container-' + id
          width: width
          backgroundColor:'rgba(255, 255, 255, 0.0)'
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

endOfMonth = (timestamp) ->
  tmpDate = new Date(timestamp)
  end = new Date(tmpDate.getFullYear(), tmpDate.getMonth() + 1, 0)
  end.setHours(23, 59, 59, 999)
  return end.getTime()

beginningOfMonth = (timestamp) ->
  start = new Date(timestamp)
  start.setDate(1)
  start.setHours(0,0,0,0)
  return start.getTime()

beginningOfYear = (timestamp) ->
  tmpDate = new Date(timestamp)
  start = new Date(tmpDate.getFullYear(), 0, 0)
  start.setHours(0,0,0,0)
  return start.getTime()

endOfYear = (timestamp) ->
  tmpDate = new Date(timestamp)
  end = new Date(tmpDate.getFullYear(), 11, 30)
  end.setHours(23, 59, 59, 999)
  return end.getTime()

beginningOfHour = (timestamp) ->
  start = new Date(timestamp)
  start.setMinutes(0,0,0)
  return start.getTime()

endOfHour = (timestamp) ->
  start = new Date(timestamp)
  start.setMinutes(59,59,999)
  return start.getTime()

$(".metering_point_detail").ready ->
  id = $(this).attr('id').split('_')[2]
  width = $("#chart-container-" + id).width()
  $.getJSON('/metering_points/' + id + '/chart?resolution=day_to_hours', (data) ->
    chart = new (Highcharts.Chart)(
      chart:
        type: 'column'
        renderTo: 'chart-container-' + id
        backgroundColor:'rgba(255, 255, 255, 0.0)'
        width: width
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
      loading:
        hideDuration: 800
        showDuration: 800
      xAxis:
        lineWidth: 1
        tickWidth: 1
        type: 'datetime'
        startOnTick: false
        endOnTick: false
        min: beginningOfDay(data[0].data[0][0])
        max: endOfDay(data[0].data[0][0])
        labels:
          enabled: true
          style:
            color: '#FFF'
        title:
          text: "Zeit"
          enabled: true
          style: { "color": "#FFF", "fontWeight": "bold"}
      yAxis:
        gridLineWidth: 0
        labels:
          enabled: true
          style:
            color: '#FFF'
          format: "{value} kWh"
        title:
          enabled: true
          text: "Energie"
          style: { "color": "#FFF", "fontWeight": "bold"}
      plotOptions:
        column:
          borderWidth: 0
          events:
            cursor: 'pointer'
            click: (event) ->
              zoomIn(event.point.x)
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
    return
  ).success ->
    chart_data_min_x = chart.series[0].data[0].x
    checkIfPreviousDataExists()
    checkIfNextDataExists()



  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    containing_timestamp = getPreviousTimestamp()
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        return
      chart.series[0].setData(data[0].data)
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
    ).success ->
      chart_data_min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
      checkIfZoomOut()
      chart.hideLoading()

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    containing_timestamp = getNextTimestamp()
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        return
      chart.series[0].setData(data[0].data)
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
    ).success ->
      chart_data_min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
      checkIfZoomOut()
      chart.hideLoading()

  $(".btn-chart-zoomout").on 'click', ->
    chart.showLoading()
    if actual_resolution == "hour_to_minutes"
      actual_resolution = "day_to_hours"
    else if actual_resolution == "day_to_hours"
      actual_resolution = "month_to_days"
    else if actual_resolution == "month_to_days"
      actual_resolution = "year_to_months"

    containing_timestamp = chart_data_min_x
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        return
      chart.series[0].setData(data[0].data)
      new_point_width = setPointWidth()
      chart.series[0].update({pointWidth: new_point_width})
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
    ).success ->
      chart_data_min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
      checkIfZoomOut()
      chart.hideLoading()

  $(window).on "resize", ->
    new_point_width = setPointWidth()
    if chart != undefined
      chart.series[0].update({pointWidth: new_point_width})



checkIfPreviousDataExists = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    containing_timestamp = getPreviousTimestamp()
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        $(".btn-chart-prev").attr('disabled', true)
      else
        $(".btn-chart-prev").removeAttr("disabled")
    )

checkIfNextDataExists = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    containing_timestamp = getNextTimestamp()
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        $(".btn-chart-next").attr('disabled', true)
      else
        $(".btn-chart-next").removeAttr("disabled")
    )

getExtremes = (timestamp) ->
  if actual_resolution == "hour_to_minutes"
    start = beginningOfHour(timestamp)
    end = endOfHour(timestamp)
  else if actual_resolution == "day_to_hours"
    start = beginningOfDay(timestamp)
    end = endOfDay(timestamp)
  else if actual_resolution == "month_to_days"
    start = beginningOfMonth(timestamp)
    end = endOfMonth(timestamp)
  else if actual_resolution == "year_to_months"
    start = beginningOfYear(timestamp)
    end = endOfYear(timestamp)
  return {
    min: start
    max: end
  }

getPreviousTimestamp = () ->
  if actual_resolution == "hour_to_minutes"
    return chart_data_min_x - 3600*1000
  else if actual_resolution == "day_to_hours"
    return chart_data_min_x - 24*3600*1000
  else if actual_resolution == "month_to_days"
    tmpDate = new Date(chart_data_min_x)
    tmpDate.setMonth(tmpDate.getMonth() - 1)
    return tmpDate.getTime()
  else if actual_resolution == "year_to_months"
    tmpDate = new Date(chart_data_min_x)
    tmpDate.setYear(tmpDate.getFullYear() - 1)
    return tmpDate.getTime()

getNextTimestamp = () ->
  if actual_resolution == "hour_to_minutes"
    return chart_data_min_x + 3600*1000
  else if actual_resolution == "day_to_hours"
    return chart_data_min_x + 24*3600*1000
  else if actual_resolution == "month_to_days"
    tmpDate = new Date(chart_data_min_x)
    tmpDate.setMonth(tmpDate.getMonth() + 1)
    return tmpDate.getTime()
  else if actual_resolution == "year_to_months"
    tmpDate = new Date(chart_data_min_x)
    tmpDate.setYear(tmpDate.getFullYear() + 1)
    return tmpDate.getTime()

setPointWidth = () ->
  if actual_resolution == "hour_to_minutes"
    return $(".chart").width()/100.0
  else if actual_resolution == "day_to_hours"
    return $(".chart").width()/70.0
  else if actual_resolution == "month_to_days"
    return $(".chart").width()/80.0
  else if actual_resolution == "year_to_months"
    return $(".chart").width()/42.0

zoomIn = (timestamp) ->
  chart.showLoading()
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "hour_to_minutes"
      return
    else if actual_resolution == "day_to_hours"
      actual_resolution = "hour_to_minutes"
    else if actual_resolution == "month_to_days"
      actual_resolution = "day_to_hours"
    else if actual_resolution == "year_to_months"
      actual_resolution = "month_to_days"
    containing_timestamp = timestamp
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        return
      chart.series[0].setData(data[0].data)
      new_point_width = setPointWidth()
      chart.series[0].update({pointWidth: new_point_width})
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
    ).success ->
      chart_data_min_x = chart.series[0].data[0].x
      checkIfPreviousDataExists()
      checkIfNextDataExists()
      checkIfZoomOut()
      chart.hideLoading()

checkIfZoomOut = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "hour_to_minutes"
      out_resolution = "day_to_hours"
    else if actual_resolution == "day_to_hours"
      out_resolution = "month_to_days"
    else if actual_resolution == "month_to_days"
      out_resolution = "year_to_months"
    else if actual_resolution == "year_to_months"
      $(".btn-chart-zoomout").attr('disabled', true)
    containing_timestamp = chart_data_min_x
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + out_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
         $(".btn-chart-next").attr('disabled', true)
      noData = true
      data[0].data.forEach (d) ->
        if d[1] != 0
          noData = false
      if noData
        $(".btn-chart-next").attr('disabled', true)
      $(".btn-chart-zoomout").removeAttr("disabled")
    )









