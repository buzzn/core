readingsSLP = []
timers = []

$(".metering_point").ready ->
  metering_point_id = $(this).attr('id')
  metering_point = $(this)
  if $(this).find(".metering_point-ticker").data('slp') == false
    Pusher.host = $(".pusher").data('pusherhost')
    Pusher.ws_port = 8080
    Pusher.wss_port = 8080
    pusher = new Pusher($(".pusher").data('pusherkey'))

    $(this).find(".power-ticker").html(calculate_power($(this).find(".metering_point-ticker").data('readings')))

    channel = pusher.subscribe("metering_point_#{metering_point_id}")
    channel.bind "new_reading", (reading) ->
      oldString = metering_point.find(".metering_point-ticker").attr('data-readings')
      oldWattHour = oldString.split(",")[1]
      oldTimestamp = oldString.split(",")[0].substring(1, oldString.split(",")[0].length)
      metering_point.find(".metering_point-ticker").attr('data-readings', "[#{reading.timestamp}, #{reading.watt_hour}, #{oldTimestamp}, #{oldWattHour}]")
      metering_point.find(".power-ticker").html(calculate_power([reading.timestamp, reading.watt_hour, oldTimestamp, oldWattHour]))
  else
    getSLPValue()
    timers.push(
      window.setInterval(->
        setSLPValue(metering_point)
        return
      , 1000*2)
      )

calculate_power = (last_readings) =>
  if last_readings == undefined || last_readings == null
    return "?"
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))



getSLPValue = ->
  $.getJSON "/metering_points/1/latest_slp", (data) ->
    readingsSLP = data

setSLPValue = (metering_point) ->
  if Date.parse(readingsSLP[1][0]) < new Date()
    getSLPValue()
  metering_point.find(".power-ticker").html interpolateSLPkW().toFixed(0)

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