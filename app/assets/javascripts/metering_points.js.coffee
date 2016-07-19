actual_resolution = "day_to_minutes"
chart_data_min_x = 0
chart = undefined
metering_point_ids_hash = {}

namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top



#code for partial: _metering_point.html.haml
$(".metering_points").ready ->
  $(this).find(".metering_point").each ->
    #smart = $(this).attr('data-smart')
    #online = $(this).attr('data-online')

    id = $(this).attr('id').split('_')[2]
    width = $("#chart-container-" + id).width()
    aggregator = new Aggregator([id])
    $.when(aggregator.past(new Date(), 'day_to_minutes')).done ->
      data = aggregator.data
      if data == undefined || data[0] == undefined || data[0][0] == undefined
        console.log data
        data = [[(new Date()).getTime(), -1]]
        #$('#chart-container-' + id).html('no data available')
      partial_chart = new Highcharts.Chart(
        chart:
          type: 'areaspline'
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
          min: Chart.Functions.beginningOfDay(data[0][0])
          max: Chart.Functions.endOfDay(data[0][0])
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
            turboThreshold: 0
          areaspline:
            marker:
              enabled: false
              #radius: 2
        tooltip:
          enabled: false

      )
      partial_chart.addSeries(
        name: ''
        data: data
      )


#code for metering_point.show
$(".metering_point_detail").ready ->
  chart = undefined
  id = $(this).attr('id').split('_')[2]
  width = $("#chart-container-" + id).width()
  aggregator = new Aggregator([id])
  $.when(aggregator.past(new Date(), 'day_to_minutes')).done ->
    data = aggregator.data
    if data == undefined || data[0] == undefined || data[0][0] == undefined
      console.log data
      data = [[(new Date()).getTime(), -1]]
      #$('#chart-container-' + id).html('no data available')
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
        animation: false
      colors: ['#FFF']
      exporting:
        enabled: false
      legend:
        enabled: false
      title:
        margin: 0
        text: "Heute, " + moment(data[0][0]).format("DD.MM.YYYY")
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
        min: Chart.Functions.beginningOfDay(data[0][0])
        max: Chart.Functions.endOfDay(data[0][0])
        labels:
          enabled: true
          style:
            color: '#FFF'
        title:
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
          text: ""
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
          turboThreshold: 0
        areaspline:
          borderWidth: 0
          cursor: 'pointer'
          events:
            click: (event) ->
              Chart.Functions.zoomIn(event.point.x)
          marker:
            enabled: false
        column:
          borderWidth: 0
          cursor: 'pointer'
          events:
            click: (event) ->
              Chart.Functions.zoomIn(event.point.x)
          #pointPlacement: "on"
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
    )
    chart.addSeries(
      name: ''
      data: data
    )
    if chart.series[0].data[0].x != undefined
      chart_data_min_x = chart.series[0].data[0].x
    else
      chart_data_min_x = (new Date()).getTime()
    createChartTimer([id], 'metering_point')
    Chart.Functions.activateButtons(true)
    Chart.Functions.getChartComments('metering_points', id, chart_data_min_x)



  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getPreviousTimestamp()
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getNextTimestamp()
    if containing_timestamp > new Date().getTime()
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
      return
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)

  $(".btn-chart-zoom-year").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "year_to_months"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)

  $(".btn-chart-zoom-month").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "month_to_days"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-day").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = chart_data_min_x
    actual_resolution = "day_to_minutes"
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-hour").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)


  $(".btn-chart-zoom-live").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = (new Date()).getTime()
    Chart.Functions.setChartData('metering_points', id, containing_timestamp)


  $(window).on "resize", ->
    new_point_width = Chart.Functions.setPointWidth()
    if chart != undefined
      chart.series[0].update({pointWidth: new_point_width})

  $(".chart-context-menu li").on "click", ->
    switch $(this).attr('data-action')
      when 'comment'
        $('.chart-comment-form').finish().toggle(100)
      # when 'zoom_in'
      #   zoomIn($('.chart-comment-form').find('#comment_chart_timestamp').attr('value'))
    $(".chart-context-menu").hide 100
    return

