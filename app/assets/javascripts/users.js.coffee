$("#content-container").ready ->
  if gon && gon.global
    pusher = new Pusher(gon.global.pusher_key)
    # pusher.connection.bind 'state_change', (states) ->
    #   console.log 'changed from ' + states.previous + ' to ' + states.current

    if gon.global.current_user_id != undefined
      channel = pusher.subscribe("user_#{gon.global.current_user_id}")
      console.log "subscribed to user_#{gon.global.current_user_id}"
      channel.bind "new_notification", (notification) ->
        #console.log 'new_notification'
        #console.log notification.message
        if notification.type == 'primary'
          icon = 'fa fa-star fa-lg'
        else if notification.type == 'info'
          icon = 'fa fa-info fa-lg'
        else if notification.type == 'success'
          icon = 'fa fa-thumbs-up fa-lg'
        else if notification.type == 'warning'
          icon = 'fa fa-bolt fa-lg'
        else if notification.type == 'danger'
          icon = 'fa fa-times fa-lg'
        else if notification.type == 'mint'
          icon = 'fa fa-leaf fa-lg'
        else if notification.type == 'purple'
          icon = 'fa fa-shopping-cart fa-lg'
        else if notification.type == 'pink'
          icon = 'fa fa-heart fa-lg'
        else if notification.type == 'dark'
          icon = 'fa fa-sun-o fa-lg'
        $.niftyNoty({
          type: notification.type,
          icon: icon,
          title: notification.header,
          message: notification.message,
          container: "floating",
          timer: notification.duration
        })
    $(window).on 'beforeunload', ->
      pusher.disconnect()
  else
    console.log 'gon not available or variable undefined'