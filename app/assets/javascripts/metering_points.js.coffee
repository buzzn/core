actual_resolution = "day_to_minutes"
chart_data_min_x = 0
chart = undefined

#code for partial: _metering_point.html.haml
$(".metering_points").ready ->
  $(this).find(".metering_point").each ->
    smart = $(this).attr('data-smart')
    online = $(this).attr('data-online')
    if !smart || online
      id = $(this).attr('id').split('_')[2]
      width = $("#chart-container-" + id).width()
      $.ajax({url: '/metering_points/' + id + '/chart?resolution=day_to_hours', dataType: 'json'})
        .success (data) ->
          if data[0].data[0] == undefined
            data[0].data[0] = [new Date(), 0] #TODO: Search for last data
          partial_chart = new Highcharts.Chart(
            chart:
              type: 'areaspline'
              renderTo: 'chart-container-' + id
              width: width
              backgroundColor:'rgba(255, 255, 255, 0.0)'
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
          type: 'areaspline'
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
          areaspline:
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
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus





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
      setChartTitle(chart_data_min_x)
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
      #checkIfZoomOut()
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
      setChartTitle(chart_data_min_x)
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
      #checkIfZoomOut()
      chart.hideLoading()

  $(".btn-chart-zoomout").on 'click', ->
    chart.showLoading()
    if actual_resolution == "hour_to_minutes"
      actual_resolution = "day_to_minutes"
      setChartToLinechart(false)
    else if actual_resolution == "day_to_minutes"
    #  actual_resolution = "week_to_days"
    #else if actual_resolution == "week_to_days"
      actual_resolution = "month_to_days"
      setChartToBarchart(false)
    else if actual_resolution == "month_to_days"
      actual_resolution = "year_to_months"
      setChartToBarchart(false)

    containing_timestamp = chart_data_min_x
    $.getJSON('/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        data[0].data[0] = [new Date(), 0]
      chart.series[0].setData(data[0].data)
      new_point_width = setPointWidth()
      chart.series[0].update({pointWidth: new_point_width})
      chart.xAxis[0].update(getExtremes(containing_timestamp), true)
    ).success ->
      chart_data_min_x = chart.series[0].data[0].x
      setChartTitle(chart_data_min_x)
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
      #checkIfZoomOut()
      chart.hideLoading()

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
                type: 'areaspline'
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
                areaspline:
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
        .error (jqXHR, textStatus, errorThrown) ->
          console.log textStatus
  createChartTimer(metering_point_ids, 'dashboard')





  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
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
    #checkIfPreviousDataExistsDashboard()
    #checkIfNextDataExistsDashboard()
    #checkIfZoomOutDashboard()

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
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
    #checkIfPreviousDataExistsDashboard()
    #checkIfNextDataExistsDashboard()
    #checkIfZoomOutDashboard()

  $(".btn-chart-zoomout").on 'click', ->
    chart.showLoading()
    if actual_resolution == "hour_to_minutes"
      actual_resolution = "day_to_minutes"
      setChartToLinechart(true)
    else if actual_resolution == "day_to_minutes"
    #  actual_resolution = "week_to_days"
    #else if actual_resolution == "week_to_days"
      actual_resolution = "month_to_days"
      setChartToBarchart(true)
    else if actual_resolution == "month_to_days"
      actual_resolution = "year_to_months"
      setChartToBarchart(true)

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
            type: 'areaspline'
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
            areaspline:
              cursor: 'pointer'
              events:
                click: (event) ->
                  zoomInGroup(event.point.x)
            column:
              cursor: 'pointer'
              events:
                click: (event) ->
                  zoomInGroup(event.point.x)
              stacking: 'normal'
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
    .error (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
  createChartTimer([group_id], 'group')





  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    containing_timestamp = getPreviousTimestamp()
    numberOfSeries = 0
    $.ajax({url: '/groups/' + group_id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          chart.hideLoading()
          return
        data.forEach (d) ->
          seriesVisible = chart.series[numberOfSeries].visible
          if !seriesVisible
            chart.series[numberOfSeries].show()
          chart.series[numberOfSeries].setData(d.data)
          chart.xAxis[0].update(getExtremes(containing_timestamp), true)
          chart_data_min_x = chart.series[numberOfSeries].data[0].x
          setChartTitle(chart_data_min_x)
          if !seriesVisible
            chart.series[numberOfSeries].hide()
          numberOfSeries += 1

    chart.hideLoading()
    #checkIfPreviousDataExistsGroup()
    #checkIfNextDataExistsGroup()
    #checkIfZoomOutGroup()

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    containing_timestamp = getNextTimestamp()
    numberOfSeries = 0
    $.ajax({url: '/groups/' + group_id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] == undefined
          chart.hideLoading()
          return
        data.forEach (d) ->
          seriesVisible = chart.series[numberOfSeries].visible
          if !seriesVisible
            chart.series[numberOfSeries].show()
          chart.series[numberOfSeries].setData(d.data)
          chart.xAxis[0].update(getExtremes(containing_timestamp), true)
          chart_data_min_x = chart.series[numberOfSeries].data[0].x
          setChartTitle(chart_data_min_x)
          if !seriesVisible
            chart.series[numberOfSeries].hide()
          numberOfSeries += 1
    chart.hideLoading()
    #checkIfPreviousDataExistsGroup()
    #checkIfNextDataExistsGroup()
    #checkIfZoomOutGroup()

  $(".btn-chart-zoomout").on 'click', ->
    chart.showLoading()
    if actual_resolution == "hour_to_minutes"
      actual_resolution = "day_to_minutes"
      setChartToLinechart(true)
    else if actual_resolution == "day_to_minutes"
    #  actual_resolution = "week_to_days"
    #else if actual_resolution == "week_to_days"
      actual_resolution = "month_to_days"
      setChartToBarchart(true)
    else if actual_resolution == "month_to_days"
      actual_resolution = "year_to_months"
      setChartToBarchart(true)

    containing_timestamp = chart_data_min_x
    numberOfSeries = 0
    $.ajax({url: '/groups/' + group_id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
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
      .error (jqXHR, textStatus, errorThrown) ->
        console.log textStatus
    #checkIfPreviousDataExistsGroup()
    #checkIfNextDataExistsGroup()
    #checkIfZoomOutGroup()
    chart.hideLoading()



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

checkIfPreviousDataExistsDashboard = () ->
  containing_timestamp = getPreviousTimestamp()
  metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
  dataAvailable = false
  metering_point_ids.forEach (id) ->
    $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] != undefined
          dataAvailable = true
  if !dataAvailable
    $(".btn-chart-prev").attr('disabled', true)
  else
    $(".btn-chart-prev").removeAttr("disabled")

checkIfNextDataExistsDashboard = () ->
  containing_timestamp = getNextTimestamp()
  metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
  dataAvailable = false
  metering_point_ids.forEach (id) ->
    $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] != undefined
          dataAvailable = true
  if !dataAvailable
    $(".btn-chart-next").attr('disabled', true)
  else
    $(".btn-chart-next").removeAttr("disabled")

checkIfPreviousDataExistsGroup = () ->
  containing_timestamp = getPreviousTimestamp()
  id = $(".group-chart").attr('id')
  dataAvailable = false
  $.ajax({url: '/groups/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] != undefined
        dataAvailable = true
  if !dataAvailable
    $(".btn-chart-prev").attr('disabled', true)
  else
    $(".btn-chart-prev").removeAttr("disabled")

checkIfNextDataExistsGroup = () ->
  containing_timestamp = getNextTimestamp()
  id = $(".group-chart").attr('id')
  dataAvailable = false
  $.ajax({url: '/groups/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] != undefined
        dataAvailable = true
  if !dataAvailable
    $(".btn-chart-next").attr('disabled', true)
  else
    $(".btn-chart-next").removeAttr("disabled")

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
  chart.showLoading()
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "hour_to_minutes"
      setChartToLinechart(false)
      chart.hideLoading()
      return
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
      actual_resolution = "hour_to_minutes"
      setChartToLinechart(false)
    else if actual_resolution == "month_to_days"
      actual_resolution = "day_to_minutes"
      setChartToLinechart(false)
    else if actual_resolution == "year_to_months"
      actual_resolution = "month_to_days"
      setChartToBarchart()
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
      setChartTitle(chart_data_min_x)
      #checkIfPreviousDataExists()
      #checkIfNextDataExists()
      #checkIfZoomOut()
      chart.hideLoading()

zoomInDashboard = (timestamp) ->
  chart.showLoading()

  if actual_resolution == "hour_to_minutes"
    setChartToLinechart(true)
    chart.hideLoading()
    return
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    actual_resolution = "hour_to_minutes"
    setChartToLinechart(true)
  #else if actual_resolution == "week_to_days"
  #  actual_resolution = "day_to_hours"
  else if actual_resolution == "month_to_days"
  #  actual_resolution = "week_to_days"
    actual_resolution = "day_to_minutes"
    setChartToLinechart(true)
  else if actual_resolution == "year_to_months"
    actual_resolution = "month_to_days"
    setChartToBarchart(true)
  containing_timestamp = timestamp

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

zoomInGroup = (timestamp) ->
  chart.showLoading()

  if actual_resolution == "hour_to_minutes"
    #setChartToLinechart(true)
    chart.hideLoading()
    return
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    actual_resolution = "hour_to_minutes"
    setChartToLinechart(true)
  #else if actual_resolution == "week_to_days"
  #  actual_resolution = "day_to_hours"
  else if actual_resolution == "month_to_days"
  #  actual_resolution = "week_to_days"
    actual_resolution = "day_to_minutes"
    setChartToLinechart(true)
  else if actual_resolution == "year_to_months"
    actual_resolution = "month_to_days"
    setChartToBarchart(true)
  containing_timestamp = timestamp

  id = $(".group-chart").attr('id')
  numberOfSeries = 0
  $.ajax({url: '/groups/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] == undefined
        chart.hideLoading()
        return
      data.forEach (d) ->
        seriesVisible = chart.series[numberOfSeries].visible
        if !seriesVisible
          chart.series[numberOfSeries].show()
        chart.series[numberOfSeries].setData(d.data)
        new_point_width = setPointWidth()
        chart.series[numberOfSeries].update({pointWidth: new_point_width})
        chart.xAxis[0].update(getExtremes(containing_timestamp), true)
        chart_data_min_x = chart.series[0].data[0].x
        setChartTitle(chart_data_min_x)
        if !seriesVisible
          chart.series[numberOfSeries].hide()
        numberOfSeries += 1
  #checkIfPreviousDataExistsGroup()
  #checkIfNextDataExistsGroup()
  #checkIfZoomOutGroup()
  chart.hideLoading()


checkIfZoomOut = () ->
  $(".metering_point_detail").each (div) ->
    id = $(this).attr('id').split('_')[2]
    if actual_resolution == "hour_to_minutes"
      out_resolution = "day_to_hours"
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
    #  out_resolution = "week_to_days"
    #else if actual_resolution == "week_to_days"
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
        $(".btn-chart-zoomout").attr('disabled', true)
      $(".btn-chart-zoomout").removeAttr("disabled")
    )


checkIfZoomOutDashboard = () ->
  if actual_resolution == "hour_to_minutes"
    out_resolution = "day_to_hours"
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
  #  out_resolution = "week_to_days"
  #else if actual_resolution == "week_to_days"
    out_resolution = "month_to_days"
  else if actual_resolution == "month_to_days"
    out_resolution = "year_to_months"
  else if actual_resolution == "year_to_months"
    $(".btn-chart-zoomout").attr('disabled', true)
    return
  containing_timestamp = chart_data_min_x
  metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
  dataAvailable = false
  metering_point_ids.forEach (id) ->
    $.ajax({url: '/metering_points/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
      .success (data) ->
        if data[0].data[0] != undefined && data[0].data[1] != 0
          dataAvailable = true

  if !dataAvailable
    $(".btn-chart-next").attr('disabled', true)
  else
    $(".btn-chart-zoomout").removeAttr("disabled")

checkIfZoomOutGroup = () ->
  if actual_resolution == "hour_to_minutes"
    out_resolution = "day_to_hours"
  else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
  #  out_resolution = "week_to_days"
  #else if actual_resolution == "week_to_days"
    out_resolution = "month_to_days"
  else if actual_resolution == "month_to_days"
    out_resolution = "year_to_months"
  else if actual_resolution == "year_to_months"
    $(".btn-chart-zoomout").attr('disabled', true)
    return
  containing_timestamp = chart_data_min_x
  id = $(".group-chart").attr('id')
  dataAvailable = false
  $.ajax({url: '/groups/' + id + '/chart?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, async: true, dataType: 'json'})
    .success (data) ->
      if data[0].data[0] != undefined && data[0].data[1] != 0
        dataAvailable = true
  if !dataAvailable
    $(".btn-chart-next").attr('disabled', true)
  else
    $(".btn-chart-zoomout").removeAttr("disabled")


setChartToBarchart = (displaySeriesName) ->
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

setChartToLinechart = (displaySeriesName) ->
  if displaySeriesName
    chart.series.forEach (chartSeries) ->
      chartSeries.update({
        type: 'areaspline'
        tooltip:
          pointFormat: '{series.name}: <b>{point.y:,.0f} W</b><br/>'
      })
  else
    chart.series.forEach (series) ->
      series.update({
        type: 'areaspline'
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
  extremes = getExtremes(containing_timestamp)
  if actual_resolution == "hour_to_minutes"
    chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY") + " ...  " + moment(extremes.min).format("HH:mm") + " - " + moment(extremes.max).format("HH:mm")})
  else if actual_resolution == "day_to_minutes" || actual_resolution == "day_to_hours"
    chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY")})
  else if actual_resolution == "month_to_days"
    chart.setTitle({text: moment(extremes.min).format("MMMM YYYY")})
  else if actual_resolution == "year_to_months"
    chart.setTitle({text: moment(extremes.min).format("YYYY")})








#  ****** Chart Update Timers ******

createChartTimer = (resource_ids, mode) ->
  timers.push(
    window.setInterval(->
      updateChart(resource_ids, mode)
      return
    , 1000*60*3)
    )

updateChart = (resource_ids, mode) ->
  containing_timestamp = new Date().getTime()
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

$(".metering_point_scores").ready ->
  group_id = $(this).attr('data-content')
  $.ajax({url: '/metering_points/' + group_id + '/get_scores'})
    .success (data) ->
      sufficiency = data.sufficiency
      $(".score_sufficiency").append("<div class=circle-filled></div>") for [1..sufficiency] if sufficiency
      $(".score_sufficiency").append("<div class=circle-empty></div>") for [1..(5 - sufficiency)] if (5 - sufficiency)

      fitting = data.fitting
      $(".score_fitting").append("<div class=circle-filled></div>") for [1..fitting] if fitting
      $(".score_fitting").append("<div class=circle-empty></div>") for [1..(5 - fitting)] if (5 - fitting)
      $(".circle-filled").addClass("fa fa-circle")
      $(".circle-empty").addClass("fa fa-circle-o")





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
    if $(this).find(".metering_point-ticker").data('fake') == false
      $.ajax({url: '/metering_points/' + metering_point_id + '/latest_power', async: true, dataType: 'json'})
        .success (data) ->
          if data.online == true || data.virtual == true
            metering_point.find(".power-ticker").html(data.latest_power)
            if data.timestamp <= Date.now() - 60*1000
              metering_point.find(".power-ticker").css({opacity: 0.3})
            metering_point.find(".power-ticker").data('content', moment(data.timestamp).format("DD.MM.YYYY HH:mm:ss"))
            metering_point.find(".power-ticker").popover(placement: 'top', trigger: 'hover')
          else
            metering_point.find(".power-ticker").html('offline')
      if $(this).find(".metering_point-ticker").data('virtual') == true
        timers.push(
          window.setInterval(->
            pullVirtualPowerData(metering_point, metering_point_id)
            return
          , 1000*60)
          )
      else
        Pusher.host = $(".pusher").data('pusherhost')
        Pusher.ws_port = 8080
        Pusher.wss_port = 8080
        pusher = new Pusher($(".pusher").data('pusherkey'))

        channel = pusher.subscribe("metering_point_#{metering_point_id}")
        channel.bind "new_reading", (reading) ->
          metering_point.find(".power-ticker").html(reading.power)
          metering_point.find(".power-ticker").data('bs.popover').options.content = moment(reading.timestamp).format("DD.MM.YYYY HH:mm:ss")
          metering_point.find(".power-ticker").css({opacity: 1})
    else
      source = $(this).find(".metering_point-ticker").data('source')
      getFakeValue(metering_point_id, source)
      timers.push(
        window.setInterval(->
          setFakeValue(metering_point, metering_point_id, source)
          return
        , 1000*2)
        )


pullVirtualPowerData = (metering_point, metering_point_id) ->
  $.ajax({url: '/metering_points/' + metering_point_id + '/latest_power', async: true, dataType: 'json'})
    .success (data) ->
      if data.online == true || data.virtual == true
        metering_point.find(".power-ticker").html(data.latest_power)
        if data.timestamp <= Date.now().getTime() - 60*1000
            metering_point.find(".power-ticker").css({opacity: 0.3})
        metering_point.find(".power-ticker").data('content', moment(data.timestamp).format("DD.MM.YYYY HH:mm:ss"))
        metering_point.find(".power-ticker").popover(placement: 'top', trigger: 'hover')
        metering_point.find(".power-ticker").data('bs.popover').options.content = moment(reading.timestamp).format("DD.MM.YYYY HH:mm:ss")
        metering_point.find(".power-ticker").css({opacity: 1})
      else
        metering_point.find(".power-ticker").html('offline')

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
    if Date.parse(readingsSLP[1][0]) < new Date()
      getFakeValue(metering_point_id, 'slp')
    metering_point.find(".power-ticker").html interpolateFakekW(readingsSLP, factors[metering_point_id]).toFixed(0)
  else if source == 'sep_pv'
    if Date.parse(readingsSEP_PV[1][0]) < new Date()
      getFakeValue(metering_point_id, 'sep_pv')
    metering_point.find(".power-ticker").html interpolateFakekW(readingsSEP_PV, factors[metering_point_id]).toFixed(0)
  else
    if Date.parse(readingsSEP_BHKW[1][0]) < new Date()
      getFakeValue(metering_point_id, 'sep_BHKW')
    metering_point.find(".power-ticker").html interpolateFakekW(readingsSEP_BHKW, factors[metering_point_id]).toFixed(0)

interpolateFakekW = (data_arr, factor) ->
  firstTimestamp = data_arr[0][0]
  firstValue = data_arr[0][1]
  lastTimestamp = data_arr[1][0]
  lastValue = data_arr[1][1]
  averagePower = (lastValue - firstValue)/0.25*1000*factor
  return getRandomPower(averagePower)

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





