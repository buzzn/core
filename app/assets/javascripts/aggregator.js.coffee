class @Aggregator
  constructor: (metering_point_id) ->
    @returned_ajax_data = []
    @metering_point_id = metering_point_id



  present: (timestamp) ->
    # ...

  past: (timestamp, resolution) ->
    if timestamp == undefined
      timestamp = new Date()
    if resolution == undefined
      resolution = 'day_to_minutes'

    instance = this

    url = '/api/v1/aggregates/past?timestamp=' + timestamp.toDateString() + '&resolution=' + resolution + '&metering_point_ids=' + @metering_point_id + '&access_token=' + gon.global.access_token
    ajaxCall = $.ajax({url: url, async: true, dataType: 'json'})
      .success (data) ->
        if Object.prototype.toString.call(data) == '[object Array]'
          data.forEach (data_point) ->
            instance.returned_ajax_data.push([(new Date(data_point.timestamp)).getTime(), Math.abs(data_point.energy_a_milliwatt_hour)/1000])
    return ajaxCall

  getData: () ->
    return @returned_ajax_data

  sumData: (arrays) ->
    console.log arrays
    result = []
    maxLength = 0
    indexMaxLength = 0
    index = 0
    arrays.forEach (data) ->
      if data.length >= maxLength
        maxLength = data.length
        indexMaxLength = index
      index++
    console.log indexMaxLength
    console.log maxLength
    for i in [0...maxLength]
      key = arrays[indexMaxLength][i][0]
      console.log key
      value = 0
      for n in [0...arrays.length]
        value += arrays[n][i][1] if arrays[n][i] != undefined && key == arrays[n][i][0]
      result.push([key, value])
    console.log result
    return result


