$("#content-container").ready ->
  if gon && gon.global
    pusher = new Pusher(gon.global.pusher_key)
    if gon.global.current_user_id != undefined
      channel = pusher.subscribe("user_#{gon.global.current_user_id}")
      channel.bind "new_notification", notify_user

      $(".badge-header-container").on "click", ->
         $.ajax({url: '/profiles/' + gon.global.profile_name + '/read_new_badge_notifications', dataType: 'text', type: 'PUT'})
          .success () ->
            $(".badge-danger").remove();
          .error (jqXHR, textStatus, errorThrown) ->
            console.log errorThrown
  else
    console.log 'gon not available or variable undefined'




notify_user = (notification) ->
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
    timer: 3
  })
