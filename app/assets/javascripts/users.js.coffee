# $("#content-container").ready ->
#   Pusher.host    = $(".pusher").data('pusherhost')
#   Pusher.ws_port = 8080
#   Pusher.wss_port = 8080
#   pusher = new Pusher($(".pusher").data('pusherkey'))
#   if gon && gon.global && gon.global.current_user_id != undefined
#     channel = pusher.subscribe("user_#{gon.global.current_user_id}")
#     channel.bind "new_notification", (notification) ->
#       if notification.type == 'primary'
#         icon = 'fa fa-star fa-lg'
#       else if notification.type == 'info'
#         icon = 'fa fa-info fa-lg'
#       else if notification.type == 'success'
#         icon = 'fa fa-thumbs-up fa-lg'
#       else if notification.type == 'warning'
#         icon = 'fa fa-bolt fa-lg'
#       else if notification.type == 'danger'
#         icon = 'fa fa-times fa-lg'
#       else if notification.type == 'mint'
#         icon = 'fa fa-leaf fa-lg'
#       else if notification.type == 'purple'
#         icon = 'fa fa-shopping-cart fa-lg'
#       else if notification.type == 'pink'
#         icon = 'fa fa-heart fa-lg'
#       else if notification.type == 'dark'
#         icon = 'fa fa-sun-o fa-lg'
#       $.niftyNoty({
#         type: notification.type,
#         icon: icon,
#         title: notification.header,
#         message: notification.message,
#         container: "floating",
#         timer: 4000
#       })
#   else
#     console.log 'gon not available or variable undefined'