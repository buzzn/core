$(".register").ready ->
  Pusher.host = $(".pusher").data('pusherhost')
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher($(".pusher").data('pusherkey'))

  $(this).find(".power-ticker").html(calculate_power($(this).find(".register-ticker").data('readings')))
  register_id = $(this).attr('id')
  register = $(this)
  channel = pusher.subscribe("register_#{register_id}")
  channel.bind "new_reading", (reading) ->
    oldString = register.find(".register-ticker").attr('data-readings')
    oldWattHour = oldString.split(",")[1]
    oldTimestamp = oldString.split(",")[0].substring(1, oldString.split(",")[0].length)
    register.find(".register-ticker").attr('data-readings', "[#{reading.timestamp}, #{reading.watt_hour}, #{oldTimestamp}, #{oldWattHour}]")
    register.find(".power-ticker").html(calculate_power([reading.timestamp, reading.watt_hour, oldTimestamp, oldWattHour]))

calculate_power = (last_readings) =>
  if last_readings == undefined
    return -1
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))
