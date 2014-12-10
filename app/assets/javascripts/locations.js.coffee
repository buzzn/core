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

  dispatcher = new WebSocketRails(document.URL.split("/")[2] + "/websocket")

  dispatcher.on_open = (data) ->
    console.log "Connection has been established: ", data

  channel = dispatcher.subscribe("readings")

  channel.bind "new", (reading) =>
    console.log "a new reading arrived!"

  #dispatcher.bind 'new_ticker_value', (metering_point_id, value) =>
    #$("#ticker_#{metering_point_id}").html value

  init_tree()




