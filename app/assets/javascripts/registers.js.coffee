$(".register").ready ->
  $(".register").each ->
    $(this).find(".power-ticker").html(calculate_power($(this).find(".register-ticker").data('readings')))

calculate_power = (last_readings) =>
  if last_readings == undefined
    return -1
  return Math.round((last_readings[1] - last_readings[3])*3600/((last_readings[0] - last_readings[2])*10000))