$(document).on "contextmenu", (event) ->
  if (event.target.nodeName == 'path' || event.target.nodeName == 'rect') && $(event.target).closest('.highcharts-series-group').length != 0
    event.preventDefault()
    if event.originalEvent.originalTarget  #Code for Firefox && Opera
      chart_comment_input_x = event.originalEvent.originalTarget.point.plotX + 150
      chart_comment_input_y = event.originalEvent.originalTarget.point.plotY + 140
      timestamp = event.originalEvent.originalTarget.point.x
    else if event.originalEvent.srcElement  #Code for Chrome
      chart_comment_input_x = event.originalEvent.srcElement.point.plotX + 150
      chart_comment_input_y = event.originalEvent.srcElement.point.plotY + 140
      timestamp = event.originalEvent.srcElement.point.x
    else
      console.log 'no element found'

    placeholder = $('.chart-comment-form').find('#comment_body').attr('placeholder')
    index = placeholder.indexOf("(")
    if index != -1
      placeholder = placeholder.substring(0, index - 1)
    displayed_time = new Date(timestamp)
    if actual_resolution == "hour_to_minutes"
      displayed_time = moment(timestamp).format("HH:mm")
    else if actual_resolution == "day_to_minutes" || actual_resolution == "day_to_hours"
      displayed_time = moment(timestamp).format("HH:mm")
    else if actual_resolution == "month_to_days"
      displayed_time = moment(timestamp).format("DD.MM")
    else if actual_resolution == "year_to_months"
      displayed_time = moment(timestamp).format("MMMM")
    $('.chart-comment-form').find('#comment_body').attr('placeholder', placeholder + ' (' + displayed_time + ')')
    $('.chart-comment-form').find('#comment_chart_timestamp').attr('value', timestamp)
    $('.chart-comment-form').find('#comment_chart_resolution').attr('value', actual_resolution)
    $(".chart-context-menu").finish().toggle(100).css({top: chart_comment_input_y + "px", left: chart_comment_input_x + "px"})



$(document).on "mousedown", (event) ->
  if !($(event.target).parents(".chart-context-menu").length > 0)
    $(".chart-context-menu").hide(100)





#code for dashboard
$(".dashboard-chart").ready ->
  chart = undefined
  dashboard_id = $(this).attr('id')
  width = $("#chart-container-" + dashboard_id).width()
  metering_point_ids = $(this).data('metering_point-ids').toString().split(",")

  i = 0
  metering_point_ids.forEach (id) ->
    if id != ""
      aggregator = new Aggregator([id])
      $.when(aggregator.past(new Date(), 'day_to_minutes')).done ->
        data = aggregator.data
        if data == undefined || data[0] == undefined || data[0][0] == undefined
          console.log data
          data = [[(new Date()).getTime(), -1]]
          #$('#chart-container-' + dashboard_id).html('no data available')
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
              animation: false
            colors: ['#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1']
            exporting:
              enabled: false
            legend:
              enabled: true
            title:
              margin: 0
              text: "Heute, " + moment(data[0][0]).format("DD.MM.YYYY")
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
              min: Chart.Functions.beginningOfDay(data[0][0])
              max: Chart.Functions.endOfDay(data[0][0])
              labels:
                enabled: true
                style:
                  color: '#000'
              title:
                enabled: false
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
                turboThreshold: 0
              areaspline:
                borderWidth: 0
                cursor: 'pointer'
                events:
                  click: (event) ->
                    Chart.Functions.zoomInDashboard(event.point.x)
                marker:
                  enabled: false
              column:
                borderWidth: 0
                cursor: 'pointer'
                events:
                  click: (event) ->
                    Chart.Functions.zoomInDashboard(event.point.x)
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
          )
          chart.addSeries(
            data: data
          )
          getMeteringPointName(id).success (metering_point_data) ->
            chart.series[metering_point_ids_hash[id]].update({name: metering_point_data.data.attributes.name})
          chart_data_min_x = chart.series[0].data[0].x
        else
          chart.addSeries(
            data: data
          )
          getMeteringPointName(id).success (metering_point_data) ->
            chart.series[metering_point_ids_hash[id]].update({name: metering_point_data.data.attributes.name})
        metering_point_ids_hash[id] = i
        i += 1
        Chart.Functions.activateButtons(true)
  createChartTimer(metering_point_ids, 'dashboard')





  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getPreviousTimestamp()
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getNextTimestamp()
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

  $(".btn-chart-zoom-year").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "year_to_months"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

  $(".btn-chart-zoom-month").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "month_to_days"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

  $(".btn-chart-zoom-day").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = chart_data_min_x
    actual_resolution = "day_to_minutes"
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

  $(".btn-chart-zoom-hour").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('dashboard', dashboard_id, containing_timestamp)

