# USAGE:
#
# For a single metering_point, only latest power:
#
#  aggregator = new Aggregator([metering_point_id])
#  $.when(aggregator.present(new Date())).done ->
#    data = aggregator.data
#
# For multiple metering_points, only chart data:
#
# out_aggregator = new Aggregator(out_ids)
# in_aggregator = new Aggregator(in_ids)
# $.when(out_aggregator.past(new Date(), 'day_to_minutes')).done ->
#   out_data = out_aggregator.data
#   $.when(in_aggregator.past(new Date(), 'day_to_minutes')).done ->
#     in_data = in_aggregator.data
#
# IMPORTANT: DONT REUSE AN AGGREGATOR INSTANCE FOR DIFFERENT CALLS, CREATE A NEW INSTANCE INSTEAD
#################################################################################################

class @Aggregator
  constructor: (metering_point_ids) ->
    @returned_ajax_data = []
    @data = []
    @metering_point_ids = metering_point_ids

  present: (timestamp) ->
    if timestamp == undefined
      timestamp = new Date()
    instance = this
    ajax_calls = []
    @metering_point_ids.forEach (id) ->
      ajax_calls.push(instance.fetchData(id, timestamp, 'present', 'present'))
    return $.when.apply($, ajax_calls).always( ->
      instance.sumData('present')
    ).promise()

  past: (timestamp, resolution) ->
    if timestamp == undefined
      timestamp = new Date()
    if resolution == undefined
      resolution = 'day_to_minutes'
    instance = this
    ajax_calls = []
    @metering_point_ids.forEach (id) ->
      ajax_calls.push(instance.fetchData(id, timestamp, resolution, 'past'))
    return $.when.apply($, ajax_calls).always( ->
      instance.sumData(resolution)
    ).promise()


  fetchData: (id, timestamp, resolution, chartType) ->
    instance = this
    if (parseInt(timestamp) == timestamp)
      timestamp = new Date(timestamp)
    url = ''
    if chartType == 'present'
      url = '/api/v1/aggregates/present?timestamp=' + encodeURIComponent(moment(timestamp).format('YYYY-MM-DDTHH:mm:ss.SSSZ')) + '&metering_point_ids=' + id + '&access_token=' + gon.global.access_token
    else
      url = '/api/v1/aggregates/past?timestamp=' + encodeURIComponent(moment(timestamp).format('YYYY-MM-DDTHH:mm:ss.SSSZ')) + '&resolution=' + resolution + '&metering_point_ids=' + id + '&access_token=' + gon.global.access_token

    ajaxCall = $.ajax({url: url, async: true, dataType: 'json'})
      .success (data) ->
        if chartType == 'past' && Object.prototype.toString.call(data) == '[object Array]'
          highcharts_data = []
          data.forEach (data_point) ->
            highcharts_data.push([(new Date(Object.values(data_point)[0])).getTime(), Object.values(data_point)[1]/instance.getScaleFactor(resolution)])
          instance.returned_ajax_data.push(highcharts_data)
        else if chartType == 'present'
          instance.returned_ajax_data.push([[(new Date(data.timestamp)).getTime(), data.power_milliwatt/1000]])
      .error (jqXHR, textStatus, errorThrown) ->
        if chartType == 'present'
          instance.returned_ajax_data.push([[(new Date(timestamp)).getTime(), 0]])
    return ajaxCall


  sumData: (resolution) ->
    instance = this
    @data = []
    for i in [0...@returned_ajax_data.length]
      for j in [0...@returned_ajax_data[i].length]
        if @returned_ajax_data[i][j] != undefined
          key = @returned_ajax_data[i][j][0]
          value = @returned_ajax_data[i][j][1]
          if i > 0
            timestampIndex = instance.findMatchingTimestamp(key, @data, resolution)
            if timestampIndex == -1
              @data.push([key, parseFloat(value.toFixed(3))])
            else
              @data[timestampIndex][1] += value
          else
            @data.push([key, parseFloat(value.toFixed(3))])
    @data.sort (a, b) ->
      return (a[0] - b[0])


  findMatchingTimestamp: (key, arr, resolution) ->
    for i in [0...arr.length]
      if resolution == 'year_to_months'
        if key >= Chart.Functions.beginningOfMonth(arr[i][0]) && key <= Chart.Functions.endOfMonth(arr[i][0])
          return i
      else if resolution == 'month_to_days'
        if key >= Chart.Functions.beginningOfDay(arr[i][0]) && key <= Chart.Functions.endOfDay(arr[i][0])
          return i
      else if resolution == 'day_to_minutes' #15 minutes
        if Math.abs(key - arr[i][0]) < 450000
          return i
      else if resolution == 'hour_to_minutes' || resolution == 'present' #2 seconds
        if Math.abs(key - arr[i][0]) < 2000
          return i
    return -1


  getScaleFactor: (resolution) ->
    if resolution == 'day_to_minutes' || resolution == 'hour_to_minutes'
      return 1000
    else
      return 1000


Object.values = (object) ->
  values = []
  for property of object
    values.push object[property]
  values

