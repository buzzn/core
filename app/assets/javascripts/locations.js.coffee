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