getMeteringPointName = (id) ->
  $.ajax({url: '/api/v1/metering-points/' + id + '?access_token=' + gon.global.access_token, async: true, dataType: 'json'})


#code for group
$(".group-chart").ready ->
  chart = undefined
  group_id = $(this).attr('id')
  in_ids = $(this).attr('metering_point_ids-in').split(",")
  out_ids = $(this).attr('metering_point_ids-out').split(",")
  width = $("#chart-container-" + group_id).width()

  out_aggregator = new Aggregator(out_ids)
  in_aggregator = new Aggregator(in_ids)
  $.when(out_aggregator.past(new Date(), 'day_to_minutes')).done ->
    out_data = out_aggregator.data
    $.when(in_aggregator.past(new Date(), 'day_to_minutes')).done ->
      in_data = in_aggregator.data

      if out_data == undefined || out_data[0] == undefined || out_data[0][0] == undefined
        console.log out_data
        out_data = [[(new Date()).getTime(), -1]]
        #$('#chart-container-' + group_id).html('no data available')
      if in_data == undefined || in_data[0] == undefined || in_data[0][0] == undefined
        console.log in_data
        in_data = [[(new Date()).getTime(), -1]]
        #$('#chart-container-' + group_id).html('no data available')

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
          animation: false
        colors: ['#5FA2DD', '#F76C51']
        exporting:
          enabled: false
        legend:
          enabled: true
        title:
          margin: 0
          text: "Heute, " + moment(out_data[0][0]).format("DD.MM.YYYY")
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
          min: Chart.Functions.beginningOfDay(out_data[0][0])
          max: Chart.Functions.endOfDay(out_data[0][0])
          labels:
            enabled: true
            style:
              color: '#000'
          title:
            enabled: false
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
            turboThreshold: 0
          areaspline:
            borderWidth: 0
            cursor: 'pointer'
            events:
              click: (event) ->
                Chart.Functions.zoomInGroup(event.point.x)
            marker:
              enabled: false
          column:
            cursor: 'pointer'
            events:
              click: (event) ->
                Chart.Functions.zoomInGroup(event.point.x)
            #stacking: 'normal'
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
      )
      chart.addSeries(
        name: 'Gesamtverbrauch'
        data: in_data
      )
      chart.addSeries(
        name: 'Gesamterzeugung'
        data: out_data
      )

      chart_data_min_x = chart.series[0].data[0].x
      Chart.Functions.activateButtons(true)
      Chart.Functions.setEnergyStatsGroup()


  $(".btn-chart-prev").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getPreviousTimestamp()
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-next").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = Chart.Functions.getNextTimestamp()
    if containing_timestamp > new Date().getTime()
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
      return
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-year").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "year_to_months"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-month").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "month_to_days"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-day").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    containing_timestamp = chart_data_min_x
    actual_resolution = "day_to_minutes"
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-hour").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = chart_data_min_x
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)


  $(".btn-chart-zoom-live").on 'click', ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    actual_resolution = "hour_to_minutes"
    containing_timestamp = (new Date()).getTime()
    Chart.Functions.setChartDataMultiSeries('groups', group_id, containing_timestamp)

  $(".chart-context-menu li").on "click", ->
    switch $(this).attr('data-action')
      when 'comment'
        $('.chart-comment-form').finish().toggle(100)
      # when 'zoom_in'
      #   zoomIn($('.chart-comment-form').find('#comment_chart_timestamp').attr('value'))
    $(".chart-context-menu").hide 100
    return



