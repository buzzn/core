readingsSLP = []
timers = []

$(".register").ready ->
  register_id = $(this).attr('id')
  register = $(this)
  if $(this).find(".register-ticker").data('slp') == false
    Pusher.host = $(".pusher").data('pusherhost')
    Pusher.ws_port = 8080
    Pusher.wss_port = 8080
    pusher = new Pusher($(".pusher").data('pusherkey'))

    $(this).find(".power-ticker").html(calculate_power($(this).find(".register-ticker").data('readings')))

    channel = pusher.subscribe("register_#{register_id}")
    channel.bind "new_reading", (reading) ->
      oldString = register.find(".register-ticker").attr('data-readings')
      oldWattHour = oldString.split(",")[1]
      oldTimestamp = oldString.split(",")[0].substring(1, oldString.split(",")[0].length)
      register.find(".register-ticker").attr('data-readings', "[#{reading.timestamp}, #{reading.watt_hour}, #{oldTimestamp}, #{oldWattHour}]")
      register.find(".power-ticker").html(calculate_power([reading.timestamp, reading.watt_hour, oldTimestamp, oldWattHour]))
  else
    getSLPValue()
    timers.push(
      window.setInterval(->
        setSLPValue(register)
        return
      , 1000*2)
      )

calculate_power = (last_readings) =>
  if last_readings == undefined
    return -1
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))



getSLPValue = ->
  $.getJSON "/metering_points/1/latest_slp", (data) ->
    readingsSLP = data

setSLPValue = (register) ->
  if Date.parse(readingsSLP[1][0]) < new Date()
    getSLPValue()
  register.find(".power-ticker").html interpolateSLPkW().toFixed(0) + " W"

interpolateSLPkW = ->
  firstTimestamp = readingsSLP[0][0]
  firstValue = readingsSLP[0][1]
  lastTimestamp = readingsSLP[1][0]
  lastValue = readingsSLP[1][1]
  averagePower = (lastValue - firstValue)/0.25*1000
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