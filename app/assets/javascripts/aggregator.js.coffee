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
    return $.when.apply($, ajax_calls).done( ->
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
    return $.when.apply($, ajax_calls).done( ->
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
          instance.returned_ajax_data.push([[(new Date(Object.values(data)[0])).getTime(), Object.values(data)[1]/1000]])
    return ajaxCall

  sumData: (resolution) ->
    @data = []
    maxLength = 0
    indexMaxLength = 0
    index = 0
    @returned_ajax_data.forEach (data) ->
      if data.length >= maxLength
        maxLength = data.length
        indexMaxLength = index
      index++
    for i in [0...maxLength]
      key = @returned_ajax_data[indexMaxLength][i][0]
      value = 0
      for n in [0...@returned_ajax_data.length]
        if @returned_ajax_data[n][i] != undefined && (key == @returned_ajax_data[n][i][0] || @matchesTimestamp(key, @returned_ajax_data[n][i][0], resolution))
          value += @returned_ajax_data[n][i][1]
      @data.push([key, parseFloat(value.toFixed(3))])


  matchesTimestamp: (key, timestamp, resolution) ->
    delta = Math.abs(key - timestamp)
    if resolution == 'year_to_months'
      return delta <= 1296000000
    else if resolution == 'month_to_days'
      return delta <= 43200000
    else if resolution == 'day_to_minutes' #15 minutes
      return delta <= 450000
    else if resolution == 'hour_to_minutes' || resolution == 'present' #2 seconds
      return delta <= 1000

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