namespace 'Chart.Functions', (exports) ->
  exports.getExtremes = (timestamp) ->
    if actual_resolution == "hour_to_minutes"
      start = Chart.Functions.beginningOfHour(timestamp)
      end = Chart.Functions.endOfHour(timestamp)
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
      start = Chart.Functions.beginningOfDay(timestamp)
      end = Chart.Functions.endOfDay(timestamp)
    else if actual_resolution == "week_to_days"
      start = Chart.Functions.beginningOfWeek(timestamp)
      end = Chart.Functions.endOfWeek(timestamp)
    else if actual_resolution == "month_to_days"
      start = Chart.Functions.beginningOfMonth(timestamp)
      end = Chart.Functions.endOfMonth(timestamp)
    else if actual_resolution == "year_to_months"
      start = Chart.Functions.beginningOfYear(timestamp)
      end = Chart.Functions.endOfYear(timestamp)
    return {
      min: start
      max: end
    }

  exports.getPreviousTimestamp = () ->
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

  exports.getNextTimestamp = () ->
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

  exports.setPointWidth = () ->
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


  exports.zoomIn = (timestamp) ->
    Chart.Functions.activateButtons(false)
    chart.showLoading()
    $(".metering_point_detail").each (div) ->
      id = $(this).attr('id').split('_')[2]
      if actual_resolution == "hour_to_minutes"
        Chart.Functions.setChartType(false)
        chart.hideLoading()
        Chart.Functions.activateButtons(true)
        return
      else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
        actual_resolution = "hour_to_minutes"
        Chart.Functions.setChartType(false)
      else if actual_resolution == "month_to_days"
        actual_resolution = "day_to_minutes"
        Chart.Functions.setChartType(false)
      else if actual_resolution == "year_to_months"
        actual_resolution = "month_to_days"
        Chart.Functions.setChartType()
      containing_timestamp = timestamp
      Chart.Functions.setChartData('metering_points', id, containing_timestamp)

  exports.zoomInDashboard = (timestamp) ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    if actual_resolution == "hour_to_minutes"
      Chart.Functions.setChartType(true)
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
      return
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
      actual_resolution = "hour_to_minutes"
      Chart.Functions.setChartType(true)
    else if actual_resolution == "month_to_days"
      actual_resolution = "day_to_minutes"
      Chart.Functions.setChartType(true)
    else if actual_resolution == "year_to_months"
      actual_resolution = "month_to_days"
      Chart.Functions.setChartType(true)
    containing_timestamp = timestamp

    id = $(".dashboard-chart").attr('id')
    Chart.Functions.setChartDataMultiSeries('dashboard', id, containing_timestamp)

  exports.zoomInGroup = (timestamp) ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)
    if actual_resolution == "hour_to_minutes"
      Chart.Functions.setChartType(true)
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
      return
    else if actual_resolution == "day_to_hours" || actual_resolution == "day_to_minutes"
      actual_resolution = "hour_to_minutes"
      Chart.Functions.setChartType(true)
    #else if actual_resolution == "week_to_days"
    #  actual_resolution = "day_to_hours"
    else if actual_resolution == "month_to_days"
    #  actual_resolution = "week_to_days"
      actual_resolution = "day_to_minutes"
      Chart.Functions.setChartType(true)
    else if actual_resolution == "year_to_months"
      actual_resolution = "month_to_days"
      Chart.Functions.setChartType(true)
    containing_timestamp = timestamp

    id = $(".group-chart").attr('id')
    Chart.Functions.setChartDataMultiSeries('groups', id, containing_timestamp)




  exports.setChartType = (displaySeriesName) ->
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
      })
    else
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
      })


  exports.setChartTitle = (containing_timestamp) ->
    moment.locale('de')
    extremes = Chart.Functions.getExtremes(containing_timestamp)
    #console.log moment(extremes.min).format("DD.MM.YYYY") + ' comes from ' + moment(containing_timestamp).format("DD.MM.YYYY")
    if actual_resolution == "hour_to_minutes"
      chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY") + " ...  " + moment(extremes.min).format("HH:mm") + " - " + moment(extremes.max).format("HH:mm")})
    else if actual_resolution == "day_to_minutes" || actual_resolution == "day_to_hours"
      chart.setTitle({text: moment(extremes.min).format("DD.MM.YYYY")})
    else if actual_resolution == "month_to_days"
      chart.setTitle({text: moment(extremes.min).format("MMMM YYYY")})
    else if actual_resolution == "year_to_months"
      chart.setTitle({text: moment(extremes.max).format("YYYY")})

  exports.activateButtons = (disabled) ->
    $(".btn-chart-next").attr('disabled', !disabled)
    $(".btn-chart-prev").attr('disabled', !disabled)
    $(".btn-chart-zoomout").attr('disabled', !disabled)
    $(".btn-chart-zoom-year").attr('disabled', !disabled)
    $(".btn-chart-zoom-month").attr('disabled', !disabled)
    $(".btn-chart-zoom-day").attr('disabled', !disabled)
    $(".btn-chart-zoom-hour").attr('disabled', !disabled)
    $(".btn-chart-zoom-live").attr('disabled', !disabled)
    if disabled
      if actual_resolution == 'year_to_months'
        $(".btn-chart-zoom-year").attr('disabled', disabled)
      else if actual_resolution == 'month_to_days'
        $(".btn-chart-zoom-month").attr('disabled', disabled)
      else if actual_resolution == 'day_to_minutes'
        $(".btn-chart-zoom-day").attr('disabled', disabled)
      else if actual_resolution == 'hour_to_minutes'
        $(".btn-chart-zoom-hour").attr('disabled', disabled)


  exports.setResolution = (resolution) ->
    actual_resolution = resolution

  exports.showLoadingBlockButtons = ->
    chart.showLoading()
    Chart.Functions.activateButtons(false)

  exports.setChartData = (resource, id, containing_timestamp) ->
    aggregator = new Aggregator([id])
    $.when(aggregator.past(containing_timestamp, actual_resolution)).done ->
      data = aggregator.data
      if data == undefined || data[0] == undefined || data[0][0] == undefined
        console.log data
        data = [[containing_timestamp, -1]]
        #$('#chart-container-' + id).html('no data available')
        chart.hideLoading()
        Chart.Functions.activateButtons(true)
      chart.series[0].setData(data)
      new_point_width = Chart.Functions.setPointWidth()
      chart.series[0].update({pointWidth: new_point_width})
      chart.xAxis[0].update(Chart.Functions.getExtremes(containing_timestamp), true)
      #console.log chart.series[0]
      chart_data_min_x = chart.series[0].data[0].x
      Chart.Functions.setChartTitle(chart_data_min_x)
      Chart.Functions.setChartType(false)
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
      Chart.Functions.setEnergyStats()
      if $(".metering_point_detail").length > 0
        Chart.Functions.getChartComments(resource, id, containing_timestamp)

  exports.setChartDataMultiSeries = (resource, id, containing_timestamp) ->
    if resource == 'dashboard'
      metering_point_ids = $(".dashboard-chart").data('metering_point-ids').toString().split(",")
      metering_point_ids.forEach (metering_point_id) ->
        if metering_point_id != ""
          aggregator = new Aggregator([metering_point_id])
          $.when(aggregator.past(containing_timestamp, actual_resolution)).done ->
            data = aggregator.data
            if data == undefined || data[0] == undefined || data[0][0] == undefined
              console.log data
              data = [[containing_timestamp, -1]]
              #$('#chart-container-' + id).html('no data available')
            numberOfSeries = metering_point_ids_hash[metering_point_id]
            seriesVisible = chart.series[numberOfSeries].visible
            if !seriesVisible
              chart.series[numberOfSeries].show()
            chart.series[numberOfSeries].setData(data)
            new_point_width = Chart.Functions.setPointWidth()
            chart.series[numberOfSeries].update({pointWidth: new_point_width})
            extremes = Chart.Functions.getExtremes(containing_timestamp)
            chart.xAxis[0].update(extremes, true)
            chart_data_min_x = extremes.min
            Chart.Functions.setChartTitle(chart_data_min_x)
            Chart.Functions.setChartType(true)
            if !seriesVisible
              chart.series[numberOfSeries].hide()
      chart.hideLoading()
      Chart.Functions.activateButtons(true)
    else
      in_ids = $(".group-chart").attr('metering_point_ids-in').split(",")
      out_ids = $(".group-chart").attr('metering_point_ids-out').split(",")
      out_aggregator = new Aggregator(out_ids)
      in_aggregator = new Aggregator(in_ids)
      $.when(out_aggregator.past(containing_timestamp, actual_resolution)).done ->
        out_data = out_aggregator.data
        $.when(in_aggregator.past(containing_timestamp, actual_resolution)).done ->
          in_data = in_aggregator.data
          if in_data == undefined || in_data[0] == undefined || in_data[0][0] == undefined || out_data == undefined || out_data[0] == undefined || out_data[0][0] == undefined
            console.log data
            data = [[containing_timestamp, -1]]
            #$('#chart-container-' + id).html('no data available')
            chart.hideLoading()
            Chart.Functions.activateButtons(true)
          data = [in_data, out_data]
          numberOfSeries = 0
          data.forEach (d) ->
            seriesVisible = chart.series[numberOfSeries].visible
            if !seriesVisible
              chart.series[numberOfSeries].show()
            chart.series[numberOfSeries].setData(d)
            new_point_width = Chart.Functions.setPointWidth()
            chart.series[numberOfSeries].update({pointWidth: new_point_width})
            extremes = Chart.Functions.getExtremes(containing_timestamp)
            chart.xAxis[0].update(extremes, true)
            chart_data_min_x = extremes.min
            Chart.Functions.setChartTitle(chart_data_min_x)
            if !seriesVisible
              chart.series[numberOfSeries].hide()
            numberOfSeries += 1
          Chart.Functions.setChartType(true)
          chart.hideLoading()
          Chart.Functions.activateButtons(true)
          Chart.Functions.setEnergyStatsGroup()
          Chart.Functions.getChartComments(resource, id, chart_data_min_x)


  exports.endOfDay = (timestamp) ->
    end = new Date(timestamp)
    end.setHours(23,59,59,999)
    return end.getTime()

  exports.beginningOfDay = (timestamp) ->
    start = new Date(timestamp)
    start.setHours(0,0,0,0)
    return start.getTime()

  exports.endOfMonth = (timestamp) ->
    tmpDate = new Date(timestamp)
    end = new Date(tmpDate.getFullYear(), tmpDate.getMonth() + 1, 0)
    end.setHours(23, 59, 59, 999)
    return end.getTime()

  exports.beginningOfMonth = (timestamp) ->
    start = new Date(timestamp)
    start.setDate(1)
    start.setHours(0,0,0,0)
    return start.getTime()# - 43200000

  exports.beginningOfYear = (timestamp) ->
    tmpDate = new Date(timestamp)
    start = new Date(tmpDate.getFullYear(), 0, 1)
    start.setHours(0,0,0,0)
    return start.getTime()# - 1296000000

  exports.endOfYear = (timestamp) ->
    tmpDate = new Date(timestamp)
    end = new Date(tmpDate.getFullYear(), 11, 31)
    end.setHours(23, 59, 59, 999)
    return end.getTime()

  exports.beginningOfHour = (timestamp) ->
    start = new Date(timestamp)
    start.setMinutes(0,0,0)
    return start.getTime()

  exports.endOfHour = (timestamp) ->
    end = new Date(timestamp)
    end.setMinutes(59,59,999)
    return end.getTime()

  exports.beginningOfWeek = (timestamp) ->
    startDay = 1
    start = new Date(timestamp.valueOf() - (timestamp<=0 ? 7-startDay:timestamp-startDay)*86400000);
    start.setHours(0,0,0,0)
    return start.getTime()

  exports.endOfWeek = (timestamp) ->
    startDay = 1
    start = new Date(timestamp.valueOf() - (timestamp<=0 ? 7-startDay:timestamp-startDay)*86400000);
    end = new Date(start.valueOf() + 6*86400000);
    end.setHours(23,59,59,999)
    return end.getTime()


  exports.getChartComments = (resource, resource_id, containing_timestamp) ->
    $.ajax({url: '/' + resource + '/' + resource_id + '/chart_comments?resolution=' + actual_resolution + '&containing_timestamp=' + containing_timestamp, dataType: 'json'})
      .success (data) ->
        $('.chart-comments').find('.chart-comment').each ->
          $(this).remove()
        data.comments.forEach (comment) ->
          $('.chart-comments').append("<div class='chart-comment pull-left' id=chart-comment_#{comment.comment_id} data-content='#{comment.body}' data-chart_timestamp='#{comment.chart_timestamp}'>#{comment.user_image} </div>")
          comment_div = $("#chart-comment_#{comment.comment_id}")
          comment_div.on 'click', ->
            $('html, body').animate({ scrollTop: $('.comments-content').offset().top}, 1000)
            $('.nano-content').animate({ scrollTop: $("#comment_#{comment.comment_id}")[0].offsetTop}, 1000)
            $("#comment_#{comment.comment_id}").find('.comment-answer').show()
        Chart.Functions.resizeChartComments(true, resource_id)
        $('.chart-comment').popover(placement: 'bottom', trigger: "hover" )


  exports.resizeChartComments = (initializing, resource_id) ->
    if $(".chart-comments").length == 0
      return
    firstDataX = parseInt($('.highcharts-series-group').find('.highcharts-series').first().children().first().attr('x')) || 0
    pointWidth = parseInt($('.highcharts-series-group').find('.highcharts-series').first().children().first().attr('width')) || 0
    xAxisWidth = $('.highcharts-axis').first()[0].getBoundingClientRect().width || $('.highcharts-axis').first().children().last()[0].getBoundingClientRect().width
    xAxisOffset = 2*firstDataX + pointWidth
    xAxisWidth -= xAxisOffset
    if $('.highcharts-axis').first()[0].getBoundingClientRect().x && $('.highcharts-axis').first()[0].getBoundingClientRect().x != 0
      xAxisLeftMargin = $('.highcharts-axis').first()[0].getBoundingClientRect().x
    else
      xAxisLeftMargin = $('.highcharts-axis').first()[0].getBoundingClientRect().left || $('.highcharts-axis').first().children().first()[0].getBoundingClientRect().left
    xAxisLeftMarginOffset = firstDataX + 0.5 * pointWidth
    xAxisLeftMargin += xAxisLeftMarginOffset
    min_max = Chart.Functions.getExtremes(chart_data_min_x)
    x_min = min_max.min
    x_max = min_max.max
    occuring_timestamps = []
    $('.chart-comment').each ->
      chart_timestamp = $(this).data('chart_timestamp')
      offset_top = 10
      count = {}
      i = 0
      while i < occuring_timestamps.length
        timestamp = occuring_timestamps[i]
        count[timestamp] = if count[timestamp] then count[timestamp] + 1 else 1
        i++
      if $.inArray(chart_timestamp, occuring_timestamps) != -1
        offset_top -= count[chart_timestamp]*8
      occuring_timestamps.push(chart_timestamp)
      original_offset = $(this).offset()
      left_new = (chart_timestamp - x_min)/((x_max - x_min))*xAxisWidth
      if initializing
        new_offset_top = original_offset.top - offset_top - 7
      else
        new_offset_top = original_offset.top
      $(this).offset({top: new_offset_top , left: xAxisLeftMargin + left_new - 6 - offset_top})


  exports.refreshChartComments = () ->
    url = window.location.href
    resource = url.toString().split('/')[3]
    resource_id = url.toString().split('/')[4]
    Chart.Functions.getChartComments(resource, resource_id, chart_data_min_x)

  exports.setEnergyStats = () ->
    if chart && chart.series.length != 0 && chart.series[0].data.length != 0 && chart.series[0].type == 'column'
      min = chart.series[0].data[0].y
      min_time = chart.series[0].data[0].x
      max = min
      max_time = min_time
      sum = 0
      chart.series[0].data.forEach (reading) ->
        value = reading.y
        time = reading.x
        if value >= max
          max = value
          max_time = time
        if value <= min
          min = value
          min_time = time
        sum += value
      if actual_resolution == 'year_to_months'
        format_string = "MMMM"
      else if actual_resolution == 'month_to_days'
        format_string = "DD.MM"
      moment.locale('de')
      if max.toFixed(2) != '-1.00'
        $('.stats-energy-max').html(max.toFixed(2))
      else
        $('.stats-energy-max').html('n.a.')
      $('.stats-energy-max-time').html('max (kWh): ' + moment(max_time).format(format_string))
      if min.toFixed(2) != '-1.00'
        $('.stats-energy-min').html(min.toFixed(2))
      else
        $('.stats-energy-min').html('n.a.')
      $('.stats-energy-min-time').html('min (kWh): ' + moment(min_time).format(format_string))
      if sum.toFixed(2) != '-1.00'
        $('.stats-energy-sum').html(sum.toFixed(2))
      else
        $('.stats-energy-sum').html('n.a.')


      $('.metering_point-stats').show(500);
    else
      $('.metering_point-stats').hide(500);

  exports.setEnergyStatsGroup = () ->
    if chart && chart.series.length != 0 && chart.series[0].data.length != 0
      if actual_resolution == "day_to_minutes" && chart_data_min_x >= Chart.Functions.beginningOfDay((new Date()).getTime()) || actual_resolution == "hour_to_minutes"
        own_consumption = 0
        foreign_consumption = 0
        for i in [0...chart.series[0].data.length]
          if chart.series[1].data[i]
            if chart.series[1].data[i].y >= chart.series[0].data[i].y
              own_consumption += chart.series[0].data[i].y
            else
              own_consumption += chart.series[1].data[i].y
              foreign_consumption += chart.series[0].data[i].y - chart.series[1].data[i].y
        if foreign_consumption + own_consumption != 0
          autarchy = (own_consumption*100 / (foreign_consumption + own_consumption)).toFixed(2)
        else
          autarchy = "n.a."
        $('.stats-autarchy').html(autarchy)
      else
        url = window.location.href
        resource_id = url.toString().split('/')[4]
        $.ajax({url: '/groups/' + resource_id + '/get_scores?resolution=' + actual_resolution + '&containing_timestamp=' + chart_data_min_x, dataType: 'json'})
          .success (data) ->
            if data.autarchy != null && data.autarchy != -1
              $('.stats-autarchy').html((data.autarchy*100).toFixed(2))
            else
              $('.stats-autarchy').html('n.a.')

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
  #if actual_resolution == 'hour_to_minutes'
  #  return
  if mode == 'metering_point'
    if resource_ids.length == 0
      return
    Chart.Functions.setChartData('metering_points', resource_ids[0], chart_data_min_x)
  else if mode == 'dashboard'
    if resource_ids.length == 0
      return
    Chart.Functions.setChartDataMultiSeries('dashboard', resource_ids, chart_data_min_x)
  else if mode == 'group'
    if resource_ids.length == 0
      return
    Chart.Functions.setChartDataMultiSeries('groups', resource_ids[0], chart_data_min_x)




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
    timers.push(window.setInterval(->
      getLiveData(metering_point, metering_point_id)
      return
    , 1000*5)
    )

