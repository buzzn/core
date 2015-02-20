$(".register").ready ->
  Pusher.host = $(".pusher").data('pusherhost')
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher($(".pusher").data('pusherkey'))

  $(".register").each ->
    $(this).find(".power-ticker").html(calculate_power($(this).find(".register-ticker").data('readings')))
    #register_id = $(this).attr('id')
    #channel = pusher.subscribe("register_#{register_id}")
    #channel.bind "new_reading", (reading) ->
      #$(this).find(".power-ticker").html()
      #chart.reset_radius(reading.register_id, reading.watt_hour, reading.timestamp)

calculate_power = (last_readings) =>
  if last_readings == undefined
    return -1
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))



  #for register_id in gon.register_ids

   # channel = pusher.subscribe("register_#{register_id}")
    #channel.bind "new_reading", (reading) ->
     # chart.reset_radius(reading.register_id, reading.watt_hour, reading.timestamp)
