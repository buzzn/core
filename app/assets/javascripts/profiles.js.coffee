timers = []

clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []

$(".profiles.show").ready ->

  Pusher.host    = gon.pusher_host
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher(gon.pusher_key)

  for register_id in gon.register_ids

    channel = pusher.subscribe("register_#{register_id}")
    console.log "subscribed to channel register_#{register_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.register_id}").html reading.watt_hour

  minuteTimer = ->
    $(".location_metering_points").children().each(->
      metering_point_id = $(this).attr('id').split('_')[2]
      $.getJSON "/metering_points/" + metering_point_id + "/chart?resolution=day_to_hours", (data) ->
        $("#metering_point_#{metering_point_id}").find("[id^=chart-]").highcharts().series[0].setData(data[0].data)
        $("#metering_point_#{metering_point_id}").find("[id^=chart-]").highcharts().xAxis.dateTimeLabelFormats
        console.log "chart-#{metering_point_id} updated"
    )

  timers.push(
    window.setInterval(->
      minuteTimer()
      return
    , 1000*60)
    )




$(document).on('page:before-change', clearTimers)




