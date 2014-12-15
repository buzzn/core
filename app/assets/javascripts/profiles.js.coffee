$(".profiles.show").ready ->

  pusher = new Pusher("83f4f88842ce2dc76b7b")

  for register_id in gon.register_ids

    channel = pusher.subscribe("register_#{register_id}")
    console.log "subscribed to channel register_#{register_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.register_id}").html reading.watt_hour