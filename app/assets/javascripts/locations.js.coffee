$(".locations.show").ready ->

  timers = []

  init_tree = ->
    if document.URL.lastIndexOf('#') == -1
      url = document.URL
    else
      url = document.URL.substring(0, document.URL.lastIndexOf('#'))
    $.getJSON url + ".json", (data) ->
      json = JSON.stringify(data).substring(13, JSON.stringify(data).length - 1)
      $("#tree1").tree
        data: JSON.parse(json)
        autoOpen: true
        dragAndDrop: true
      return

  # Javascript to enable link to tab
  hash = document.location.hash
  $(".nav-pills a[href=" + hash + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    return

  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    target_click = e.target.toString().slice(e.target.toString().lastIndexOf("#"), e.target.length)
    if target_click == "#metering_point_tree"
      init_tree()

  $("#tree1").bind "tree.move", (event) ->
    url = "http://" + document.URL.split("/")[2] + "/metering_points/" + event.move_info.moved_node.id + "/update_parent?parent_id=" + event.move_info.target_node.id
    $.ajax(url)
    return

  Pusher.host    = gon.pusher_host
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher(gon.pusher_key)

  for register_id in gon.register_ids

    channel = pusher.subscribe("register_#{register_id}")
    console.log "subscribed to channel register_#{register_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.register_id}").html reading.watt_hour

  init_tree()

  minuteTimer = ->
    $(".metering_points").children().each(->
      metering_point_id = $(this).attr('id').split('_')[2]
      $.getJSON "/metering_points/" + metering_point_id + "/chart?resolution=day_to_hours", (data) ->
        $("#metering_point_#{metering_point_id}").find("[id^=chart-]").highcharts().series[0].setData(data[0].data)
        console.log "chart-#{metering_point_id} updated"
    )

  timers.push(
    window.setInterval(->
      minuteTimer()
      return
    , 1000*60)
    )

window.beforeunload = ->
  i = 0
  alert "verlassen " + timers.length
  while i < timers.length
    window.clearInterval timers[i]
    alert "cleared " + i
    i++
  timers = []






