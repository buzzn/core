$(".locations.show").ready ->

  init_tree = ->
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

  pusher = new Pusher("83f4f88842ce2dc76b7b")

  for metering_point_id in gon.metering_point_ids

    channel = pusher.subscribe("reading_#{metering_point_id}")
    console.log "subscribed to channel reading_#{metering_point_id}"

    channel.bind "new_reading", (reading) ->
      console.log "new reading arrived!" + reading.watt_hour

  init_tree()




