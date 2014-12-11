$(".profiles.show").ready ->

  pusher = new Pusher("83f4f88842ce2dc76b7b")

  for metering_point_id in gon.metering_point_ids

    channel = pusher.subscribe("reading_#{metering_point_id}")
    console.log "subscribed to channel reading_#{metering_point_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.metering_point_id}").html reading.watt_hour