getLiveData = (metering_point, metering_point_id) ->
  aggregator = new Aggregator([metering_point_id])
  $.when(aggregator.present(new Date())).done ->
    data = aggregator.data
    if parseInt(data[0][1]) != -1
      metering_point.find(".power-ticker").html(parseInt(data[0][1]))
    else
      metering_point.find(".power-ticker").html("n.a.")
    if data.timestamp <= Date.now() - 60*1000
      metering_point.find(".power-ticker").css({opacity: 0.3})
    else
      metering_point.find(".power-ticker").css({opacity: 1})
    metering_point.find(".power-ticker").data('content', moment(data[0][0]).format("DD.MM.YYYY HH:mm:ss"))
    metering_point.find(".power-ticker").popover(placement: 'top', trigger: 'hover')
    metering_point.find(".power-ticker").data('bs.popover').options.content = moment(data[0][0]).format("DD.MM.YYYY HH:mm:ss")
    if $(".metering_point_detail").length != 0 && chart != undefined && actual_resolution == 'hour_to_minutes'
      if chart_data_min_x > data[0][0] - 60*60*1000
        chart.series[0].addPoint([data[0][0], data[0][1]])
      if data[0][0] > chart_data_min_x +  60 *60 *1000 && data[0][0] < chart_data_min_x +  60 *60 *1011
        # TODO: if 1 hour is over toggle to next hour, but only if displayed
        # macht getExtremes oder?
        chart_data_min_x = data[0][0]
        # console.log("aktualisiere Chart " + data.timestamp + " power " + data.latest_power)
        chart.xAxis[0].update(Chart.Functions.getExtremes(data[0][0]), true)
        Chart.Functions.setChartTitle(data[0][0])
        Chart.Functions.setChartData('metering_points', metering_point_id, data[0][0])
      if window.wisActive && window.wwasInactive # eigentlich nur, wenn neu aktiv oder wenn delta t zu groß
        window.wwasInactive = false
        Chart.Functions.setChartData('metering_points', metering_point_id, data[0][0])
        # console.log("neuer Chart " + data.timestamp + " power " + data.latest_power)

    if actual_resolution == 'day_to_minutes'
      window.wwasInactive = false


clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []

$(document).on('page:before-change', clearTimers)
