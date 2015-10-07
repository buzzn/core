actual_resolution = "day_to_minutes"
chart_data_min_x = 0
chart = undefined
ttlastSample = new Date()
rem_metering_point_id = ""

#code for partial: _metering_point.html.haml
$(".metering_points").ready ->
  $(this).find(".metering_point").each ->
    #smart = $(this).attr('data-smart')
    #online = $(this).attr('data-online')

    id = $(this).attr('id').split('_')[2]
    width = $("#chart-container-" + id).width()
    $.ajax({url: '/metering_points/' + id + '/chart?resolution=day_to_minutes', dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          data[0].data[0] = [new Date(), 0] #TODO: Search for last data
        partial_chart = new Highcharts.Chart(
          chart:
            type: 'area'
            renderTo: 'chart-container-' + id
            width: width
            backgroundColor: 'rgba(255, 255, 255, 0.0)'
            spacingBottom: 5,
            spacingTop: 0,
            spacingLeft: 20,
            spacingRight: 20
          colors: ['#FFF']
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
              format: "{value} W"
            title:
              enabled: false
            minRange: 10
            min: 0
          plotOptions:
            series:
              fillColor:
                linearGradient: { x1: 1, y1: 0, x2: 1, y2: 1 }
                stops: [
                  [0, "rgba(255, 255, 255, 0.4)"],
                  [1, "rgba(255, 255, 255, 0.0)"]
                ]
              states:
                hover:
                  enabled: false
            areaspline:
              marker:
                radius: 2
          tooltip:
            enabled: false

          series: data)
      .error (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
        $('#chart-container-' + id).html('error')

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
  end = new Date(timestamp)
  end.setMinutes(59,59,999)
  return end.getTime()

beginningOfWeek = (timestamp) ->
  startDay = 1
  start = new Date(timestamp.valueOf() - (timestamp<=0 ? 7-startDay:timestamp-startDay)*86400000);
  start.setHours(0,0,0,0)
  return start.getTime()

endOfWeek = (timestamp) ->
  startDay = 1
  start = new Date(timestamp.valueOf() - (timestamp<=0 ? 7-startDay:timestamp-startDay)*86400000);
  end = new Date(start.valueOf() + 6*86400000);
  end.setHours(23,59,59,999)
  return end.getTime()

#code for metering_point.show
$(".metering_point_detail").ready ->
  chart = undefined
  id = $(this).attr('id').split('_')[2]
  width = $("#chart-container-" + id).width()
  $.ajax({url: '/metering_points/' + id + '/chart?resolution=day_to_minutes', dataType: 'json'})
    .success (data) ->
      if data[0].data[0] == undefined
        data[0].data[0] = [new Date(), 0] #TODO: Search for last data
      chart = new Highcharts.Chart(
        chart:
          renderTo: 'chart-container-' + id
          backgroundColor:'rgba(255, 255, 255, 0.0)'
          width: width
          spacingBottom: 20
          spacingTop: 10
          spacingLeft: 20
          spacingRight: 20
        colors: ['#FFF']
        exporting:
          enabled: false
        legend:
          enabled: false
        title:
          margin: 0
          text: "Heute, " + moment(data[0].data[0][0]).format("DD.MM.YYYY")
          style: { "color": "#FFF"}
        credits:
          enabled: false
        loading:
          hideDuration: 800
          showDuration: 800
          labelStyle:
            color: 'black'
            'font-size': '20pt'
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
          min: 0
          labels:
            enabled: true
            style:
              color: '#FFF'
            format: "{value} W"
          title:
            enabled: true
            text: "Leistung"
            style: { "color": "#FFF", "fontWeight": "bold"}
          minRange: 1
        plotOptions:
          series:
            fillColor:
              linearGradient: { x1: 1, y1: 0, x2: 1, y2: 1 }
              stops: [
                [0, "rgba(255, 255, 255, 0.4)"],
                [1, "rgba(255, 255, 255, 0.1)"]
              ]
          area:
            borderWidth: 0
            cursor: 'pointer'
            events:
              click: (event) ->
                zoomIn(event.point.x)
          column:
            borderWidth: 0
            cursor: 'pointer'
            events:
              click: (event) ->
                zoomIn(event.point.x)
        tooltip:
          pointFormat: '<b>{point.y:,.0f} W</b><br/>'
          dateTimeLabelFormats:
            millisecond:"%e.%b, %H:%M:%S.%L",
            second:"%e.%b, %H:%M:%S",
            minute:"%e.%b, %H:%M",
            hour:"%e.%b, %H:%M",
            day:"%e.%b.%Y",
            week:"Week from %e.%b.%Y",
            month:"%B %Y",
            year:"%Y"
        series: data
      )
      chart_data_min_x = chart.series[0].data[0].x
      createChartTimer([id], 'metering_point')
      activateButtons(true)
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      $('#chart-container-' + id).html('error')



  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getPreviousTimestamp()
    setChartData('metering_points', id, containing_timestamp)

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getNextTimestamp()
    setChartData('metering_points', id, containing_timestamp)

  $(".btn-chart-zoom-month").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "month_to_days"
    containing_timestamp = chart_data_min_x
    setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-day").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = chart_data_min_x
    actual_resolution = "day_to_minutes"
    setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-hour").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = chart_data_min_x
    setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-live").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = (new Date()).getTime()
    setChartData('metering_points', id, containing_timestamp)


  $(window).on "resize", ->
    new_point_width = setPointWidth()
    if chart != undefined
      chart.series[0].update({pointWidth: new_point_width})



#code for dashboard
$(".dashboard-chart").ready ->
  chart = undefined
  dashboard_id = $(this).attr('id')
  width = $("#chart-container-" + dashboard_id).width()
  metering_point_ids = $(this).data('metering_point-ids').toString().split(",")
  metering_point_ids.forEach (id) ->
    if id != ""
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=day_to_minutes', async: true, dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            data[0].data[0] = [new Date(), 0] #TODO: Search for last data
          if chart == undefined
            chart = new Highcharts.Chart(
              chart:
                type: 'area'
                renderTo: 'chart-container-' + dashboard_id
                backgroundColor:'rgba(255, 255, 255, 0.0)'
                width: width
                spacingBottom: 20
                spacingTop: 10
                spacingLeft: 20
                spacingRight: 20
              colors: ['#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
              exporting:
                enabled: false
              legend:
                enabled: true
              title:
                margin: 0
                text: "Heute, " + moment(data[0].data[0][0]).format("DD.MM.YYYY")
                style: { "color": "#000"}
              credits:
                enabled: false
              loading:
                hideDuration: 800
                showDuration: 800
                labelStyle:
                  color: 'black'
                  'font-size': '20pt'
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
                    color: '#000'
                title:
                  text: "Zeit"
                  enabled: true
                  style: { "color": "#000", "fontWeight": "bold"}
              yAxis:
                gridLineWidth: 0
                min: 0
                labels:
                  enabled: true
                title:
                  margin: 0
                  text: ""
                credits:
                  enabled: false
              plotOptions:
                series:
                  fillOpacity: 0.5
                area:
                  borderWidth: 0
                  cursor: 'pointer'
                  events:
                    click: (event) ->
                      zoomInDashboard(event.point.x)
                column:
                  borderWidth: 0
                  cursor: 'pointer'
                  events:
                    click: (event) ->
                      zoomInDashboard(event.point.x)
                  stacking: 'normal'
              tooltip:
                pointFormat: '{series.name}: <b>{point.y:,.0f} W</b><br/>'
                dateTimeLabelFormats:
                  millisecond:"%e.%b, %H:%M:%S.%L",
                  second:"%e.%b, %H:%M:%S",
                  minute:"%e.%b, %H:%M",
                  hour:"%e.%b, %H:%M",
                  day:"%e.%b.%Y",
                  week:"Week from %e.%b.%Y",
                  month:"%B %Y",
                  year:"%Y"
                #series: data
            )
            chart.addSeries(
              name: data[0].name
              data: data[0].data
            )
            chart_data_min_x = chart.series[0].data[0].x
            #checkIfPreviousDataExistsDashboard()
            #checkIfNextDataExistsDashboard()
          else
            chart.addSeries(
              name: data[0].name
              data: data[0].data
            )
          activateButtons(true)
        .error (jqXHR, textStatus, errorThrown) ->
          console.log textStatus
  createChartTimer(metering_point_ids, 'dashboard')





  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getPreviousTimestamp()
    metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
    numberOfSeries = 0
    metering_point_ids.forEach (id) ->
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            chart.hideLoading()
            return
          seriesVisible = chart.series[numberOfSeries].visible
          if !seriesVisible
            chart.series[numberOfSeries].show()
          chart.series[numberOfSeries].setData(data[0].data)
          chart.xAxis[0].update(getExtremes(containing_timestamp), true)
          chart_data_min_x = chart.series[numberOfSeries].data[0].x
          if !seriesVisible
            chart.series[numberOfSeries].hide()
          numberOfSeries += 1
    setChartTitle(chart_data_min_x)
    chart.hideLoading()
    activateButtons(true)
    #checkIfPreviousDataExistsDashboard()
    #checkIfNextDataExistsDashboard()
    #checkIfZoomOutDashboard()

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getNextTimestamp()
    metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
    numberOfSeries = 0
    metering_point_ids.forEach (id) ->
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            chart.hideLoading()
            return
          seriesVisible = chart.series[numberOfSeries].visible
          if !seriesVisible
            chart.series[numberOfSeries].show()
          chart.series[numberOfSeries].setData(data[0].data)
          chart.xAxis[0].update(getExtremes(containing_timestamp), true)
          chart_data_min_x = chart.series[numberOfSeries].data[0].x
          if !seriesVisible
            chart.series[numberOfSeries].hide()
          numberOfSeries += 1
    setChartTitle(chart_data_min_x)
    chart.hideLoading()
    activateButtons(true)
    #checkIfPreviousDataExistsDashboard()
    #checkIfNextDataExistsDashboard()
    #checkIfZoomOutDashboard()

  $(".btn-chart-zoomout").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    if actual_resolution == "hour_to_minutes"
      actual_resolution = "day_to_minutes"
      setChartType(true)
    else if actual_resolution == "day_to_minutes"
    #  actual_resolution = "week_to_days"
    #else if actual_resolution == "week_to_days"
      actual_resolution = "month_to_days"
      setChartType(true)
    else if actual_resolution == "month_to_days"
      #actual_resolution = "year_to_months"
      setChartType(true)
      activateButtons(true)
      hart.hideLoading()
      return

    containing_timestamp = chart_data_min_x
    metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
    numberOfSeries = 0
    metering_point_ids.forEach (id) ->
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            chart.hideLoading()
            data[0].data[0] = [new Date(), 0]
          seriesVisible = chart.series[numberOfSeries].visible
          if !seriesVisible
            chart.series[numberOfSeries].show()
          chart.series[numberOfSeries].setData(data[0].data)
          new_point_width = setPointWidth()
          chart.series[numberOfSeries].update({pointWidth: new_point_width})
          chart.xAxis[0].update(getExtremes(containing_timestamp), true)
          chart_data_min_x = chart.series[numberOfSeries].data[0].x
          if !seriesVisible
            chart.series[numberOfSeries].hide()
          numberOfSeries += 1
    #checkIfPreviousDataExistsDashboard()
    #checkIfNextDataExistsDashboard()
    #checkIfZoomOutDashboard()
    setChartTitle(chart_data_min_x)
    chart.hideLoading()
    activateButtons(true)








#code for group
$(".group-chart").ready ->
  chart = undefined
  group_id = $(this).attr('id')
  width = $("#chart-container-" + group_id).width()
  url = '/groups/' + group_id + '/chart?resolution=day_to_minutes'
  $.ajax({url: url, async: true, dataType: 'json'})
    .success (data) ->

      if data[0].data[0] == undefined
        data[0].data[0] = [new Date(), 0] #TODO: Search for last data

      if chart == undefined
        chart = new Highcharts.Chart(
          chart:
            type: 'area'
            renderTo: 'chart-container-' + group_id
            backgroundColor:'rgba(255, 255, 255, 0.0)'
            width: width
            spacingBottom: 20
            spacingTop: 10
            spacingLeft: 20
            spacingRight: 20
          colors: ['#5FA2DD', '#F76C51']
          exporting:
            enabled: false
          legend:
            enabled: true
          title:
            margin: 0
            text: "Heute, " + moment(data[0].data[0][0]).format("DD.MM.YYYY")
            style: { "color": "#000"}
          credits:
            enabled: false
          loading:
            hideDuration: 800
            showDuration: 800
            labelStyle:
              color: 'black'
              'font-size': '20pt'
            style:
              backgroundColor: 'grey'
              opacity: '0.4'
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
                color: '#000'
            title:
              text: "Zeit"
              enabled: true
              style: { "color": "#000", "fontWeight": "bold"}
          yAxis:
            gridLineWidth: 0
            min: 0
            labels:
              enabled: true
              style:
                color: '#000'
              format: "{value} W"
            title:
              enabled: true
              text: "Leistung"
              style: { "color": "#000", "fontWeight": "bold"}
          plotOptions:
            series:
              fillOpacity: 0.5
            area:
              cursor: 'pointer'
              events:
                click: (event) ->
                  zoomInGroup(event.point.x)
            column:
              cursor: 'pointer'
              events:
                click: (event) ->
                  zoomInGroup(event.point.x)
              #stacking: 'normal'

          tooltip:
            shared: true
            pointFormat: '{series.name}: <b>{point.y:,.0f} W</b><br/>'
            dateTimeLabelFormats:
              millisecond:"%e.%b, %H:%M:%S.%L",
              second:"%e.%b, %H:%M:%S",
              minute:"%e.%b, %H:%M",
              hour:"%e.%b, %H:%M",
              day:"%e.%b.%Y",
              week:"Week from %e.%b.%Y",
              month:"%B %Y",
              year:"%Y"
          series: data

        )
        # chart.addSeries(
        #   name: data[0].name
        #   data: data[0].data
        # )
        # chart.addSeries(
        #   name: data[1].name
        #   data: data[1].data
        # )

        chart_data_min_x = chart.series[0].data[0].x
        #checkIfPreviousDataExistsGroup()
        #checkIfNextDataExistsGroup()
      activateButtons(true)
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      $('#chart-container-' + group_id).html('error')
  createChartTimer([group_id], 'group')



  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getPreviousTimestamp()
    setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = getNextTimestamp()
    setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-month").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "month_to_days"
    containing_timestamp = chart_data_min_x
    setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-day").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    containing_timestamp = chart_data_min_x
    actual_resolution = "day_to_minutes"
    setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-hour").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = chart_data_min_x
    setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-live").on 'click', ->
    chart.showLoading()
    activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = (new Date()).getTime()
    setChartDataMultiSeries('groups', group_id, containing_timestamp)





getExtremes = (timestamp) ->
  if actual_resolution == "hour_to_minutes"
    start = beginningOfHour(timestamp)
    end = endOfHour(timestamp)
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    start = beginningOfDay(timestamp)
    end = endOfDay(timestamp)
  else if actual_resolution == "week_to_days"
    start = beginningOfWeek(timestamp)
    end = endOfWeek(timestamp)
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
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    return chart_data_min_x - 24*3600*1000
  else if actual_resolution == "week_to_days"
    return chart_data_min_x - 7*24*3600*1000
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
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    return chart_data_min_x + 24*3600*1000
  else if actual_resolution == "week_to_days"
    return chart_data_min_x + 7*24*3600*1000
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
  else if actual_resolution == "day_to_minutes"
    return $(".chart").width()/200.0
  else if actual_resolution == "week_to_days"
    return $(".chart").width()/32.0
  else if actual_resolution == "month_to_days"
    return $(".chart").width()/80.0
  else if actual_resolution == "year_to_months"
    return $(".chart").width()/42.0

zoomIn = (timestamp) ->
  activateButtons(false)
  chart.showLoading()
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "hour_to_minutes"
      setChartType(false)
      chart.hideLoading()
      activateButtons(true)
      return
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
      actual_resolution = "hour_to_minutes"
      setChartType(false)
    else if actual_resolution == "month_to_days"
      actual_resolution = "day_to_minutes"
      setChartType(false)
    else if actual_resolution == "year_to_months"
      actual_resolution = "month_to_days"
      setChartType()
    containing_timestamp = timestamp
    setChartData('metering_points', id, containing_timestamp)

zoomInDashboard = (timestamp) ->
  chart.showLoading()
  activateButtons(false)
  if actual_resolution == "hour_to_minutes"
    setChartType(true)
    chart.hideLoading()
    activateButtons(true)
    return
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    actual_resolution = "hour_to_minutes"
    setChartType(true)
  #else if actual_resolution == "week_to_days"
  #  actual_resolution = "day_to_hours"
  else if actual_resolution == "month_to_days"
  #  actual_resolution = "week_to_days"
    actual_resolution = "day_to_minutes"
    setChartType(true)
  else if actual_resolution == "year_to_months"
    actual_resolution = "month_to_days"
    setChartType(true)
  containing_timestamp = timestamp

  metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
  numberOfSeries = 0
  metering_point_ids.forEach (id) ->
    $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          chart.hideLoading()
          activateButtons(true)
          return
        seriesVisible = chart.series[numberOfSeries].visible
        if !seriesVisible
          chart.series[numberOfSeries].show()
        chart.series[numberOfSeries].setData(data[0].data)
        new_point_width = setPointWidth()
        chart.series[numberOfSeries].update({pointWidth: new_point_width})
        chart.xAxis[0].update(getExtremes(containing_timestamp), true)
        chart_data_min_x = chart.series[0].data[0].x
        if !seriesVisible
          chart.series[numberOfSeries].hide()
        numberOfSeries += 1

  #checkIfPreviousDataExistsDashboard()
  #checkIfNextDataExistsDashboard()
  #checkIfZoomOutDashboard()
  setChartTitle(chart_data_min_x)
  chart.hideLoading()
  activateButtons(true)

zoomInGroup = (timestamp) ->
  chart.showLoading()
  activateButtons(false)
  if actual_resolution == "hour_to_minutes"
    setChartType(true)
    chart.hideLoading()
    activateButtons(true)
    return
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    actual_resolution = "hour_to_minutes"
    setChartType(true)
  #else if actual_resolution == "week_to_days"
  #  actual_resolution = "day_to_hours"
  else if actual_resolution == "month_to_days"
  #  actual_resolution = "week_to_days"
    actual_resolution = "day_to_minutes"
    setChartType(true)
  else if actual_resolution == "year_to_months"
    actual_resolution = "month_to_days"
    setChartType(true)
  containing_timestamp = timestamp

  id = $(".group-chart").attr('id')
  setChartDataMultiSeries('groups', id, containing_timestamp)




setChartType = (displaySeriesName) ->
  if actual_resolution == "month_to_days" || actual_resolution == "year_to_months"
    if displaySeriesName
      chart.series.forEach (series) ->
        series.update({
          type: 'column'
          tooltip:
            pointFormat: '{series.name}: <b>{point.y:.2f} kWh</b><br/>'
        })
    else
      chart.series.forEach (series) ->
        series.update({
          type: 'column'
          tooltip:
            pointFormat: '<b>{point.y:.2f} kWh</b><br/>'
        })
    chart.yAxis[0].update({
      labels:
        format: "{value} kWh"
      title:
        text: "Energie"
    })
  else
    if displaySeriesName
      chart.series.forEach (chartSeries) ->
        chartSeries.update({
          type: 'area'
          tooltip:
            pointFormat: '{series.name}: <b>{point.y:,.0f} W</b><br/>'
        })
    else
      chart.series.forEach (series) ->
        series.update({
          type: 'area'
          tooltip:
            pointFormat: '<b>{point.y:,.0f} W</b><br/>'
        })
    chart.yAxis[0].update({
      labels:
        format: "{value} W"
      title:
        text: "Leistung"
    })

setChartTitle = (containing_timestamp) ->
  moment.locale('de')
  extremes = getExtremes(containing_timestamp)
  if actual_resolution == "hour_to_minutes"
    chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY") + " ...  " + moment(extremes.min).format("HH:mm") + " - " + moment(extremes.max).format("HH:mm")})
  else if actual_resolution == "day_to_minutes" || actual_resolution == "day_to_hours"
    chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY")})
  else if actual_resolution == "month_to_days"
    chart.setTitle({text: moment(extremes.min).format("MMMM YYYY")})
  else if actual_resolution == "year_to_months"
    chart.setTitle({text: moment(extremes.min).format("YYYY")})

activateButtons = (disabled) ->
  $(".btn-chart-next").attr('disabled', !disabled)
  $(".btn-chart-prev").attr('disabled', !disabled)
  $(".btn-chart-zoomout").attr('disabled', !disabled)
  $(".btn-chart-zoom-month").attr('disabled', !disabled)
  $(".btn-chart-zoom-day").attr('disabled', !disabled)
  $(".btn-chart-zoom-hour").attr('disabled', !disabled)
  $(".btn-chart-zoom-live").attr('disabled', !disabled)

setChartData = (resource, id, containing_timestamp) ->
  $.ajax({url: '/' + resource + '/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] == undefined
        data[0].data[0] = [new Date(), 0]
      chart.series[0].setData(data[0].data)
      new_point_width = setPointWidth()
      chart.series[0].update({pointWidth: new_point_width})
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
      chart_data_min_x = chart.series[0].data[0].x
      setChartTitle(chart_data_min_x)
      setChartType(false)
      chart.hideLoading()
      activateButtons(true)
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      $('#chart-container-' + id).html('error')
      chart.hideLoading()
      activateButtons(true)

setChartDataMultiSeries = (resource, id, containing_timestamp) ->
  numberOfSeries = 0
  $.ajax({url: '/' + resource + '/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        data[0].data[0] = [new Date(), 0]
      data.forEach (d) ->
        seriesVisible = chart.series[numberOfSeries].visible
        if !seriesVisible
          chart.series[numberOfSeries].show()
        chart.series[numberOfSeries].setData(d.data)
        new_point_width = setPointWidth()
        chart.series[numberOfSeries].update({pointWidth: new_point_width})
        chart.xAxis[0].update(getExtremes(containing_timestamp), true)
        chart_data_min_x = chart.series[numberOfSeries].data[0].x
        setChartTitle(chart_data_min_x)
        if !seriesVisible
          chart.series[numberOfSeries].hide()
        numberOfSeries += 1
      setChartType(true)
      chart.hideLoading()
      activateButtons(true)
    .error (jqXHR, textStatus, errorThrown) ->
      chart.hideLoading()
      console.log textStatus
      $('#chart-container-' + id).html('error')
      activateButtons(true)







#  ****** Chart Update Timers ******

createChartTimer = (resource_ids, mode) ->
  timers.push(
    window.setInterval(->
      updateChart(resource_ids, mode)
      return
    , 1000*60*5)
    )

updateChart = (resource_ids, mode) ->
  containing_timestamp = new Date().getTime()
  if actual_resolution == 'hour_to_minutes'
    return
  if mode == 'metering_point'
    if resource_ids.length == 0
      return
    $.ajax({url: '/metering_points/' + resource_ids[0] + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          return
        if chart_data_min_x == data[0].data[0][0]
          chart.series[0].setData(data[0].data)

  else if mode == 'dashboard'
    if resource_ids.length == 0
      return
    numberOfSeries = 0
    resource_ids.forEach (id) ->
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            return
          if chart_data_min_x == data[0].data[0][0]
            chart.series[numberOfSeries].setData(data[0].data)
          numberOfSeries += 1
        .error (jqXHR, textStatus, errorThrown) ->
          console.log textStatus
          numberOfSeries += 1

  else if mode == 'group'
    if resource_ids.length == 0
      return
    numberOfSeries = 0
    $.ajax({url: '/groups/' + resource_ids[0] + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          return
        if chart_data_min_x == data[0].data[0][0]
          data.forEach (d) ->
            chart.series[numberOfSeries].setData(d.data)
            numberOfSeries += 1




# ******* scores ********

# $(".metering_point_scores").ready ->
#   group_id = $(this).attr('data-content')
#   $.ajax({url: '/metering_points/' + group_id + '/get_scores'})
#     .success (data) ->
#       sufficiency = Number((data.sufficiency).toFixed(0))
#       $(".score_sufficiency").append("<div class=circle-filled></div>") for [1..sufficiency] if sufficiency
#       $(".score_sufficiency").append("<div class=circle-empty></div>") for [1..(5 - sufficiency)] if (5 - sufficiency)

#       fitting = Number((data.fitting).toFixed(0))
#       $(".score_fitting").append("<div class=circle-filled></div>") for [1..fitting] if fitting
#       $(".score_fitting").append("<div class=circle-empty></div>") for [1..(5 - fitting)] if (5 - fitting)
#       $(".circle-filled").addClass("fa fa-circle")
#       $(".circle-empty").addClass("fa fa-circle-o")





# ****** ticker *******

readingsSLP = []
readingsSEP_PV = []
readingsSEP_BHKW = []
factors = {}
timers = []


$(".metering_point").ready ->
  metering_point_id = $(this).attr('id').split('_')[2]
  metering_point = $(this)
  if $(this).find(".metering_point-ticker").length != 0
    source = $(this).find(".metering_point-ticker").data('source')
    if $(this).find(".metering_point-ticker").data('fake') == true
      getFakeValue(metering_point_id, source)
      timers.push(
        window.setInterval(->
          setFakeValue(metering_point, metering_point_id, source)
          return
        , 1000*5)
        )
    else
      if source == "mysmartgrid"
        timers.push(window.setInterval(->
          getLiveData(metering_point, metering_point_id)
          return
        , 1000*30)
        )
      else if source == "discovergy" || source == "virtual"

          timers.push(window.setInterval(->
            console.log window.wisActive
            if  window.wisActive == true
              getLiveData(metering_point, metering_point_id)
            return
          , 1000*5)
          )

      timers.push(window.setInterval(->
        ttsample(metering_point,metering_point_id)
        return
      , 1000 * 20)
      )

ttsample = (metering_point,metering_point_id) ->
  delta = Date.now() - ttlastSample
  if Date.now() - ttlastSample >= 40000 && metering_point_id == rem_metering_point_id
    # Code here will only run if the timer is delayed by more 2X the sample rate
    # (e.g. if the laptop sleeps for more than 20-40 seconds)
    # Finetuning of times may be necessary
    # for debugging uncomment this line: metering_point.find(".power-ticker").html('Servus! Woke up from sleep!! ' + delta)
    location.reload()
  # for debugging uncomment this line: else
  # for debugging uncomment this line:   metering_point.find(".power-ticker").html('always awake ' + delta)
  rem_metering_point_id = metering_point_id
  ttlastSample = Date.now()



getLiveData = (metering_point, metering_point_id) ->
  $.ajax({url: '/metering_points/' + metering_point_id + '/latest_power', async: true, dataType: 'json'})
    .success (data) ->
      if data.online == true || data.virtual == true
        metering_point.find(".power-ticker").html(data.latest_power)
        if data.timestamp <= Date.now() - 60*1000
          metering_point.find(".power-ticker").css({opacity: 0.3})
        else
          metering_point.find(".power-ticker").css({opacity: 1})
        metering_point.find(".power-ticker").data('content', moment(data.timestamp).format("DD.MM.YYYY HH:mm:ss"))
        metering_point.find(".power-ticker").popover(placement: 'top', trigger: 'hover')
        metering_point.find(".power-ticker").data('bs.popover').options.content = moment(data.timestamp).format("DD.MM.YYYY HH:mm:ss")
        if $(".metering_point_detail").length != 0 && chart != undefined && actual_resolution == 'hour_to_minutes'
          if chart_data_min_x > data.timestamp - 60*60*1000
            chart.series[0].addPoint([data.timestamp, data.latest_power])
          # else if #TODO: if 1 hour is over toggle to next hour, but only if displayed
          #   chart.xAxis[0].update(getExtremes(data.timestamp), true)
          #   setChartTitle(data.timestamp)
          #   chart.series[0].addPoint([data.timestamp, data.latest_power])
      else
        metering_point.find(".power-ticker").html('offline')
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      metering_point.find(".power-ticker").html('error')


calculate_power = (last_readings) =>
  if last_readings == undefined || last_readings == null
    return "?"
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))



getFakeValue = (metering_point_id, source) ->
  $.getJSON "/metering_points/" + metering_point_id + "/latest_fake_data", (data) ->
    if source == 'slp'
      readingsSLP = data.data
    else if source == 'sep_pv'
      readingsSEP_PV = data.data
    else
      readingsSEP_BHKW = data.data
    if !(metering_point_id of factors)
      factors[metering_point_id] = data.factor

setFakeValue = (metering_point, metering_point_id, source) ->
  if source == 'slp'
    if readingsSLP[0][0] < (new Date()).getTime() - 15*60*1000
      getFakeValue(metering_point_id, 'slp')
    metering_point.find(".power-ticker").html getRandomPower(readingsSLP[0][1] * factors[metering_point_id]).toFixed(0)
  else if source == 'sep_pv'
    if readingsSEP_PV[0][0] < (new Date()).getTime() - 15*60*1000
      getFakeValue(metering_point_id, 'sep_pv')
    metering_point.find(".power-ticker").html getRandomPower(readingsSEP_PV[0][1] * factors[metering_point_id]).toFixed(0)
  else
    if readingsSEP_BHKW[0][0] < (new Date()).getTime() - 15*60*1000
      getFakeValue(metering_point_id, 'sep_bhkw')
    metering_point.find(".power-ticker").html getRandomPower(readingsSEP_BHKW[0][1] * factors[metering_point_id]).toFixed(0)

# interpolateFakekW = (data_arr, factor) ->
#   firstTimestamp = data_arr[0][0]
#   firstValue = data_arr[0][1]
#   lastTimestamp = data_arr[1][0]
#   lastValue = data_arr[1][1]
#   averagePower = (lastValue - firstValue)/0.25*1000*factor
#   return getRandomPower(averagePower)

getRandomPower = (averagePower) ->
  y = averagePower + Math.random()*10 - 5
  if y < 0
    return 0
  else
    return y


clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []

$(document).on('page:before-change', clearTimers)


